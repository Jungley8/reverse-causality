extends Control

## 错误提示Toast系统
## 从屏幕顶部滑入，显示错误信息，3秒后自动消失

@onready var message_label = $Panel/MessageLabel
@onready var animation_player = $AnimationPlayer

var tween: Tween = null

func _ready():
	visible = false

## 显示错误消息
func show_error(message: String, duration: float = 3.0):
	message_label.text = message
	visible = true
	
	# 停止之前的动画
	if tween:
		tween.kill()
	
	# 创建滑入动画
	tween = create_tween()
	tween.set_parallel(true)
	
	# 从顶部滑入
	var start_pos = Vector2(position.x, -size.y)
	var end_pos = position
	position = start_pos
	tween.tween_property(self, "position", end_pos, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# 淡入
	modulate.a = 0.0
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	
	# 等待指定时间后滑出
	await get_tree().create_timer(duration).timeout
	
	# 滑出动画
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", start_pos, 0.3).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	
	await tween.finished
	visible = false
