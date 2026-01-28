@tool
class_name ThemeBuilder
extends Object

## 主题构建器
## 在编辑器中运行此脚本生成主题文件

func build_theme() -> Theme:
	var theme = Theme.new()
	
	# === 字体设置 ===
	_setup_fonts(theme)
	
	# === Button 样式 ===
	_setup_buttons(theme)
	
	# === Label 样式 ===
	_setup_labels(theme)
	
	# === Panel 样式 ===
	_setup_panels(theme)
	
	# === ProgressBar 样式 ===
	_setup_progress_bars(theme)
	
	# === LineEdit 样式 ===
	_setup_line_edits(theme)
	
	return theme

# === 字体设置 ===
func _setup_fonts(theme: Theme):
	# 尝试加载字体（如果存在）
	var font_path = "res://NotoSansSC-VariableFont_wght.ttf"
	if ResourceLoader.exists(font_path):
		var font_file = load(font_path)
		if font_file:
			theme.set_font("font", "", font_file)
	
	# 设置默认字体大小
	theme.set_font_size("font_size", "", 16)  # FONT_SIZE_BODY

# === Button 样式 ===
func _setup_buttons(theme: Theme):
	# Primary Button（主按钮）
	var btn_primary_normal = _create_button_style(
		Color("#58A6FF"),  # BUTTON_PRIMARY_BG
		Color("#484F58"),  # BORDER_ACCENT
		8, 1
	)
	var btn_primary_hover = _create_button_style(
		Color("#79C0FF"),  # BUTTON_PRIMARY_HOVER
		Color("#79C0FF"),  # INFO_EMPHASIS
		8, 2,
		_shadow_md()
	)
	var btn_primary_pressed = _create_button_style(
		Color("#388BFD"),  # BUTTON_PRIMARY_ACTIVE
		Color("#388BFD"),  # INFO_MUTED
		8, 1
	)
	var btn_primary_disabled = _create_button_style(
		Color("#161A23"),  # BG_ELEVATED
		Color("#1C2128"),  # BORDER_SUBTLE
		8, 1
	)
	
	theme.set_stylebox("normal", "ButtonPrimary", btn_primary_normal)
	theme.set_stylebox("hover", "ButtonPrimary", btn_primary_hover)
	theme.set_stylebox("pressed", "ButtonPrimary", btn_primary_pressed)
	theme.set_stylebox("disabled", "ButtonPrimary", btn_primary_disabled)
	
	theme.set_color("font_color", "ButtonPrimary", Color("#0A0D12"))  # TEXT_INVERSE
	theme.set_color("font_hover_color", "ButtonPrimary", Color.WHITE)
	theme.set_color("font_pressed_color", "ButtonPrimary", Color("#0A0D12"))  # TEXT_INVERSE
	theme.set_color("font_disabled_color", "ButtonPrimary", Color("#484F58"))  # TEXT_DISABLED
	
	theme.set_font_size("font_size", "ButtonPrimary", 16)  # FONT_SIZE_BODY
	
	# Secondary Button（次按钮）
	var btn_secondary_normal = _create_button_style(
		Color("#161A23"),  # BUTTON_SECONDARY_BG
		Color("#2D3139"),  # BORDER_DEFAULT
		8, 1
	)
	var btn_secondary_hover = _create_button_style(
		Color("#1E232E"),  # BUTTON_SECONDARY_HOVER
		Color("#484F58"),  # BORDER_ACCENT
		8, 1,
		_shadow_sm()
	)
	
	theme.set_stylebox("normal", "ButtonSecondary", btn_secondary_normal)
	theme.set_stylebox("hover", "ButtonSecondary", btn_secondary_hover)
	theme.set_stylebox("pressed", "ButtonSecondary", btn_secondary_normal)
	theme.set_stylebox("disabled", "ButtonSecondary", btn_primary_disabled)
	
	theme.set_color("font_color", "ButtonSecondary", Color("#E6EDF3"))  # TEXT_PRIMARY
	theme.set_color("font_hover_color", "ButtonSecondary", Color.WHITE)
	theme.set_font_size("font_size", "ButtonSecondary", 16)  # FONT_SIZE_BODY
	
	# Default Button（默认按钮，用于未指定类型的按钮）
	theme.set_stylebox("normal", "Button", btn_secondary_normal)
	theme.set_stylebox("hover", "Button", btn_secondary_hover)
	theme.set_stylebox("pressed", "Button", btn_secondary_normal)
	theme.set_stylebox("disabled", "Button", btn_primary_disabled)
	
	theme.set_color("font_color", "Button", Color("#E6EDF3"))  # TEXT_PRIMARY
	theme.set_font_size("font_size", "Button", 16)  # FONT_SIZE_BODY

