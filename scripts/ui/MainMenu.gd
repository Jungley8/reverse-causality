extends Control

## 主菜单控制器

@onready var continue_btn = $MenuButtons/ContinueButton
@onready var start_button = $MenuButtons/StartButton
@onready var archive_button = $MenuButtons/ArchiveButton
@onready var game_title = $TitleContainer/GameTitle
@onready var subtitle = $TitleContainer/Subtitle

func _ready():
	# 初始化并应用主题
	ThemeManager.initialize()
	ThemeManager.apply_theme_to_scene(self)
	
	# 设置背景色
	var background = get_node_or_null("Background")
	if background and background is ColorRect:
		background.color = ThemeManager.get_color("background")
	
	# 为按钮设置主题类型
	if start_button:
		start_button.theme_type_variation = "ButtonPrimary"
	if continue_btn:
		continue_btn.theme_type_variation = "ButtonSecondary"
	if archive_button:
		archive_button.theme_type_variation = "ButtonSecondary"
	
	# 为标题设置主题类型
	if game_title:
		game_title.theme_type_variation = "LabelH1"
	if subtitle:
		subtitle.theme_type_variation = "LabelH2"
	
	# 检查是否有存档
	if not SaveGame.has_save():
		continue_btn.disabled = true
		continue_btn.modulate = Color(0.5, 0.5, 0.5)
	
	# 更新UI文本
	_update_ui_text()
	
	# 监听语言变化
	if I18nManager:
		I18nManager.language_changed.connect(_on_language_changed)

func _update_ui_text():
	if not I18nManager:
		return
	
	if start_button:
		start_button.text = I18nManager.translate("ui.main_menu.start_game")
	if continue_btn:
		continue_btn.text = I18nManager.translate("ui.main_menu.continue_game")
	if archive_button:
		archive_button.text = I18nManager.translate("ui.main_menu.archive")
	if game_title:
		game_title.text = I18nManager.translate("ui.main_menu.title")
	if subtitle:
		subtitle.text = I18nManager.translate("ui.main_menu.subtitle")

func _on_language_changed(_language: String):
	_update_ui_text()

func _on_start_pressed():
	SaveGame.reset_progress()
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")

func _on_archive_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/Archive.tscn")
