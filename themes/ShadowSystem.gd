class_name ShadowSystem
extends Object

## 阴影与光效系统
## 用于定义UI元素的"悬浮"高度

# Level 0: 贴合表面（无阴影）
static func shadow_none() -> Dictionary:
	return {}

# Level 1: 微弱抬升（按钮默认、卡片）
static func shadow_sm() -> Dictionary:
	return {
		"shadow_color": Color(0, 0, 0, 0.15),
		"shadow_size": 2,
		"shadow_offset": Vector2(0, 1)
	}

# Level 2: 中度抬升（悬停状态、下拉菜单）
static func shadow_md() -> Dictionary:
	return {
		"shadow_color": Color(0, 0, 0, 0.25),
		"shadow_size": 4,
		"shadow_offset": Vector2(0, 2)
	}

# Level 3: 高度抬升（模态框、弹窗）
static func shadow_lg() -> Dictionary:
	return {
		"shadow_color": Color(0, 0, 0, 0.35),
		"shadow_size": 8,
		"shadow_offset": Vector2(0, 4)
	}

# Level 4: 极高抬升（通知、Toast）
static func shadow_xl() -> Dictionary:
	return {
		"shadow_color": Color(0, 0, 0, 0.45),
		"shadow_size": 16,
		"shadow_offset": Vector2(0, 8)
	}

# === 内阴影（用于凹陷效果） ===
static func shadow_inner() -> Dictionary:
	return {
		"shadow_color": Color(0, 0, 0, 0.2),
		"shadow_size": -2,  # 负值表示内阴影
		"shadow_offset": Vector2(0, -1)
	}

# === 光晕效果 ===
static func glow_success() -> Dictionary:
	# 使用 lerp 将颜色向白色混合以变亮
	var lightened_color = ColorPalette.SUCCESS_DEFAULT.lerp(Color.WHITE, 0.2)
	return {
		"shadow_color": lightened_color,
		"shadow_size": 8,
		"shadow_offset": Vector2(0, 0)
	}

static func glow_danger() -> Dictionary:
	# 使用 lerp 将颜色向白色混合以变亮
	var lightened_color = ColorPalette.DANGER_DEFAULT.lerp(Color.WHITE, 0.2)
	return {
		"shadow_color": lightened_color,
		"shadow_size": 8,
		"shadow_offset": Vector2(0, 0)
	}
