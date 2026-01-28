extends Control

## 游戏主界面控制器
## 管理游戏主界面的所有逻辑

var current_level: LevelData
var current_dragging_card: CauseCard = null
var chain_slots: Array[ChainSlot] = []
var is_undoing_redoing: bool = false  # 标记是否正在执行撤销/重做，避免重复记录

@onready var level_label = $Header/LevelLabel
@onready var result_card = $ResultCardContainer/ResultCard
@onready var strength_bar = $StrengthBar
@onready var strength_label = $StrengthBar/StrengthLabel
@onready var chain_area = $ChainArea
@onready var chain_slots_container = $ChainArea/ChainSlots
@onready var candidate_grid = $CandidateArea/CandidateGrid
@onready var validate_button = $ActionButtons/ValidateButton
@onready var clear_button = $ActionButtons/ClearButton
@onready var result_panel = $ResultPanel
@onready var error_toast = $ErrorToast

func _ready():
	# 初始化并应用主题
	ThemeManager.initialize()
	ThemeManager.apply_theme_to_scene(self)
	
	# 设置背景色
	var background = get_node_or_null("Background")
	if background and background is ColorRect:
		background.color = ThemeManager.get_color("background")
	
	# 为按钮设置主题类型
	if validate_button:
		validate_button.theme_type_variation = "ButtonPrimary"
	if clear_button:
		clear_button.theme_type_variation = "ButtonSecondary"
	
	# 为标签设置主题类型
	if level_label:
		level_label.theme_type_variation = "LabelH2"
	if result_card:
		result_card.theme_type_variation = "LabelH3"
	if strength_label:
		strength_label.theme_type_variation = "LabelSecondary"
	
	# 清空历史记录（新关卡开始）
	UndoRedoManager.clear()
	
	# 从 GameManager 获取当前关卡
	if GameManager.current_level:
		current_level = GameManager.current_level
		_setup_level()
	else:
		# 如果没有，默认加载关卡1
		_load_level(1)
	_connect_signals()

func _load_level(level_id: int):
	# 备用加载方法
	var level_path = "res://data/levels/level_%02d.tres" % level_id
	if ResourceLoader.exists(level_path):
		current_level = load(level_path) as LevelData
		_setup_level()
	else:
		push_error("关卡文件不存在：", level_path)

func _setup_level():
	if not current_level:
		return
	
	# 设置关卡标题
	if I18nManager:
		level_label.text = I18nManager.translate("ui.game.level") + " %02d" % GameManager.current_level_id
	else:
		level_label.text = "关卡 %02d" % GameManager.current_level_id
	
	# 设置结果卡片
	var result_node = _find_node_by_id(current_level.result_id, current_level.candidates)
	if result_node:
		result_card.text = result_node.label
	else:
		if I18nManager:
			result_card.text = I18nManager.translate("ui.game.result_node")
		else:
			result_card.text = "结果节点"
	
	# 创建候选节点卡片
	_create_candidate_cards()
	
	# 创建因果链槽位
	_create_chain_slots()
	
	# 更新强度条
	_update_strength_bar()

func _find_node_by_id(node_id: String, nodes: Array[CauseNode]) -> CauseNode:
	for node in nodes:
		if node.id == node_id:
			return node
	return null

func _create_candidate_cards():
	# 清除现有卡片
	for child in candidate_grid.get_children():
		child.queue_free()
	
	# 创建新卡片（排除结果节点）
	for candidate in current_level.candidates:
		# 跳过结果节点
		if candidate.id == current_level.result_id:
			continue
		
		var card_scene = preload("res://scenes/components/CauseCard.tscn")
		var card = card_scene.instantiate() as CauseCard
		card.cause_data = candidate
		candidate_grid.add_child(card)
		
		# 连接信号
		card.drag_started.connect(_on_card_drag_started)
		card.drag_ended.connect(_on_card_drag_ended)

func _create_chain_slots():
	# 清除现有槽位
	for child in chain_slots_container.get_children():
		child.queue_free()
	chain_slots.clear()
	
	# 创建槽位
	for i in range(current_level.max_steps):
		var slot_scene = preload("res://scenes/components/ChainSlot.tscn")
		var slot = slot_scene.instantiate() as ChainSlot
		chain_slots_container.add_child(slot)
		chain_slots.append(slot)
		
		# 连接信号
		slot.card_placed.connect(_on_card_placed)
		slot.card_removed.connect(_on_card_removed)
		
		# 添加箭头（更大、更明显）
		var arrow = Label.new()
		if I18nManager:
			arrow.text = I18nManager.translate("ui.game.arrow")
		else:
			arrow.text = "→"
		arrow.add_theme_font_size_override("font_size", 32)
		arrow.add_theme_color_override("font_color", ThemeManager.get_color("info"))
		arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		# 设置箭头的最小尺寸，确保有足够空间
		arrow.custom_minimum_size = Vector2(32, 120)
		chain_slots_container.add_child(arrow)
	
	# 添加结果节点显示（固定，更大更明显）
	var result_slot = Label.new()
	if I18nManager:
		result_slot.text = I18nManager.translate("ui.game.result")
	else:
		result_slot.text = "结果"
	result_slot.add_theme_font_size_override("font_size", 20)
	result_slot.add_theme_color_override("font_color", ThemeManager.get_color("success"))
	result_slot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_slot.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# 设置结果节点的最小尺寸，与槽位一致
	result_slot.custom_minimum_size = Vector2(180, 120)
	chain_slots_container.add_child(result_slot)

