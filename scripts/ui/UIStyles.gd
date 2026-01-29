extends Node

## UIStyles - 样式工厂
## 统一创建所有 StyleBox，确保视觉一致性
##
## 用法：
##   panel.add_theme_stylebox_override("panel", UIStyles.card())
##   button.add_theme_stylebox_override("normal", UIStyles.button("primary", "normal"))

# 在 _ready() 中加载 UITokens
var _tokens
var C  # COLOR
var S  # SPACING
var R  # RADIUS
var B  # BORDER
var SZ # SIZE
var SHADOW

func _ready():
	# 自动从 Autoload 中获取 UITokens
	if has_node("/root/UITokens"):
		_tokens = get_node("/root/UITokens")
		C = _tokens.COLOR
		S = _tokens.SPACING
		R = _tokens.RADIUS
		B = _tokens.BORDER
		SZ = _tokens.SIZE
		SHADOW = _tokens.SHADOW
	else:
		push_error("UITokens 自动加载未找到")

# ============================================================
# 卡片样式
# ============================================================

## 因果卡片样式
## variant: "default", "distractor", "hover", "used"
func card(variant: String = "default") -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	
	match variant:
		"default":
			style.bg_color = C.BG_ELEVATED
			style.border_color = C.BORDER_DEFAULT
			_apply_shadow(style, SHADOW.md())
		"distractor":
			style.bg_color = Color("#1E1616")
			style.border_color = C.DANGER_MUTED
			_apply_shadow(style, SHADOW.md())
		"hover":
			style.bg_color = C.BG_OVERLAY
			style.border_color = C.WARNING
			_apply_shadow(style, SHADOW.glow(C.WARNING))
		"hover_distractor":
			style.bg_color = Color("#2E1A1A")
			style.border_color = C.DANGER
			_apply_shadow(style, SHADOW.glow(C.DANGER))
		"used":
			style.bg_color = Color("#1A1A1A")
			style.border_color = Color("#3A3A3A")
			_apply_shadow(style, SHADOW.none())
		_:
			style.bg_color = C.BG_ELEVATED
			style.border_color = C.BORDER_DEFAULT
	
	# 通用设置
	_apply_border(style, B.DEFAULT)
	_apply_radius(style, R.LG)
	_apply_padding(style, SZ.CARD_PADDING)
	
	return style

# ============================================================
# 槽位样式
# ============================================================

## 链槽位样式
## state: "empty", "filled", "hover_valid", "hover_invalid"
func slot(state: String = "empty") -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	
	match state:
		"empty":
			style.bg_color = C.BG_SURFACE
			style.border_color = C.BORDER_SUBTLE
			style.draw_center = true
			_apply_shadow(style, SHADOW.sm())
		"filled":
			style.bg_color = C.BG_ELEVATED
			style.border_color = C.INFO
			_apply_shadow(style, SHADOW.md())
		"hover_valid":
			style.bg_color = C.SUCCESS_SUBTLE
			style.border_color = C.SUCCESS
			_apply_shadow(style, SHADOW.glow(C.SUCCESS))
		"hover_invalid":
			style.bg_color = C.DANGER_SUBTLE
			style.border_color = C.DANGER
			_apply_shadow(style, SHADOW.glow(C.DANGER))
		_:
			style.bg_color = C.BG_SURFACE
			style.border_color = C.BORDER_SUBTLE
	
	# 通用设置
	_apply_border(style, B.DEFAULT)
	_apply_radius(style, R.LG)
	_apply_padding(style, SZ.CARD_PADDING)
	
	return style

# ============================================================
# 按钮样式
# ============================================================

## 按钮样式
## variant: "primary", "secondary", "danger"
## state: "normal", "hover", "pressed", "disabled"
func button(variant: String = "primary", state: String = "normal") -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	
	if variant == "primary":
		match state:
			"normal":
				style.bg_color = C.SUCCESS
				style.border_color = C.SUCCESS_MUTED
				_apply_shadow(style, SHADOW.sm())
			"hover":
				style.bg_color = C.SUCCESS_HOVER
				style.border_color = C.SUCCESS
				_apply_shadow(style, SHADOW.md())
			"pressed":
				style.bg_color = C.SUCCESS_MUTED
				style.border_color = C.SUCCESS_MUTED
				_apply_shadow(style, SHADOW.none())
			"disabled":
				style.bg_color = C.BG_ELEVATED
				style.border_color = C.BORDER_SUBTLE
				_apply_shadow(style, SHADOW.none())
	elif variant == "secondary":
		match state:
			"normal":
				style.bg_color = C.BG_ELEVATED
				style.border_color = C.BORDER_DEFAULT
				_apply_shadow(style, SHADOW.sm())
			"hover":
				style.bg_color = C.BG_OVERLAY
				style.border_color = C.INFO
				_apply_shadow(style, SHADOW.md())
			"pressed":
				style.bg_color = C.BG_SURFACE
				style.border_color = C.BORDER_DEFAULT
				_apply_shadow(style, SHADOW.none())
			"disabled":
				style.bg_color = C.BG_SURFACE
				style.border_color = C.BORDER_SUBTLE
				_apply_shadow(style, SHADOW.none())
	elif variant == "danger":
		match state:
			"normal":
				style.bg_color = C.DANGER
				style.border_color = C.DANGER_MUTED
				_apply_shadow(style, SHADOW.sm())
			"hover":
				style.bg_color = C.DANGER_HOVER
				style.border_color = C.DANGER
				_apply_shadow(style, SHADOW.md())
			"pressed":
				style.bg_color = C.DANGER_MUTED
				style.border_color = C.DANGER_MUTED
				_apply_shadow(style, SHADOW.none())
			"disabled":
				style.bg_color = C.BG_ELEVATED
				style.border_color = C.BORDER_SUBTLE
				_apply_shadow(style, SHADOW.none())
	
	# 通用设置
	_apply_border(style, B.DEFAULT)
	_apply_radius(style, R.MD)
	style.content_margin_left = SZ.BUTTON_PADDING_H
	style.content_margin_right = SZ.BUTTON_PADDING_H
	style.content_margin_top = SZ.BUTTON_PADDING_V
	style.content_margin_bottom = SZ.BUTTON_PADDING_V
	
	return style

