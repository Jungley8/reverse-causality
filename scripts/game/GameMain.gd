extends Control

## 游戏主界面控制器
## 管理游戏主界面的所有逻辑

var current_level: LevelData
var current_dragging_card: CauseCard = null
var chain_slots: Array[ChainSlot] = []

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

func _ready():
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
	level_label.text = "关卡 %02d" % GameManager.current_level_id
	
	# 设置结果卡片
	var result_node = _find_node_by_id(current_level.result_id, current_level.candidates)
	if result_node:
		result_card.text = result_node.label
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
		
		# 添加箭头
		var arrow = Label.new()
		arrow.text = "→"
		arrow.add_theme_font_size_override("font_size", 24)
		arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		chain_slots_container.add_child(arrow)
	
	# 添加结果节点显示（固定）
	var result_slot = Label.new()
	result_slot.text = "结果"
	result_slot.add_theme_font_size_override("font_size", 16)
	result_slot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_slot.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
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
	_update_strength_bar()

func _on_card_removed(slot: ChainSlot):
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
		strength_bar.value = clamp(ratio, 0.0, 100.0)
		strength_label.text = "%.1f / %.1f" % [strength, current_level.required_strength]
	else:
		strength_bar.value = 0.0
		strength_label.text = "0.0 / 0.0"

func _on_validate_pressed():
	var chain = _get_current_chain()
	
	if chain.size() < 2:
		_show_error("请至少放置 2 个因果节点")
		return
	
	var validator = CausalValidator.new()
	var result = validator.validate_chain(chain, current_level)
	# 添加 required_strength 到结果中，供评分使用
	result["required_strength"] = current_level.required_strength
	var grade = validator.calculate_grade(chain, result)
	
	# 保存结果
	SaveGame.save_level_result(GameManager.current_level_id, grade, result.strength, chain)
	
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
	_update_strength_bar()

func _show_error(message: String):
	print("错误：", message)
	# 可以添加错误提示UI
