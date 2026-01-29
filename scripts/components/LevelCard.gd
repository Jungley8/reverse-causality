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
		status_icon.text = I18nManager.translate("ui.level_card.locked")
		grade_label.text = ""
		mouse_filter = MOUSE_FILTER_IGNORE
	else:
		modulate = Color.WHITE
		var grade = SaveGame.get_level_grade(level_id)
		if grade:
			status_icon.text = I18nManager.translate("ui.level_card.completed")
			grade_label.text = I18nManager.translate("ui.level_card.grade", {"grade": grade})
		else:
			status_icon.text = I18nManager.translate("ui.level_card.incomplete")
			grade_label.text = I18nManager.translate("ui.level_card.not_completed")
		mouse_filter = MOUSE_FILTER_STOP

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if not is_locked:
			level_selected.emit(level_id)

## 播放解锁动画
func play_unlock_animation():
	# 播放解锁音效
	if AudioManager:
		AudioManager.play_unlock()
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 缩放动画：1.0 → 1.2 → 1.0
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.25).set_delay(0.25).set_ease(Tween.EASE_IN)
	
	# 旋转动画：0° → 360°
	tween.tween_property(self, "rotation_degrees", 360.0, 0.5).set_ease(Tween.EASE_OUT)
	
	# 恢复旋转
	await tween.finished
	rotation_degrees = 0.0

## 播放等级提升动画
func play_grade_up_animation():
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 缩放脉冲
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_delay(0.2).set_ease(Tween.EASE_IN)
	
	# 颜色闪烁（金色）
	var original_modulate = modulate
	tween.tween_property(self, "modulate", Color(1.0, 0.84, 0.0), 0.2)
	tween.tween_property(self, "modulate", original_modulate, 0.2).set_delay(0.2)
