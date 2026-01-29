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
	# Primary Button - 暖绿强调（成功色、验证按钮）
	var btn_primary_normal = _create_button_style(Color("#4A9C5C"), Color("#2D7A42"), 12, 2)
	btn_primary_normal.shadow_color = Color(0, 0, 0, 0.25)
	btn_primary_normal.shadow_size = 4
	btn_primary_normal.shadow_offset = Vector2(0, 2)
	
	var btn_primary_hover = _create_button_style(Color("#5CB871"), Color("#4A9C5C"), 12, 2, _shadow_md())
	btn_primary_hover.shadow_color = Color(74, 156, 92, 0.35)
	btn_primary_hover.shadow_size = 8
	btn_primary_hover.shadow_offset = Vector2(0, 3)
	
	var btn_primary_pressed = _create_button_style(Color("#2D7A42"), Color("#1A5A2D"), 12, 2)
	btn_primary_pressed.shadow_color = Color(0, 0, 0, 0.2)
	btn_primary_pressed.shadow_size = 2
	btn_primary_pressed.shadow_offset = Vector2(0, 1)
	
	var btn_primary_disabled = _create_button_style(Color("#1a1814"), Color("#3d3832"), 12, 1)
	
	theme.set_stylebox("normal", "ButtonPrimary", btn_primary_normal)
	theme.set_stylebox("hover", "ButtonPrimary", btn_primary_hover)
	theme.set_stylebox("pressed", "ButtonPrimary", btn_primary_pressed)
	theme.set_stylebox("disabled", "ButtonPrimary", btn_primary_disabled)
	
	theme.set_color("font_color", "ButtonPrimary", Color("#FAF6F0"))
	theme.set_color("font_hover_color", "ButtonPrimary", Color("#FFFFFF"))
	theme.set_color("font_pressed_color", "ButtonPrimary", Color("#FAF6F0"))
	theme.set_color("font_disabled_color", "ButtonPrimary", Color("#665a4a"))
	theme.set_font_size("font_size", "ButtonPrimary", 20)
	
	# Secondary Button - 暖灰边框
	var btn_secondary_normal = _create_button_style(Color("#1a1814"), Color("#3d3832"), 12, 2)
	btn_secondary_normal.shadow_color = Color(0, 0, 0, 0.15)
	btn_secondary_normal.shadow_size = 3
	btn_secondary_normal.shadow_offset = Vector2(0, 2)
	
	var btn_secondary_hover = _create_button_style(Color("#242019"), Color("#7eb8e8"), 12, 2, _shadow_md())
	btn_secondary_hover.shadow_color = Color(0, 0, 0, 0.25)
	btn_secondary_hover.shadow_size = 6
	btn_secondary_hover.shadow_offset = Vector2(0, 3)
	
	theme.set_stylebox("normal", "ButtonSecondary", btn_secondary_normal)
	theme.set_stylebox("hover", "ButtonSecondary", btn_secondary_hover)
	theme.set_stylebox("pressed", "ButtonSecondary", btn_secondary_normal)
	theme.set_stylebox("disabled", "ButtonSecondary", btn_primary_disabled)
	
	theme.set_color("font_color", "ButtonSecondary", Color("#f0ebe3"))
	theme.set_color("font_hover_color", "ButtonSecondary", Color("#f0ebe3"))
	theme.set_font_size("font_size", "ButtonSecondary", 18)
	
	# Default Button
	theme.set_stylebox("normal", "Button", btn_secondary_normal)
	theme.set_stylebox("hover", "Button", btn_secondary_hover)
	theme.set_stylebox("pressed", "Button", btn_secondary_normal)
	theme.set_stylebox("disabled", "Button", btn_primary_disabled)
	theme.set_color("font_color", "Button", Color("#f0ebe3"))
	theme.set_font_size("font_size", "Button", 18)