# === Label 样式 ===
func _setup_labels(theme: Theme):
	theme.set_color("font_color", "Label", Color("#E6EDF3"))  # TEXT_PRIMARY
	theme.set_font_size("font_size", "Label", 16)  # FONT_SIZE_BODY
	
	# Heading1
	theme.set_color("font_color", "LabelH1", Color("#E6EDF3"))  # TEXT_PRIMARY
	theme.set_font_size("font_size", "LabelH1", 32)  # FONT_SIZE_H1
	
	# Heading2
	theme.set_color("font_color", "LabelH2", Color("#E6EDF3"))  # TEXT_PRIMARY
	theme.set_font_size("font_size", "LabelH2", 24)  # FONT_SIZE_H2
	
	# Secondary text
	theme.set_color("font_color", "LabelSecondary", Color("#9EA7B3"))  # TEXT_SECONDARY
	theme.set_font_size("font_size", "LabelSecondary", 14)  # FONT_SIZE_BODY_SMALL
	
	# Caption
	theme.set_color("font_color", "LabelCaption", Color("#6E7781"))  # TEXT_TERTIARY
	theme.set_font_size("font_size", "LabelCaption", 12)  # FONT_SIZE_CAPTION

# === Panel 样式 ===
func _setup_panels(theme: Theme):
	# PanelContainer - 卡片容器
	var panel_card = _create_panel_style(
		Color("#161A23"),  # BG_ELEVATED
		Color("#2D3139"),  # BORDER_DEFAULT
		6, 1,
		_shadow_sm()
	)
	theme.set_stylebox("panel", "PanelContainer", panel_card)
	
	# Panel - 基础面板
	var panel_base = _create_panel_style(
		Color("#0E1117"),  # BG_SURFACE
		Color("#1C2128"),  # BORDER_SUBTLE
		4, 1
	)
	theme.set_stylebox("panel", "Panel", panel_base)
	
	# PanelElevated - 抬升面板
	var panel_elevated = _create_panel_style(
		Color("#1E232E"),  # BG_OVERLAY
		Color("#3D4149"),  # BORDER_STRONG
		8, 2,
		_shadow_md()
	)
	theme.set_stylebox("panel", "PanelElevated", panel_elevated)

# === ProgressBar 样式 ===
func _setup_progress_bars(theme: Theme):
	# Background
	var progress_bg = StyleBoxFlat.new()
	progress_bg.bg_color = Color("#0E1117")  # BG_SURFACE
	progress_bg.corner_radius_top_left = 4
	progress_bg.corner_radius_top_right = 4
	progress_bg.corner_radius_bottom_left = 4
	progress_bg.corner_radius_bottom_right = 4
	progress_bg.border_width_left = 1
	progress_bg.border_width_top = 1
	progress_bg.border_width_right = 1
	progress_bg.border_width_bottom = 1
	progress_bg.border_color = Color("#1C2128")  # BORDER_SUBTLE
	
	# Fill（渐变效果）
	var progress_fill = StyleBoxFlat.new()
	progress_fill.bg_color = Color("#3FB950")  # SUCCESS_DEFAULT
	progress_fill.corner_radius_top_left = 4
	progress_fill.corner_radius_top_right = 4
	progress_fill.corner_radius_bottom_left = 4
	progress_fill.corner_radius_bottom_right = 4
	
	# 设置渐变（Godot 4.x）
	# 注：StyleBoxFlat的渐变需要通过shader实现
	# 这里使用纯色，如需渐变可在ProgressBar自定义shader
	
	theme.set_stylebox("background", "ProgressBar", progress_bg)
	theme.set_stylebox("fill", "ProgressBar", progress_fill)
	theme.set_color("font_color", "ProgressBar", Color.WHITE)
	theme.set_font_size("font_size", "ProgressBar", 14)  # FONT_SIZE_BODY_SMALL

