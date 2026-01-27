class_name LevelCard
extends PanelContainer

## 关卡卡片组件

signal level_selected(level_id: int)

@export var level_id: int = 1
@export var level_title: String = ""
@export var is_locked: bool = true

@onready var status_icon = $VBox/StatusIcon
@onready var grade_label = $VBox/GradeLabel
@onready var title_label = $VBox/TitleLabel
@onready var level_id_label = $VBox/LevelIdLabel

func _ready():
	_update_visuals()

func _update_visuals():
	level_id_label.text = "%02d" % level_id
	title_label.text = level_title
	
	if is_locked:
		modulate = Color(0.4, 0.4, 0.4)
		status_icon.text = "🔒"
		grade_label.text = ""
		mouse_filter = MOUSE_FILTER_IGNORE
	else:
		modulate = Color.WHITE
		var grade = SaveGame.get_level_grade(level_id)
		if grade:
			status_icon.text = "✓"
			grade_label.text = grade + "级"
		else:
			status_icon.text = "○"
			grade_label.text = "未完成"
		mouse_filter = MOUSE_FILTER_STOP

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if not is_locked:
			level_selected.emit(level_id)
