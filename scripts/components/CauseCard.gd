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
		_setup_visuals()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _setup_visuals():
	if not cause_data:
		return
	
	# 使用主题样式
	var style = ThemeManager.create_card_style(cause_data.is_distractor)
	add_theme_stylebox_override("panel", style)
	
	# 设置文本（更大的字体以匹配新的卡片尺寸）
	if label:
		label.text = cause_data.label
		label.add_theme_color_override("font_color", ThemeManager.get_color("text_primary"))
		label.add_theme_font_size_override("font_size", 18)  # 更大的字体

func _on_mouse_entered():
	if not is_used and not is_dragging:
		_apply_hover_effect()

func _on_mouse_exited():
	if not is_dragging:
		_remove_hover_effect()

func _apply_hover_effect():
	# 更明显的缩放动画
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.2).set_ease(Tween.EASE_OUT)
	
	# 更新样式
	if cause_data:
		var hover_style = ThemeManager.create_card_style(cause_data.is_distractor)
		hover_style.bg_color = Color("#1E232E")  # CARD_BG_HOVER
		if cause_data.is_distractor:
			hover_style.border_color = Color("#F85149")  # 危险色
		else:
			hover_style.border_color = Color("#58A6FF")  # 蓝色强调
		hover_style.border_width_left = 3
		hover_style.border_width_top = 3
		hover_style.border_width_right = 3
		hover_style.border_width_bottom = 3
		
		# 添加更明显的光晕
		var shadow = _shadow_md()
		if not cause_data.is_distractor:
			# 蓝色光晕
			hover_style.shadow_color = Color(88, 166, 255, 0.4)
		else:
			# 红色光晕
			hover_style.shadow_color = Color(248, 81, 73, 0.4)
		hover_style.shadow_size = 12
		hover_style.shadow_offset = Vector2(0, 4)
		
		add_theme_stylebox_override("panel", hover_style)

func _shadow_md() -> Dictionary:
	return {"shadow_color": Color(0, 0, 0, 0.25), "shadow_size": 4, "shadow_offset": Vector2(0, 2)}

func _remove_hover_effect():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_OUT)
	
	# 恢复原样式
	if cause_data:
		var normal_style = ThemeManager.create_card_style(cause_data.is_distractor)
		add_theme_stylebox_override("panel", normal_style)

## 开始拖拽
func _get_drag_data(_at_position: Vector2):
	if is_used:
		return null
	
	is_dragging = true
	original_position = global_position
	z_index = 100
	
	# 播放拖拽音效
	if AudioManager:
		AudioManager.play_drag()
	
	# 拖拽动画：轻微放大 + 半透明
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.8, 0.1)
	
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
			z_index = 0
			# 恢复动画
			var tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(self, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_OUT)
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
	tween.tween_property(self, "global_position", original_position, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
