extends Control

## 错误提示Toast系统
## 从屏幕顶部滑入，显示错误信息，3秒后自动消失

@onready var message_label = $Panel/MessageLabel
@onready var animation_player = $AnimationPlayer

var tween: Tween = null

func _ready():
	visible = false

## 显示错误消息（红色）
func show_error(message: String, duration: float = 3.0):
	_show_message(message, true, duration)

## 显示成功消息（绿色）
func show_success(message: String, duration: float = 3.0):
	_show_message(message, false, duration)

func _show_message(message: String, is_error: bool, duration: float):
	message_label.text = message
	var panel = $Panel
	if panel is Panel:
		panel.add_theme_color_override("bg_color", Color(0.8, 0.2, 0.2, 0.95) if is_error else Color(0.2, 0.7, 0.3, 0.95))
	visible = true

	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	var start_pos = Vector2(position.x, -size.y)
	var end_pos = position
	position = start_pos
	tween.tween_property(self, "position", end_pos, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	modulate.a = 0.0
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

	await get_tree().create_timer(duration).timeout
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", start_pos, 0.3).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	visible = false
