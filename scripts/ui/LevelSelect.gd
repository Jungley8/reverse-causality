extends Control

## 关卡选择界面控制器

var current_level_id: int = 1
var previous_unlock_states: Dictionary = {}  # 记录之前的解锁状态

@onready var level_grid = $LevelGrid
@onready var back_button = $Header/BackButton
@onready var title_label = $Header/Title

func _ready():
	# 初始化并应用主题
	ThemeManager.initialize()
	ThemeManager.apply_theme_to_scene(self)
	
	# 设置背景色
	var background = get_node_or_null("Background")
	if background and background is ColorRect:
		background.color = ThemeManager.get_color("background")
	
	# 为按钮和标签设置主题类型
	if back_button:
		back_button.theme_type_variation = "ButtonSecondary"
	if title_label:
		title_label.theme_type_variation = "LabelH2"
	
	# 检查是否需要显示教程
	if not SaveGame.save_data.get("tutorial_completed", false):
		get_tree().change_scene_to_file("res://scenes/tutorial/Tutorial.tscn")
		return
	
	# 更新UI文本
	_update_ui_text()
	
	# 监听语言变化
	if I18nManager:
		I18nManager.language_changed.connect(_on_language_changed)
	
	# 加载之前的解锁状态（用于检测新解锁）
	_load_previous_unlock_states()
	
	_load_level_states()
	if back_button:
		if not back_button.pressed.is_connected(_on_back_pressed):
			back_button.pressed.connect(_on_back_pressed)

func _update_ui_text():
	if not I18nManager:
		return
	
	if back_button:
		back_button.text = I18nManager.translate("ui.level_select.back")
	if title_label:
		title_label.text = I18nManager.translate("ui.level_select.title")

func _on_language_changed(_language: String):
	_update_ui_text()
	# 重新加载关卡状态以更新标题
	_load_level_states()

func _load_previous_unlock_states():
	# 从SaveGame读取之前的解锁状态
	for i in range(3):
		var level_id = i + 1
		var was_unlocked = false
		if level_id == 1:
			was_unlocked = true
		else:
			var prev_grade = SaveGame.get_level_grade(level_id - 1)
			was_unlocked = (prev_grade in ["B", "A", "S"])
		previous_unlock_states[level_id] = was_unlocked

func _load_level_states():
	var completed_levels = SaveGame.get_completed_levels()
	
	# 创建3个基础关卡卡片
	for i in range(3):
		var level_id = i + 1
		var card_scene = preload("res://scenes/components/LevelCard.tscn")
		var card = card_scene.instantiate() as LevelCard
		card.level_id = level_id
		card.level_title = _get_level_title(level_id)
		
		# 关卡1默认解锁，后续关卡需要前一关B级以上
		var was_locked = true
		if level_id == 1:
			was_locked = false
		else:
			var prev_grade = SaveGame.get_level_grade(level_id - 1)
			was_locked = not (prev_grade in ["B", "A", "S"])
		
		card.is_locked = was_locked
		
		# 检测新解锁的关卡
		var was_unlocked_before = previous_unlock_states.get(level_id, false)
		if was_locked == false and was_unlocked_before == false and level_id > 1:
			# 新解锁的关卡，播放动画
			card.play_unlock_animation()
			# 显示解锁提示（可选）
			_show_unlock_notification(level_id)
		
		card.level_selected.connect(_on_level_selected)
		level_grid.add_child(card)
	
	# 检查并显示隐藏关卡
	if _can_unlock_hidden_level():
		var hidden_card_scene = preload("res://scenes/components/LevelCard.tscn")
		var hidden_card = hidden_card_scene.instantiate() as LevelCard
		hidden_card.level_id = 101  # 使用101作为隐藏关卡ID
		hidden_card.level_title = I18nManager.translate("levels.level_hidden_01") if I18nManager else "隐藏关卡：因果迷宫"
		hidden_card.is_locked = false
		hidden_card.modulate = Color(1.0, 0.9, 0.7)  # 金色调
		hidden_card.level_selected.connect(_on_level_selected)
		level_grid.add_child(hidden_card)

func _show_unlock_notification(level_id: int):
	# 简单的控制台提示，可以扩展为UI提示
	print("新关卡解锁：关卡 %02d" % level_id)

func _get_level_title(level_id: int) -> String:
	if not I18nManager:
		match level_id:
			1: return "城市崩溃"
			2: return "AI禁令"
			3: return "法律人格"
			101: return "隐藏关卡：因果迷宫"
			_: return "关卡 %d" % level_id
	
	match level_id:
		1: return I18nManager.translate("levels.level_01")
		2: return I18nManager.translate("levels.level_02")
		3: return I18nManager.translate("levels.level_03")
		101: return I18nManager.translate("levels.level_hidden_01")
		_: return I18nManager.translate("ui.level_select.level") + " %d" % level_id

## 检查是否可以解锁隐藏关卡
func _can_unlock_hidden_level() -> bool:
	# 条件1：完成所有3个基础关卡
	var all_completed = true
	for i in range(1, 4):
		var grade = SaveGame.get_level_grade(i)
		if grade not in ["B", "A", "S"]:
			all_completed = false
			break
	
	if not all_completed:
		return false
	
	# 条件2：至少发现2个共振模式
	var unlocked_resonances = SaveGame.get_unlocked_resonances()
	if unlocked_resonances.size() < 2:
		return false
	
	# 条件3：至少发现1条隐藏路径
	var has_hidden_path = false
	for i in range(1, 4):
		var paths = SaveGame.get_discovered_paths(i)
		for path in paths:
			# 检查是否是隐藏路径（通过关卡数据判断，这里简化处理）
			if "隐藏" in path or "黑天鹅" in path:
				has_hidden_path = true
				break
		if has_hidden_path:
			break
	
	return has_hidden_path

func _on_level_selected(level_id: int):
	current_level_id = level_id
	# 隐藏关卡使用特殊ID
	if level_id == 101:
		GameManager.load_level_from_path("res://data/levels/level_hidden_01.tres")
	else:
		GameManager.load_level(level_id)
	get_tree().change_scene_to_file("res://scenes/game/GameMain.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
