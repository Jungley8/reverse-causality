@tool
extends EditorScript

## 编辑器脚本：生成主题文件
## 在编辑器中：工具 > 执行脚本 > 选择此文件

func _run():
	# 直接内联构建主题，避免类加载问题
	var theme = _build_theme()
	if theme:
		var err = ResourceSaver.save(theme, "res://themes/default_theme.tres")
		if err == OK:
			print("主题已保存到 res://themes/default_theme.tres")
		else:
			push_error("主题保存失败：", err)
	else:
		push_error("主题构建失败")

# 内联构建主题（完全独立的实现）
func _build_theme() -> Theme:
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

func _setup_fonts(theme: Theme):
	var font_path = "res://NotoSansSC-VariableFont_wght.ttf"
	if ResourceLoader.exists(font_path):
		var font_file = load(font_path)
		if font_file:
			theme.set_font("font", "", font_file)
	theme.set_font_size("font_size", "", 16)  # TypographySystem.FONT_SIZE_BODY

func _setup_buttons(theme: Theme):
	# Primary Button - 更亮的蓝色，更明显的效果
	var btn_primary_normal = _create_button_style(Color("#58A6FF"), Color("#58A6FF"), 12, 2)
	btn_primary_normal.shadow_color = Color(0, 0, 0, 0.2)
	btn_primary_normal.shadow_size = 4
	btn_primary_normal.shadow_offset = Vector2(0, 2)
	
	var btn_primary_hover = _create_button_style(Color("#79C0FF"), Color("#79C0FF"), 12, 2, _shadow_md())
	btn_primary_hover.shadow_color = Color(88, 166, 255, 0.3)  # 蓝色光晕
	btn_primary_hover.shadow_size = 8
	btn_primary_hover.shadow_offset = Vector2(0, 3)
	
	var btn_primary_pressed = _create_button_style(Color("#388BFD"), Color("#388BFD"), 12, 2)
	btn_primary_pressed.shadow_color = Color(0, 0, 0, 0.15)
	btn_primary_pressed.shadow_size = 2
	btn_primary_pressed.shadow_offset = Vector2(0, 1)
	
	var btn_primary_disabled = _create_button_style(Color("#161A23"), Color("#1C2128"), 12, 1)
	
	theme.set_stylebox("normal", "ButtonPrimary", btn_primary_normal)
	theme.set_stylebox("hover", "ButtonPrimary", btn_primary_hover)
	theme.set_stylebox("pressed", "ButtonPrimary", btn_primary_pressed)
	theme.set_stylebox("disabled", "ButtonPrimary", btn_primary_disabled)
	
	theme.set_color("font_color", "ButtonPrimary", Color("#0A0D12"))
	theme.set_color("font_hover_color", "ButtonPrimary", Color.WHITE)
	theme.set_color("font_pressed_color", "ButtonPrimary", Color("#0A0D12"))
	theme.set_color("font_disabled_color", "ButtonPrimary", Color("#484F58"))
	theme.set_font_size("font_size", "ButtonPrimary", 18)  # 更大字体
	
	# Secondary Button - 更明显的边框和悬停效果
	var btn_secondary_normal = _create_button_style(Color("#161A23"), Color("#484F58"), 12, 2)
	btn_secondary_normal.shadow_color = Color(0, 0, 0, 0.15)
	btn_secondary_normal.shadow_size = 3
	btn_secondary_normal.shadow_offset = Vector2(0, 2)
	
	var btn_secondary_hover = _create_button_style(Color("#1E232E"), Color("#58A6FF"), 12, 2, _shadow_md())
	btn_secondary_hover.shadow_color = Color(0, 0, 0, 0.25)
	btn_secondary_hover.shadow_size = 6
	btn_secondary_hover.shadow_offset = Vector2(0, 3)
	
	theme.set_stylebox("normal", "ButtonSecondary", btn_secondary_normal)
	theme.set_stylebox("hover", "ButtonSecondary", btn_secondary_hover)
	theme.set_stylebox("pressed", "ButtonSecondary", btn_secondary_normal)
	theme.set_stylebox("disabled", "ButtonSecondary", btn_primary_disabled)
	
	theme.set_color("font_color", "ButtonSecondary", Color("#E6EDF3"))
	theme.set_color("font_hover_color", "ButtonSecondary", Color.WHITE)
	theme.set_font_size("font_size", "ButtonSecondary", 18)  # 更大字体
	
	# Default Button
	theme.set_stylebox("normal", "Button", btn_secondary_normal)
	theme.set_stylebox("hover", "Button", btn_secondary_hover)
	theme.set_stylebox("pressed", "Button", btn_secondary_normal)
	theme.set_stylebox("disabled", "Button", btn_primary_disabled)
	theme.set_color("font_color", "Button", Color("#E6EDF3"))
	theme.set_font_size("font_size", "Button", 18)

