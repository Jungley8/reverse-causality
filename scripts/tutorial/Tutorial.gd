extends Control

## 首次引导教程系统
## 分步骤引导玩家学习游戏玩法

enum TutorialStep {
	INTRO,           # 介绍游戏目标
	DRAG_CARD,       # 教拖拽
	PLACE_CARD,      # 教放置
	BUILD_CHAIN,     # 教构建链
	VALIDATE,        # 教验证
	UNDERSTAND_RESULT, # 解读结果
	COMPLETE
}

var current_step = TutorialStep.INTRO
var highlight_overlay: ColorRect = null
var highlighted_element: Control = null
var tutorial_game_main: Node = null

@onready var message_panel = $MessagePanel
@onready var message_title = $MessagePanel/VBox/TitleLabel
@onready var message_text = $MessagePanel/VBox/TextLabel
@onready var continue_button = $MessagePanel/VBox/ContinueButton
@onready var skip_button = $MessagePanel/VBox/SkipButton

func _ready():
	# 加载游戏主界面作为教程背景
	var game_main_scene = preload("res://scenes/game/GameMain.tscn")
	tutorial_game_main = game_main_scene.instantiate()
	add_child(tutorial_game_main)
	move_child(tutorial_game_main, 0)  # 移到最底层
	
	# 连接按钮信号
	continue_button.pressed.connect(_on_continue_pressed)
	skip_button.pressed.connect(_on_skip_pressed)
	
	# 连接游戏主界面的信号以检测玩家操作
	_connect_game_signals()
	
	# 显示第一步
	_show_step(current_step)

func _connect_game_signals():
	# 等待一帧确保节点已准备好
	await get_tree().process_frame
	
	if not tutorial_game_main:
		return
	
	# 连接卡片拖拽信号
	var candidate_grid = tutorial_game_main.get_node_or_null("CandidateArea/CandidateGrid")
	if candidate_grid:
		for card in candidate_grid.get_children():
			if card.has_signal("drag_started"):
				if not card.drag_started.is_connected(_on_card_drag_started):
					card.drag_started.connect(_on_card_drag_started)
			if card.has_signal("drag_ended"):
				if not card.drag_ended.is_connected(_on_card_drag_ended):
					card.drag_ended.connect(_on_card_drag_ended)
	
	# 连接槽位信号
	var chain_slots_container = tutorial_game_main.get_node_or_null("ChainArea/ChainSlots")
	if chain_slots_container:
		for slot in chain_slots_container.get_children():
			if slot.has_signal("card_placed"):
				if not slot.card_placed.is_connected(_on_card_placed):
					slot.card_placed.connect(_on_card_placed)
	
	# 连接验证按钮
	var validate_button = tutorial_game_main.get_node_or_null("ActionButtons/ValidateButton")
	if validate_button:
		if not validate_button.pressed.is_connected(_on_validate_pressed):
			validate_button.pressed.connect(_on_validate_pressed)

func _show_step(step: TutorialStep):
	current_step = step
	
	match step:
		TutorialStep.INTRO:
			_show_message(
				"欢迎来到《逆果溯因》",
				"你需要从给定的结果，构建一条合理的因果链。\n\n点击继续开始教程..."
			)
			_remove_highlight()
		
		TutorialStep.DRAG_CARD:
			_show_message(
				"拖拽节点",
				"点击并拖拽下方的节点卡片到上方的槽位中"
			)
			await get_tree().process_frame
			var candidate_grid = tutorial_game_main.get_node_or_null("CandidateArea/CandidateGrid")
			if candidate_grid and candidate_grid.get_child_count() > 0:
				var first_card = candidate_grid.get_child(0)
				_highlight_element(first_card)
		
		TutorialStep.PLACE_CARD:
			_show_message(
				"放置节点",
				"将节点拖拽到第一个槽位，然后松开鼠标完成放置"
			)
			await get_tree().process_frame
			var chain_slots = tutorial_game_main.get_node_or_null("ChainArea/ChainSlots")
			if chain_slots:
				# 找到第一个槽位（跳过箭头）
				for child in chain_slots.get_children():
					if child.has_method("place_card"):
						_highlight_element(child)
						break
		
		TutorialStep.BUILD_CHAIN:
			_show_message(
				"构建因果链",
				"继续拖拽更多节点，组成一条完整的因果链\n至少需要 2 个节点才能验证"
			)
			_remove_highlight()
		
		TutorialStep.VALIDATE:
			_show_message(
				"验证结果",
				"当你构建好因果链后，点击\"验证\"按钮检查你的因果链是否成立"
			)
			await get_tree().process_frame
			var validate_button = tutorial_game_main.get_node_or_null("ActionButtons/ValidateButton")
			if validate_button:
				_highlight_element(validate_button)
		
		TutorialStep.UNDERSTAND_RESULT:
			_show_message(
				"理解反馈",
				"系统会告诉你：\n• 因果是否成立\n• 逻辑强度如何\n• 是否存在问题"
			)
			_remove_highlight()
		
		TutorialStep.COMPLETE:
			_show_message(
				"教程完成！",
				"现在你可以挑战正式关卡了"
			)
			_remove_highlight()
			# 保存教程完成状态
			if not SaveGame.save_data.has("tutorial_completed"):
				SaveGame.save_data["tutorial_completed"] = false
			SaveGame.save_data["tutorial_completed"] = true
			SaveGame.save_game()
			continue_button.text = "开始游戏"