func _connect_signals():
	validate_button.pressed.connect(_on_validate_pressed)
	clear_button.pressed.connect(_on_clear_pressed)

func _on_card_drag_started(card: CauseCard):
	current_dragging_card = card
	_update_slot_hints(card)

func _on_card_drag_ended(card: CauseCard):
	current_dragging_card = null
	_clear_slot_hints()
	
	# 如果卡片没有被使用（放置失败），返回原位置
	if card and not card.is_used:
		card.return_to_original()
	
	_update_strength_bar()

func _update_slot_hints(card: CauseCard):
	for slot in chain_slots:
		if slot.can_accept_card(card):
			slot.current_state = ChainSlot.State.HOVER_VALID
		else:
			slot.current_state = ChainSlot.State.HOVER_INVALID
		slot._update_visual()

func _clear_slot_hints():
	for slot in chain_slots:
		if slot.current_card:
			slot.current_state = ChainSlot.State.FILLED
		else:
			slot.current_state = ChainSlot.State.EMPTY
		slot._update_visual()

func _on_card_placed(slot: ChainSlot, card: CauseCard):
	# 记录操作到撤销/重做管理器（如果不是在执行撤销/重做）
	if not is_undoing_redoing:
		var slot_index = chain_slots.find(slot)
		if slot_index >= 0 and card and card.cause_data:
			UndoRedoManager.record_place(slot_index, card.cause_data.id)
	
	_update_strength_bar()

func _on_card_removed(slot: ChainSlot, card_id: String):
	# 记录操作到撤销/重做管理器（如果不是在执行撤销/重做）
	if not is_undoing_redoing and card_id:
		var slot_index = chain_slots.find(slot)
		if slot_index >= 0:
			UndoRedoManager.record_remove(slot_index, card_id)
	
	_update_strength_bar()

func _get_current_chain() -> Array[String]:
	var chain: Array[String] = []
	for slot in chain_slots:
		if slot.current_card and slot.current_card.cause_data:
			chain.append(slot.current_card.cause_data.id)
	# 添加结果节点
	if current_level:
		chain.append(current_level.result_id)
	return chain

func _calculate_current_strength(chain: Array[String]) -> float:
	if not current_level or chain.size() < 2:
		return 0.0
	
	var total_strength = 0.0
	for i in range(chain.size() - 1):
		var from_id = chain[i]
		var to_id = chain[i + 1]
		
		# 查找匹配的规则
		for rule in current_level.rules:
			if rule.from_id == from_id and rule.to_id == to_id:
				total_strength += rule.strength
				break
	
	return total_strength

func _update_strength_bar():
	var chain = _get_current_chain()
	var strength = _calculate_current_strength(chain)
	
	if current_level:
		var ratio = (strength / current_level.required_strength) * 100.0
		var target_value = clamp(ratio, 0.0, 100.0)
		
		# 使用Tween平滑过渡
		var tween = create_tween()
		tween.tween_property(strength_bar, "value", target_value, 0.3).set_ease(Tween.EASE_OUT)
		
		# 更新标签
		if I18nManager:
			strength_label.text = I18nManager.translate("ui.game.strength_format", {"current": "%.1f" % strength, "required": "%.1f" % current_level.required_strength})
		else:
			strength_label.text = "%.1f / %.1f" % [strength, current_level.required_strength]
		
		# 根据强度设置颜色反馈
		var color: Color
		if ratio >= 90.0:
			color = Color(0.2, 1.0, 0.2)  # 绿色（接近阈值）
		elif ratio >= 70.0:
			color = Color(1.0, 1.0, 0.2)  # 黄色
		else:
			color = Color(1.0, 0.4, 0.4)  # 红色（不足）
		
		tween.parallel().tween_property(strength_bar, "modulate", color, 0.3)
	else:
		strength_bar.value = 0.0
		if I18nManager:
			strength_label.text = I18nManager.translate("ui.game.strength_empty")
		else:
			strength_label.text = "0.0 / 0.0"