func _setup_labels(theme: Theme):
	theme.set_color("font_color", "Label", Color("#E6EDF3"))
	theme.set_font_size("font_size", "Label", 16)
	theme.set_color("font_color", "LabelH1", Color("#E6EDF3"))
	theme.set_font_size("font_size", "LabelH1", 32)
	theme.set_color("font_color", "LabelH2", Color("#E6EDF3"))
	theme.set_font_size("font_size", "LabelH2", 24)
	theme.set_color("font_color", "LabelSecondary", Color("#9EA7B3"))
	theme.set_font_size("font_size", "LabelSecondary", 14)
	theme.set_color("font_color", "LabelCaption", Color("#6E7781"))
	theme.set_font_size("font_size", "LabelCaption", 12)

func _setup_panels(theme: Theme):
	# PanelContainer - 卡片容器，更明显的阴影和边框
	var panel_card = _create_panel_style(Color("#161A23"), Color("#484F58"), 10, 2, _shadow_md())
	panel_card.shadow_color = Color(0, 0, 0, 0.3)
	panel_card.shadow_size = 6
	panel_card.shadow_offset = Vector2(0, 3)
	theme.set_stylebox("panel", "PanelContainer", panel_card)
	
	# Panel - 基础面板
	var panel_base = _create_panel_style(Color("#0E1117"), Color("#2D3139"), 8, 1)
	panel_base.shadow_color = Color(0, 0, 0, 0.1)
	panel_base.shadow_size = 2
	panel_base.shadow_offset = Vector2(0, 1)
	theme.set_stylebox("panel", "Panel", panel_base)
	
	# PanelElevated - 抬升面板，更强的阴影
	var panel_elevated = _create_panel_style(Color("#1E232E"), Color("#58A6FF"), 12, 2, _shadow_md())
	panel_elevated.shadow_color = Color(0, 0, 0, 0.4)
	panel_elevated.shadow_size = 10
	panel_elevated.shadow_offset = Vector2(0, 4)
	theme.set_stylebox("panel", "PanelElevated", panel_elevated)

func _setup_progress_bars(theme: Theme):
	var progress_bg = StyleBoxFlat.new()
	progress_bg.bg_color = Color("#0E1117")
	progress_bg.corner_radius_top_left = 4
	progress_bg.corner_radius_top_right = 4
	progress_bg.corner_radius_bottom_left = 4
	progress_bg.corner_radius_bottom_right = 4
	progress_bg.border_width_left = 1
	progress_bg.border_width_top = 1
	progress_bg.border_width_right = 1
	progress_bg.border_width_bottom = 1
	progress_bg.border_color = Color("#1C2128")
	
	var progress_fill = StyleBoxFlat.new()
	progress_fill.bg_color = Color("#3FB950")
	progress_fill.corner_radius_top_left = 4
	progress_fill.corner_radius_top_right = 4
	progress_fill.corner_radius_bottom_left = 4
	progress_fill.corner_radius_bottom_right = 4
	
	theme.set_stylebox("background", "ProgressBar", progress_bg)
	theme.set_stylebox("fill", "ProgressBar", progress_fill)
	theme.set_color("font_color", "ProgressBar", Color.WHITE)
	theme.set_font_size("font_size", "ProgressBar", 14)

func _setup_line_edits(theme: Theme):
	var line_edit_normal = _create_panel_style(Color("#0E1117"), Color("#2D3139"), 4, 1)
	var line_edit_focus = _create_panel_style(Color("#161A23"), Color("#58A6FF"), 4, 2)
	theme.set_stylebox("normal", "LineEdit", line_edit_normal)
	theme.set_stylebox("focus", "LineEdit", line_edit_focus)
	theme.set_color("font_color", "LineEdit", Color("#E6EDF3"))
	theme.set_color("font_placeholder_color", "LineEdit", Color("#6E7781"))

func _create_button_style(bg_color: Color, border_color: Color, corner_radius: int = 8, border_width: int = 1, shadow: Dictionary = {}) -> StyleBoxFlat:
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
	# 更大的内边距，使按钮更明显
	style.content_margin_left = 32
	style.content_margin_right = 32
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	if shadow.has("shadow_color"):
		style.shadow_color = shadow.shadow_color
		style.shadow_size = shadow.shadow_size
		style.shadow_offset = shadow.shadow_offset
	return style

func _create_panel_style(bg_color: Color, border_color: Color, corner_radius: int = 6, border_width: int = 1, shadow: Dictionary = {}) -> StyleBoxFlat:
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
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 24
	style.content_margin_bottom = 24
	if shadow.has("shadow_color"):
		style.shadow_color = shadow.shadow_color
		style.shadow_size = shadow.shadow_size
		style.shadow_offset = shadow.shadow_offset
	return style

func _shadow_sm() -> Dictionary:
	return {"shadow_color": Color(0, 0, 0, 0.25), "shadow_size": 4, "shadow_offset": Vector2(0, 2)}

func _shadow_md() -> Dictionary:
	return {"shadow_color": Color(0, 0, 0, 0.35), "shadow_size": 8, "shadow_offset": Vector2(0, 4)}
