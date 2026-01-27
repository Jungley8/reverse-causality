extends Control

## 关卡选择界面控制器

var current_level_id: int = 1

@onready var level_grid = $LevelGrid
@onready var back_button = $Header/BackButton

func _ready():
	_load_level_states()
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

func _load_level_states():
	var completed_levels = SaveGame.get_completed_levels()
	
	# 创建3个关卡卡片
	for i in range(3):
		var level_id = i + 1
		var card_scene = preload("res://scenes/components/LevelCard.tscn")
		var card = card_scene.instantiate() as LevelCard
		card.level_id = level_id
		card.level_title = _get_level_title(level_id)
		
		# 关卡1默认解锁，后续关卡需要前一关B级以上
		if level_id == 1:
			card.is_locked = false
		else:
			var prev_grade = SaveGame.get_level_grade(level_id - 1)
			card.is_locked = not (prev_grade in ["B", "A", "S"])
		
		card.level_selected.connect(_on_level_selected)
		level_grid.add_child(card)

func _get_level_title(level_id: int) -> String:
	match level_id:
		1: return "城市崩溃"
		2: return "AI禁令"
		3: return "法律人格"
		_: return "关卡 %d" % level_id

func _on_level_selected(level_id: int):
	current_level_id = level_id
	GameManager.load_level(level_id)
	get_tree().change_scene_to_file("res://scenes/game/GameMain.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
