extends Control

## 主菜单控制器

@onready var continue_btn = $MenuButtons/ContinueButton
@onready var start_button = $MenuButtons/StartButton
@onready var archive_button = $MenuButtons/ArchiveButton

func _ready():
	# 检查是否有存档
	if not SaveGame.has_save():
		continue_btn.disabled = true
		continue_btn.modulate = Color(0.5, 0.5, 0.5)

func _on_start_pressed():
	SaveGame.reset_progress()
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")

func _on_archive_pressed():
	# 暂时跳转到关卡选择（因果图鉴功能在P2实现）
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")
