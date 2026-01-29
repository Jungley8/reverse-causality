extends Control

## 完整因果图鉴UI
## 支持标签页切换：关卡 / 共振 / 世界线

enum TabType {
	LEVELS,
	RESONANCES,
	WORLD_LOGS
}

var current_tab: TabType = TabType.LEVELS

@onready var back_button = $Header/BackButton
@onready var tab_container = $TabContainer
@onready var levels_tab = $TabContainer/Levels
@onready var resonances_tab = $TabContainer/Resonances
@onready var world_logs_tab = $TabContainer/WorldLogs

func _ready():
	# 初始化并应用主题
	ThemeManager.initialize()
	ThemeManager.apply_theme_to_scene(self)
	
	# 设置背景色
	var background = get_node_or_null("Background")
	if background and background is ColorRect:
		background.color = ThemeManager.get_color("background")
	
	# 为按钮设置主题类型
	if back_button:
		back_button.theme_type_variation = "ButtonSecondary"
		back_button.pressed.connect(_on_back_pressed)
	
	if tab_container:
		tab_container.tab_changed.connect(_on_tab_changed)
	
	# 更新UI文本
	_update_ui_text()
	
	# 监听语言变化
	I18nManager.language_changed.connect(_on_language_changed)

func _update_ui_text():
	if back_button:
		back_button.text = I18nManager.translate("ui.archive.back")
	
	# 更新标签页名称（如果tab_container支持）
	if tab_container:
		tab_container.set_tab_title(0, I18nManager.translate("ui.archive.levels"))
		tab_container.set_tab_title(1, I18nManager.translate("ui.archive.resonances"))
		tab_container.set_tab_title(2, I18nManager.translate("ui.archive.world_logs"))

func _on_language_changed(_language: String):
	_update_ui_text()
	_load_current_tab()

func _on_tab_changed(tab_index: int):
	current_tab = tab_index as TabType
	_load_current_tab()

func _load_current_tab():
	match current_tab:
		TabType.LEVELS:
			_load_levels_tab()
		TabType.RESONANCES:
			_load_resonances_tab()
		TabType.WORLD_LOGS:
			_load_world_logs_tab()

## 加载关卡标签页
func _load_levels_tab():
	var scroll_container = levels_tab.get_node_or_null("ScrollContainer")
	if not scroll_container:
		# 创建滚动容器
		scroll_container = ScrollContainer.new()
		scroll_container.name = "ScrollContainer"
		scroll_container.set_anchors_preset(Control.PRESET_FULL_RECT)
		levels_tab.add_child(scroll_container)
		
		var vbox = VBoxContainer.new()
		vbox.name = "VBox"
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll_container.add_child(vbox)
	
	var vbox = scroll_container.get_node("VBox")
	
	# 清除现有内容
	for child in vbox.get_children():
		child.queue_free()
	
	# 获取所有已完成的关卡
	var level_progress = SaveGame.save_data.get("level_progress", {})
	
	if level_progress.is_empty():
		var empty_label = Label.new()
		empty_label.text = I18nManager.translate("ui.archive.no_levels")
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(empty_label)
		return
	
	# 按关卡ID排序
	var level_ids = []
	for level_id_str in level_progress.keys():
		level_ids.append(int(level_id_str))
	level_ids.sort()
	
	# 为每个关卡创建条目
	for level_id in level_ids:
		var level_data = level_progress[str(level_id)]
		_create_level_entry(vbox, level_id, level_data)

