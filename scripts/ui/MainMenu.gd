extends Control

## 主菜单控制器

@onready var continue_btn = $MenuButtons/ContinueButton
@onready var start_button = $MenuButtons/StartButton
@onready var archive_button = $MenuButtons/ArchiveButton
@onready var game_title = $TitleContainer/GameTitle
@onready var subtitle = $TitleContainer/Subtitle

func _ready():
	# 检查是否有存档
	if not SaveGame.has_save():
		continue_btn.disabled = true
		continue_btn.modulate = Color(0.5, 0.5, 0.5)
	
	# 应用主题样式
	_apply_theme()
	
	# 更新UI文本
	_update_ui_text()
	
	# 监听语言变化
	if I18nManager:
		I18nManager.language_changed.connect(_on_language_changed)

func _apply_theme():
	ThemeManager.apply_theme_to_button(start_button)
	ThemeManager.apply_theme_to_button(continue_btn)
	ThemeManager.apply_theme_to_button(archive_button)
	
	if game_title:
		ThemeManager.apply_theme_to_label(game_title)
	if subtitle:
		ThemeManager.apply_theme_to_label(subtitle)

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