func _show_message(title: String, text: String):
	message_title.text = title
	message_text.text = text
	message_panel.visible = true

func _highlight_element(element: Control):
	if not element:
		return
	
	_remove_highlight()
	highlighted_element = element
	
	# 等待一帧确保元素位置已更新
	await get_tree().process_frame
	
	# 创建高亮覆盖层
	highlight_overlay = ColorRect.new()
	highlight_overlay.color = Color(1.0, 1.0, 0.0, 0.3)  # 半透明黄色
	highlight_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# 获取元素在屏幕上的全局位置和大小
	var element_global = element.get_global_rect()
	var tutorial_global = get_global_rect()
	
	# 计算相对于教程场景的位置
	highlight_overlay.position = element_global.position - tutorial_global.position
	highlight_overlay.size = element_global.size
	
	add_child(highlight_overlay)
	move_child(highlight_overlay, get_child_count() - 2)  # 移到消息面板之前

func _remove_highlight():
	if highlight_overlay:
		highlight_overlay.queue_free()
		highlight_overlay = null
	highlighted_element = null

func _on_continue_pressed():
	match current_step:
		TutorialStep.INTRO:
			_next_step()
		TutorialStep.DRAG_CARD:
			# 等待玩家拖拽
			pass
		TutorialStep.PLACE_CARD:
			# 等待玩家放置
			pass
		TutorialStep.BUILD_CHAIN:
			# 等待玩家构建链
			pass
		TutorialStep.VALIDATE:
			# 等待玩家点击验证
			pass
		TutorialStep.UNDERSTAND_RESULT:
			_next_step()
		TutorialStep.COMPLETE:
			# 跳转到关卡选择
			get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")

func _on_skip_pressed():
	# 标记教程为完成
	if not SaveGame.save_data.has("tutorial_completed"):
		SaveGame.save_data["tutorial_completed"] = false
	SaveGame.save_data["tutorial_completed"] = true
	SaveGame.save_game()
	
	# 跳转到关卡选择
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")

func _next_step():
	var next_step_value = current_step + 1
	if next_step_value <= TutorialStep.COMPLETE:
		current_step = next_step_value as TutorialStep
		_show_step(current_step)

func _on_card_drag_started(_card):
	if current_step == TutorialStep.DRAG_CARD:
		_next_step()

func _on_card_drag_ended(_card):
	pass

func _on_card_placed(_slot, _card):
	if current_step == TutorialStep.PLACE_CARD:
		_next_step()
	elif current_step == TutorialStep.BUILD_CHAIN:
		# 检查是否已放置至少2个节点
		var chain_slots = tutorial_game_main.get_node_or_null("ChainArea/ChainSlots")
		if chain_slots:
			var placed_count = 0
			for slot in chain_slots.get_children():
				if slot.has_method("place_card") and slot.current_card:
					placed_count += 1
			if placed_count >= 2:
				_next_step()

func _on_validate_pressed():
	if current_step == TutorialStep.VALIDATE:
		# 等待验证结果
		await get_tree().create_timer(1.0).timeout
		_next_step()