func _create_level_entry(parent: Control, level_id: int, level_data: Dictionary):
	var entry = PanelContainer.new()
	entry.custom_minimum_size = Vector2(0, 140)
	
	var vbox = VBoxContainer.new()
	entry.add_child(vbox)
	
	# 标题行
	var title_row = HBoxContainer.new()
	var title_label = Label.new()
	title_label.text = I18nManager.translate("ui.archive.level") + " %02d" % level_id
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var grade_label = Label.new()
	var default_grade = I18nManager.translate("ui.level_card.not_completed")
	grade_label.text = level_data.get("grade", default_grade)
	grade_label.add_theme_font_size_override("font_size", 18)
	grade_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	title_row.add_child(title_label)
	title_row.add_child(grade_label)
	vbox.add_child(title_row)
	
	# 最佳因果链
	var chain_label = Label.new()
	chain_label.text = I18nManager.translate("ui.archive.best_chain")
	chain_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(chain_label)
	
	var chain_text = Label.new()
	var best_chain = level_data.get("best_chain", [])
	if best_chain.is_empty():
		chain_text.text = "无"  # 这个可以保持，因为"无"在两种语言中都简单
	else:
		var chain_labels = _convert_chain_ids_to_labels(level_id, best_chain)
		chain_text.text = " → ".join(chain_labels)
	chain_text.add_theme_font_size_override("font_size", 12)
	chain_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(chain_text)
	
	# 发现的路径
	var discovered_paths = SaveGame.get_discovered_paths(level_id)
	if not discovered_paths.is_empty():
		var paths_label = Label.new()
		var separator = "、" if I18nManager.get_current_language() == "zh_CN" else ", "
		paths_label.text = I18nManager.translate("ui.archive.discovered_paths") + separator.join(discovered_paths)
		paths_label.add_theme_font_size_override("font_size", 12)
		paths_label.modulate = Color(0.8, 0.8, 1.0)
		vbox.add_child(paths_label)
	
	# 完成时间
	var time_label = Label.new()
	var completed_time = level_data.get("completed_time", 0)
	if completed_time > 0:
		var time_dict = Time.get_datetime_dict_from_unix_time(completed_time)
		time_label.text = I18nManager.translate("ui.archive.completed_time") + "%04d-%02d-%02d %02d:%02d" % [
			time_dict.year, time_dict.month, time_dict.day,
			time_dict.hour, time_dict.minute
		]
	else:
		time_label.text = I18nManager.translate("ui.archive.completed_time") + I18nManager.translate("ui.archive.unknown_time")
	time_label.add_theme_font_size_override("font_size", 12)
	time_label.modulate = Color(0.7, 0.7, 0.7)
	vbox.add_child(time_label)
	
	parent.add_child(entry)

func _convert_chain_ids_to_labels(level_id: int, chain_ids: Array) -> Array[String]:
	var labels: Array[String] = []
	
	var level_path = "res://data/levels/level_%02d.tres" % level_id
	if not ResourceLoader.exists(level_path):
		return chain_ids
	
	var level_data = load(level_path) as LevelData
	if not level_data:
		return chain_ids
	
	var id_to_label = {}
	for candidate in level_data.candidates:
		id_to_label[candidate.id] = candidate.label
	
	for node_id in chain_ids:
		if id_to_label.has(node_id):
			labels.append(id_to_label[node_id])
		else:
			labels.append(node_id)
	
	return labels

## 加载共振标签页
func _load_resonances_tab():
	var scroll_container = resonances_tab.get_node_or_null("ScrollContainer")
	if not scroll_container:
		scroll_container = ScrollContainer.new()
		scroll_container.name = "ScrollContainer"
		scroll_container.set_anchors_preset(Control.PRESET_FULL_RECT)
		resonances_tab.add_child(scroll_container)
		
		var vbox = VBoxContainer.new()
		vbox.name = "VBox"
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll_container.add_child(vbox)
	
	var vbox = scroll_container.get_node("VBox")
	
	# 清除现有内容
	for child in vbox.get_children():
		child.queue_free()
	
	# 获取已解锁的共振
	var unlocked_ids = SaveGame.get_unlocked_resonances()
	
	if unlocked_ids.is_empty():
		var empty_label = Label.new()
		empty_label.text = I18nManager.translate("ui.archive.no_resonances")
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(empty_label)
		return
	
	# 获取所有共振模式
	var all_patterns = ResonanceDatabase.get_all_patterns()
	
	# 显示已解锁的共振
	for pattern in all_patterns:
		if pattern.id in unlocked_ids:
			_create_resonance_entry(vbox, pattern)

