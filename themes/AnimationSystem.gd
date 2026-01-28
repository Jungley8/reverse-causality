class_name AnimationSystem
extends Object

## 动效设计系统
## 标准化的动画函数和时长常量

# === 时长标准 ===
const DURATION_INSTANT = 0.0
const DURATION_FAST = 0.15      # 快速反馈
const DURATION_NORMAL = 0.3     # 标准过渡
const DURATION_SLOW = 0.5       # 慢速强调
const DURATION_VERY_SLOW = 0.8  # 超慢展示

# === 缓动函数 ===
const EASE_OUT_STANDARD = Tween.EASE_OUT
const EASE_IN_OUT_SMOOTH = Tween.EASE_IN_OUT
const TRANS_BACK = Tween.TRANS_BACK      # 回弹效果
const TRANS_ELASTIC = Tween.TRANS_ELASTIC # 弹性效果

# === 预定义动画 ===
static func fade_in(node: CanvasItem, duration: float = DURATION_NORMAL):
	node.modulate.a = 0.0
	var tween = node.create_tween()
	tween.tween_property(node, "modulate:a", 1.0, duration).set_ease(EASE_OUT_STANDARD)

static func fade_out(node: CanvasItem, duration: float = DURATION_NORMAL):
	var tween = node.create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration).set_ease(EASE_OUT_STANDARD)

static func scale_bounce(node: Control, target_scale: Vector2 = Vector2.ONE, duration: float = DURATION_NORMAL):
	var tween = node.create_tween()
	tween.tween_property(node, "scale", target_scale, duration).set_ease(EASE_OUT_STANDARD).set_trans(TRANS_BACK)

static func slide_in_from_bottom(node: Control, duration: float = DURATION_NORMAL):
	var start_pos = node.position
	node.position.y += 100
	node.modulate.a = 0.0
	
	var tween = node.create_tween()
	tween.set_parallel(true)
	tween.tween_property(node, "position", start_pos, duration).set_ease(EASE_OUT_STANDARD)
	tween.tween_property(node, "modulate:a", 1.0, duration * 0.6)

static func pulse_glow(node: Control, color: Color, count: int = 1):
	var original_modulate = node.modulate
	var tween = node.create_tween()
	
	for i in range(count):
		tween.tween_property(node, "modulate", color, DURATION_FAST)
		tween.tween_property(node, "modulate", original_modulate, DURATION_FAST)