## 应用完整按钮样式到 Button 节点
func apply_button_style(btn: Button, variant: String = "primary"):
	if not btn:
		return
	
	btn.add_theme_stylebox_override("normal", button(variant, "normal"))
	btn.add_theme_stylebox_override("hover", button(variant, "hover"))
	btn.add_theme_stylebox_override("pressed", button(variant, "pressed"))
	btn.add_theme_stylebox_override("disabled", button(variant, "disabled"))
	
	# 设置字体颜色
	if variant == "primary":
		btn.add_theme_color_override("font_color", C.TEXT_PRIMARY)
		btn.add_theme_color_override("font_hover_color", Color.WHITE)
		btn.add_theme_color_override("font_pressed_color", C.TEXT_PRIMARY)
		btn.add_theme_color_override("font_disabled_color", C.TEXT_DISABLED)
	else:
		btn.add_theme_color_override("font_color", C.TEXT_PRIMARY)
		btn.add_theme_color_override("font_hover_color", C.TEXT_PRIMARY)
		btn.add_theme_color_override("font_pressed_color", C.TEXT_SECONDARY)
		btn.add_theme_color_override("font_disabled_color", C.TEXT_DISABLED)
	
	# 应用字体
	if UIFonts:
		UIFonts.apply_to_button(btn, UIFonts.SIZES.BODY)

# ============================================================
# 面板样式
# ============================================================

## 面板样式
## variant: "default", "elevated", "card", "overlay"
func panel(variant: String = "default") -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	
	match variant:
		"default":
			style.bg_color = C.BG_SURFACE
			style.border_color = C.BORDER_SUBTLE
			_apply_shadow(style, SHADOW.sm())
		"elevated":
			style.bg_color = C.BG_ELEVATED
			style.border_color = C.BORDER_DEFAULT
			_apply_shadow(style, SHADOW.md())
		"card":
			style.bg_color = C.BG_ELEVATED
			style.border_color = C.BORDER_DEFAULT
			_apply_shadow(style, SHADOW.md())
		"overlay":
			style.bg_color = C.BG_OVERLAY
			style.border_color = C.BORDER_STRONG
			_apply_shadow(style, SHADOW.lg())
		_:
			style.bg_color = C.BG_SURFACE
			style.border_color = C.BORDER_SUBTLE
	
	# 通用设置
	_apply_border(style, B.DEFAULT)
	_apply_radius(style, R.LG)
	_apply_padding(style, S.LG)
	
	return style

# ============================================================
# 进度条样式
# ============================================================

## 进度条背景
func progress_bg() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = C.BG_ELEVATED
	style.border_color = C.BORDER_SUBTLE
	_apply_border(style, B.THIN)
	_apply_radius(style, R.MD)
	return style

## 进度条填充
## color: "default", "success", "warning", "danger"
func progress_fill(color_variant: String = "default") -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	
	match color_variant:
		"success":
			style.bg_color = C.SUCCESS
		"warning":
			style.bg_color = C.WARNING
		"danger":
			style.bg_color = C.DANGER
		_:
			style.bg_color = C.WARNING  # 默认琥珀金
	
	_apply_radius(style, R.MD)
	return style

# ============================================================
# 输入框样式
# ============================================================

func input(state: String = "normal") -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	
	match state:
		"normal":
			style.bg_color = C.BG_SURFACE
			style.border_color = C.BORDER_DEFAULT
		"focus":
			style.bg_color = C.BG_ELEVATED
			style.border_color = C.INFO
		"error":
			style.bg_color = C.BG_SURFACE
			style.border_color = C.DANGER
		_:
			style.bg_color = C.BG_SURFACE
			style.border_color = C.BORDER_DEFAULT
	
	_apply_border(style, B.DEFAULT)
	_apply_radius(style, R.SM)
	_apply_padding(style, S.MD)
	
	return style

# ============================================================
# 辅助方法
# ============================================================

func _apply_border(style: StyleBoxFlat, width: int):
	style.border_width_left = width
	style.border_width_top = width
	style.border_width_right = width
	style.border_width_bottom = width

func _apply_radius(style: StyleBoxFlat, radius: int):
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius

func _apply_padding(style: StyleBoxFlat, padding: int):
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding
	style.content_margin_bottom = padding

func _apply_shadow(style: StyleBoxFlat, shadow: Dictionary):
	if shadow.has("color"):
		style.shadow_color = shadow.color
	if shadow.has("size"):
		style.shadow_size = shadow.size
	if shadow.has("offset"):
		style.shadow_offset = shadow.offset