# === LineEdit 样式 ===
func _setup_line_edits(theme: Theme):
	var line_edit_normal = _create_panel_style(
		Color("#0E1117"),  # BG_SURFACE
		Color("#2D3139"),  # BORDER_DEFAULT
		4, 1
	)
	var line_edit_focus = _create_panel_style(
		Color("#161A23"),  # BG_ELEVATED
		Color("#58A6FF"),  # INFO_DEFAULT
		4, 2
	)
	
	theme.set_stylebox("normal", "LineEdit", line_edit_normal)
	theme.set_stylebox("focus", "LineEdit", line_edit_focus)
	theme.set_color("font_color", "LineEdit", Color("#E6EDF3"))  # TEXT_PRIMARY
	theme.set_color("font_placeholder_color", "LineEdit", Color("#6E7781"))  # TEXT_TERTIARY

# === 辅助方法 ===
func _create_button_style(
	bg_color: Color,
	border_color: Color,
	corner_radius: int = 8,
	border_width: int = 1,
	shadow: Dictionary = {}
) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	
	style.corner_radius_top_left = corner_radius
	style.corner_radius_top_right = corner_radius
	style.corner_radius_bottom_left = corner_radius
	style.corner_radius_bottom_right = corner_radius
	
	# 内边距
	style.content_margin_left = 24  # BUTTON_PADDING_H
	style.content_margin_right = 24  # BUTTON_PADDING_H
	style.content_margin_top = 12  # BUTTON_PADDING_V
	style.content_margin_bottom = 12  # BUTTON_PADDING_V
	
	# 阴影
	if shadow.has("shadow_color"):
		style.shadow_color = shadow.shadow_color
		style.shadow_size = shadow.shadow_size
		style.shadow_offset = shadow.shadow_offset
	
	return style

func _create_panel_style(
	bg_color: Color,
	border_color: Color,
	corner_radius: int = 6,
	border_width: int = 1,
	shadow: Dictionary = {}
) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	
	style.corner_radius_top_left = corner_radius
	style.corner_radius_top_right = corner_radius
	style.corner_radius_bottom_left = corner_radius
	style.corner_radius_bottom_right = corner_radius
	
	# 内边距
	style.content_margin_left = 24  # PANEL_PADDING
	style.content_margin_right = 24  # PANEL_PADDING
	style.content_margin_top = 24  # PANEL_PADDING
	style.content_margin_bottom = 24  # PANEL_PADDING
	
	# 阴影
	if shadow.has("shadow_color"):
		style.shadow_color = shadow.shadow_color
		style.shadow_size = shadow.shadow_size
		style.shadow_offset = shadow.shadow_offset
	
	return style

# 阴影辅助方法（避免依赖 ShadowSystem）
func _shadow_sm() -> Dictionary:
	return {"shadow_color": Color(0, 0, 0, 0.15), "shadow_size": 2, "shadow_offset": Vector2(0, 1)}

func _shadow_md() -> Dictionary:
	return {"shadow_color": Color(0, 0, 0, 0.25), "shadow_size": 4, "shadow_offset": Vector2(0, 2)}

# === 保存主题 ===
func save_theme():
	var theme = build_theme()
	var err = ResourceSaver.save(theme, "res://themes/default_theme.tres")
	if err == OK:
		print("主题已保存到 res://themes/default_theme.tres")
	else:
		push_error("主题保存失败：", err)