func _create_resonance_entry(parent: Control, pattern: ResonanceDatabase.ResonancePattern):
	var entry = PanelContainer.new()
	entry.custom_minimum_size = Vector2(0, 100)
	
	var vbox = VBoxContainer.new()
	entry.add_child(vbox)
	
	# 名称
	var name_label = Label.new()
	name_label.text = "✨ " + pattern.name
	name_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(name_label)
	
	# 描述
	var desc_label = Label.new()
	desc_label.text = pattern.description
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.modulate = Color(0.8, 0.8, 0.8)
	vbox.add_child(desc_label)
	
	# 加成信息
	var bonus_label = Label.new()
	bonus_label.text = I18nManager.translate("ui.archive.bonus_multiplier", {"value": "%.1f" % pattern.bonus_multiplier})
	bonus_label.add_theme_font_size_override("font_size", 12)
	bonus_label.modulate = Color(0.7, 0.9, 0.7)
	vbox.add_child(bonus_label)
	
	parent.add_child(entry)

## 加载世界线日志标签页
func _load_world_logs_tab():
	var scroll_container = world_logs_tab.get_node_or_null("ScrollContainer")
	if not scroll_container:
		scroll_container = ScrollContainer.new()
		scroll_container.name = "ScrollContainer"
		scroll_container.set_anchors_preset(Control.PRESET_FULL_RECT)
		world_logs_tab.add_child(scroll_container)
		
		var vbox = VBoxContainer.new()
		vbox.name = "VBox"
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll_container.add_child(vbox)
	
	var vbox = scroll_container.get_node("VBox")
	
	# 清除现有内容
	for child in vbox.get_children():
		child.queue_free()
	
	# 获取所有世界线日志
	var logs = SaveGame.get_world_logs()
	
	if logs.is_empty():
		var empty_label = Label.new()
		empty_label.text = I18nManager.translate("ui.archive.no_logs")
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(empty_label)
		return
	
	# 按时间倒序排序（最新的在前）
	logs.sort_custom(func(a, b): return a.get("timestamp", 0) > b.get("timestamp", 0))
	
	# 显示日志
	for log_entry in logs:
		_create_world_log_entry(vbox, log_entry)

func _create_world_log_entry(parent: Control, log_entry: Dictionary):
	var entry = PanelContainer.new()
	entry.custom_minimum_size = Vector2(0, 150)
	
	var vbox = VBoxContainer.new()
	entry.add_child(vbox)
	
	# 关卡信息
	var level_label = Label.new()
	level_label.text = I18nManager.translate("ui.archive.level") + " %02d" % log_entry.get("level_id", 0)
	level_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(level_label)
	
	# 日志文本
	var log_text = RichTextLabel.new()
	log_text.text = log_entry.get("log_text", "")
	log_text.custom_minimum_size = Vector2(0, 100)
	log_text.scroll_active = false
	log_text.bbcode_enabled = false
	vbox.add_child(log_text)
	
	# 时间戳
	var time_label = Label.new()
	var timestamp = log_entry.get("timestamp", 0)
	if timestamp > 0:
		var time_dict = Time.get_datetime_dict_from_unix_time(timestamp)
		time_label.text = "%04d-%02d-%02d %02d:%02d" % [
			time_dict.year, time_dict.month, time_dict.day,
			time_dict.hour, time_dict.minute
		]
	else:
		time_label.text = I18nManager.translate("ui.archive.unknown_time")
	time_label.add_theme_font_size_override("font_size", 12)
	time_label.modulate = Color(0.7, 0.7, 0.7)
	vbox.add_child(time_label)
	
	parent.add_child(entry)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