func _on_validate_pressed():
	var chain = _get_current_chain()
	
	if chain.size() < 2:
		if I18nManager:
			_show_error(I18nManager.translate("ui.game.error_min_nodes"))
		else:
			_show_error("请至少放置 2 个因果节点")
		return
	
	# 播放验证音效
	if AudioManager:
		AudioManager.play_validate()
	
	var validator = CausalValidator.new()
	var result = validator.validate_chain(chain, current_level)
	# 添加 required_strength 到结果中，供评分使用
	result["required_strength"] = current_level.required_strength
	
	# 检测共振
	var resonances = ResonanceDetector.detect_resonances(chain)
	result["resonances"] = resonances
	
	# 检测路径
	var path_info = PathAnalyzer.detect_path(chain, current_level)
	result["path_info"] = path_info
	
	# 应用加成（先路径，后共振）
	var base_strength = result.get("strength", 0.0)
	if path_info.get("matched", false):
		base_strength = PathAnalyzer.apply_path_bonus(base_strength, path_info)
		# 播放路径发现音效
		if path_info.get("is_new", false) and AudioManager:
			AudioManager.play_success()
	
	if not resonances.is_empty():
		result["strength"] = ResonanceDetector.apply_resonance_bonus(base_strength, resonances)
		# 播放共振解锁音效
		for resonance in resonances:
			if resonance.get("is_new", false) and AudioManager:
				AudioManager.play_success()  # 使用成功音效，后续可以添加专门的共振音效
	else:
		result["strength"] = base_strength
	
	var grade = validator.calculate_grade(chain, result)
	
	# 如果有错误，显示错误消息
	if not result.passed and result.has("errors") and not result.errors.is_empty():
		var error_msg = result.errors[0]  # 显示第一个错误
		if result.errors.size() > 1:
			error_msg += "（还有 %d 个问题）" % (result.errors.size() - 1)
		_show_error(error_msg)
		# 播放失败音效
		if AudioManager:
			AudioManager.play_fail()
	else:
		# 播放成功音效
		if AudioManager:
			AudioManager.play_success()
	
	# 保存结果（添加chain到result中供分享使用）
	result["chain"] = chain
	SaveGame.save_level_result(GameManager.current_level_id, grade, result.strength, chain)
	
	# 生成并保存世界线日志（仅在通过时）
	if result.passed and grade != "FAIL":
		var log_text = WorldLogGenerator.generate_world_log(chain, current_level, result)
		WorldLogGenerator.save_world_log(GameManager.current_level_id, chain, log_text)
	
	# 显示结果面板
	result_panel.show_result(result, grade)
	
	# 连接结果面板信号
	if not result_panel.next_level_pressed.is_connected(_on_result_next_level):
		result_panel.next_level_pressed.connect(_on_result_next_level)
	if not result_panel.retry_pressed.is_connected(_on_result_retry):
		result_panel.retry_pressed.connect(_on_result_retry)

func _on_result_next_level():
	# 加载下一关
	var next_level_id = GameManager.current_level_id + 1
	if next_level_id <= 3:
		GameManager.load_level(next_level_id)
		current_level = GameManager.current_level
		_setup_level()
		# 清空当前链
		for slot in chain_slots:
			slot.remove_card()
	else:
		# 所有关卡完成，返回关卡选择
		get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")

func _on_result_retry():
	# 重新挑战当前关卡
	for slot in chain_slots:
		slot.remove_card()
	_update_strength_bar()

func _on_clear_pressed():
	for slot in chain_slots:
		slot.remove_card()
	UndoRedoManager.clear()  # 清空撤销/重做历史
	_update_strength_bar()

func _show_error(message: String):
	print("错误：", message)
	if error_toast:
		error_toast.show_error(message)

func _input(event: InputEvent):
	# 处理撤销/重做快捷键
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Z and (event.ctrl_pressed or event.meta_pressed):
			_undo()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_Y and (event.ctrl_pressed or event.meta_pressed):
			_redo()
			get_viewport().set_input_as_handled()

func _undo():
	if not UndoRedoManager.can_undo():
		return
	
	is_undoing_redoing = true
	var action = UndoRedoManager.undo()
	if not action:
		is_undoing_redoing = false
		return
	
	match action.action_type:
		UndoRedoManager.ActionType.PLACE:
			# 撤销放置：移除卡片
			if action.slot_index < chain_slots.size():
				var slot = chain_slots[action.slot_index]
				if slot.current_card:
					slot.remove_card()
		UndoRedoManager.ActionType.REMOVE:
			# 撤销移除：恢复卡片
			if action.slot_index < chain_slots.size():
				var slot = chain_slots[action.slot_index]
				# 查找对应的卡片
				var card = _find_card_by_id(action.card_id)
				if card and not card.is_used:
					slot.place_card(card)
	
	is_undoing_redoing = false
	_update_strength_bar()

func _redo():
	if not UndoRedoManager.can_redo():
		return
	
	is_undoing_redoing = true
	var action = UndoRedoManager.redo()
	if not action:
		is_undoing_redoing = false
		return
	
	match action.action_type:
		UndoRedoManager.ActionType.PLACE:
			# 重做放置：恢复卡片
			if action.slot_index < chain_slots.size():
				var slot = chain_slots[action.slot_index]
				var card = _find_card_by_id(action.card_id)
				if card and not card.is_used:
					slot.place_card(card)
		UndoRedoManager.ActionType.REMOVE:
			# 重做移除：移除卡片
			if action.slot_index < chain_slots.size():
				var slot = chain_slots[action.slot_index]
				if slot.current_card:
					slot.remove_card()
	
	is_undoing_redoing = false
	_update_strength_bar()

func _find_card_by_id(card_id: String) -> CauseCard:
	for child in candidate_grid.get_children():
		if child is CauseCard:
			var card = child as CauseCard
			if card.cause_data and card.cause_data.id == card_id:
				return card
	return null