func _setup_labels(theme: Theme):
	# Label - 正文
	theme.set_color("font_color", "Label", Color("#FAF6F0"))
	theme.set_font_size("font_size", "Label", 18)
	
	# LabelH1 - 一级标题
	theme.set_color("font_color", "LabelH1", Color("#FAF6F0"))
	theme.set_font_size("font_size", "LabelH1", 36)
	
	# LabelH2 - 二级标题
	theme.set_color("font_color", "LabelH2", Color("#FAF6F0"))
	theme.set_font_size("font_size", "LabelH2", 28)
	
	# LabelSecondary - 次要文本
	theme.set_color("font_color", "LabelSecondary", Color("#B8B0A4"))
	theme.set_font_size("font_size", "LabelSecondary", 16)
	
	# LabelCaption - 说明文字
	theme.set_color("font_color", "LabelCaption", Color("#8B8378"))
	theme.set_font_size("font_size", "LabelCaption", 14)

func _setup_panels(theme: Theme):
	# PanelContainer
	var panel_card = _create_panel_style(Color("#1a1814"), Color("#3d3832"), 10, 2, _shadow_md())
	panel_card.shadow_color = Color(0, 0, 0, 0.25)
	panel_card.shadow_size = 6
	panel_card.shadow_offset = Vector2(0, 3)
	theme.set_stylebox("panel", "PanelContainer", panel_card)
	
	# Panel - 基础面板（暖灰）
	var panel_base = _create_panel_style(Color("#141210"), Color("#3d3832"), 8, 1)
	panel_base.shadow_color = Color(0, 0, 0, 0.15)
	panel_base.shadow_size = 2
	panel_base.shadow_offset = Vector2(0, 1)
	theme.set_stylebox("panel", "Panel", panel_base)
	
	# PanelElevated - 抬升区域（因果链/候选区）
	var panel_elevated = _create_panel_style(Color("#242019"), Color("#624736"), 12, 2, _shadow_md())
	panel_elevated.shadow_color = Color(0, 0, 0, 0.3)
	panel_elevated.shadow_size = 8
	panel_elevated.shadow_offset = Vector2(0, 4)
	theme.set_stylebox("panel", "PanelElevated", panel_elevated)

func _setup_progress_bars(theme: Theme):
	var progress_bg = StyleBoxFlat.new()
	progress_bg.bg_color = Color("#242019")
	progress_bg.corner_radius_top_left = 6
	progress_bg.corner_radius_top_right = 6
	progress_bg.corner_radius_bottom_left = 6
	progress_bg.corner_radius_bottom_right = 6
	progress_bg.border_width_left = 1
	progress_bg.border_width_top = 1
	progress_bg.border_width_right = 1
	progress_bg.border_width_bottom = 1
	progress_bg.border_color = Color("#3d3832")
	
	var progress_fill = StyleBoxFlat.new()
	progress_fill.bg_color = Color("#D4A84B")
	progress_fill.corner_radius_top_left = 6
	progress_fill.corner_radius_top_right = 6
	progress_fill.corner_radius_bottom_left = 6
	progress_fill.corner_radius_bottom_right = 6
	
	theme.set_stylebox("background", "ProgressBar", progress_bg)
	theme.set_stylebox("fill", "ProgressBar", progress_fill)
	theme.set_color("font_color", "ProgressBar", Color("#f0ebe3"))
	theme.set_font_size("font_size", "ProgressBar", 15)

func _setup_line_edits(theme: Theme):
	var line_edit_normal = _create_panel_style(Color("#141210"), Color("#3d3832"), 4, 1)
	var line_edit_focus = _create_panel_style(Color("#242019"), Color("#7eb8e8"), 4, 2)
	theme.set_stylebox("normal", "LineEdit", line_edit_normal)
	theme.set_stylebox("focus", "LineEdit", line_edit_focus)
	theme.set_color("font_color", "LineEdit", Color("#f0ebe3"))
	theme.set_color("font_placeholder_color", "LineEdit", Color("#9c958a"))

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
