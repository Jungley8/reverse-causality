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

@onready var label = $VBox/Label

func _ready():
	if cause_data:
		_setup_visuals()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _setup_visuals():
	if not cause_data:
		return
	
	# 使用新 UI 系统
	var variant = "distractor" if cause_data.is_distractor else "default"
	add_theme_stylebox_override("panel", UIStyles.card(variant))
	
	# 设置文本 - i18n
	if label:
		# 先尝试从语言包获取翻译，如果没有则使用 label
		var translated = I18nManager.translate("nodes." + cause_data.id)
		if translated.begins_with("nodes."):
			# 翻译不存在，使用原 label
			label.text = cause_data.label
		else:
			label.text = translated

func _on_mouse_entered():
	if not is_used and not is_dragging:
		_apply_hover_effect()

func _on_mouse_exited():
	if not is_dragging:
		_remove_hover_effect()

func _apply_hover_effect():
	# 动画
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.08, 1.08), UITokens.ANIMATION.DURATION_NORMAL).set_ease(Tween.EASE_OUT)
	
	# 更新样式 - 使用 UIStyles
	if cause_data:
		var variant = "hover_distractor" if cause_data.is_distractor else "hover"
		add_theme_stylebox_override("panel", UIStyles.card(variant))

func _remove_hover_effect():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, UITokens.ANIMATION.DURATION_FAST).set_ease(Tween.EASE_OUT)
	
	# 恢复原样式
	if cause_data:
		var variant = "distractor" if cause_data.is_distractor else "default"
		add_theme_stylebox_override("panel", UIStyles.card(variant))

## 开始拖拽
func _get_drag_data(_at_position: Vector2):
	if is_used:
		return null
	
	is_dragging = true
	original_position = global_position
	z_index = UITokens.LAYER.DRAG_DROP
	
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
