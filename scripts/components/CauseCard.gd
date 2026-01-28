class_name CauseCard
extends PanelContainer

## 因果节点卡片组件
## 可拖拽的卡片，显示因果节点信息

signal drag_started(card: CauseCard)
signal drag_ended(card: CauseCard)

@export var cause_data: CauseNode
var is_dragging := false
var is_used := false
var original_position: Vector2

@onready var label = $MarginContainer/Label

func _ready():
	if cause_data:
		label.text = cause_data.label
		_update_visual()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _update_visual():
	if not cause_data:
		return
	
	# 创建基础样式
	var style = StyleBoxFlat.new()
	
	# 如果是干扰节点，使用偏红的背景色
	if cause_data.is_distractor:
		style.bg_color = Color(0.4, 0.2, 0.2)  # 偏红色背景
		style.border_color = ThemeManager.get_color("error")
	else:
		# 正常节点使用深色背景
		style.bg_color = Color(0.15, 0.18, 0.22)  # 深灰蓝色
		style.border_color = Color(0.3, 0.35, 0.4)  # 浅灰蓝色边框
	
	# 添加边框和圆角
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	
	# 添加轻微阴影效果（通过边框模拟）
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 2
	
	add_theme_stylebox_override("panel", style)
	
	# 应用文本颜色
	if label:
		label.add_theme_color_override("font_color", ThemeManager.get_color("text_primary"))

func _on_mouse_entered():
	if not is_used and not is_dragging:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)

func _on_mouse_exited():
	if not is_dragging:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2.ONE, 0.1)

## 开始拖拽
func _get_drag_data(_at_position: Vector2):
	if is_used:
		return null
	
	is_dragging = true
	original_position = global_position
	
	# 播放拖拽音效
	if AudioManager:
		AudioManager.play_drag()
	
	# 拖拽动画：轻微放大 + 半透明
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)
	tween.tween_property(self, "modulate:a", 0.7, 0.1)
	
	drag_started.emit(self)
	
	# 创建拖拽预览
	var preview = duplicate()
	preview.modulate.a = 0.8
	set_drag_preview(preview)
	
	return self

## 拖拽结束
func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		if is_dragging:
			is_dragging = false
			# 恢复动画
			var tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(self, "scale", Vector2.ONE, 0.1)
			tween.tween_property(self, "modulate:a", 1.0, 0.1)
			drag_ended.emit(self)

## 设置已使用状态
func set_used(used: bool):
	is_used = used
	if is_used:
		modulate = Color(0.3, 0.3, 0.3)
		mouse_filter = MOUSE_FILTER_IGNORE
	else:
		modulate = Color.WHITE
		mouse_filter = MOUSE_FILTER_STOP

## 返回原始位置（放置失败时调用）
func return_to_original():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", original_position, 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.3)
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
