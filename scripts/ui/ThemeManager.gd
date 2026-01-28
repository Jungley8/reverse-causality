extends RefCounted

## 主题管理器
## 统一管理UI主题和样式（静态工具类）

class_name ThemeManager

## 颜色方案（参考m1.md）
const COLOR_BACKGROUND = Color(0.05490196, 0.06666667, 0.09019608, 1)  # #0E1117
const COLOR_TEXT_PRIMARY = Color(0.90196078, 0.92941176, 0.95294118, 1)  # #E6EDF3
const COLOR_CAUSAL_STRONG = Color(0.24705882, 0.72941176, 0.31372549, 1)  # #3FB950
const COLOR_CAUSAL_WEAK = Color(0.82352941, 0.6, 0.13333333, 1)  # #D29922
const COLOR_ERROR = Color(0.97254902, 0.31764706, 0.28627451, 1)  # #F85149

## 应用主题到节点
static func apply_theme_to_button(button: Button):
	if not button:
		return
	
	# 设置基础样式
	button.add_theme_color_override("font_color", COLOR_TEXT_PRIMARY)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color(0.8, 0.8, 0.8))
	
	# 添加悬停效果（通过脚本实现）
	button.mouse_entered.connect(func(): _on_button_hover(button, true))
	button.mouse_exited.connect(func(): _on_button_hover(button, false))

static func _on_button_hover(button: Button, is_hovering: bool):
	if not button:
		return
	
	var tween = button.create_tween()
	if is_hovering:
		tween.tween_property(button, "modulate", Color(1.1, 1.1, 1.1), 0.2)
	else:
		tween.tween_property(button, "modulate", Color.WHITE, 0.2)

## 应用主题到标签
static func apply_theme_to_label(label: Label):
	if not label:
		return
	
	label.add_theme_color_override("font_color", COLOR_TEXT_PRIMARY)

## 应用主题到面板
static func apply_theme_to_panel(panel: PanelContainer):
	if not panel:
		return
	
	# 设置背景色
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.1, 0.12, 0.15, 0.8)
	style_box.border_color = Color(0.2, 0.2, 0.25, 1.0)
	style_box.border_width_left = 1
	style_box.border_width_top = 1
	style_box.border_width_right = 1
	style_box.border_width_bottom = 1
	style_box.corner_radius_top_left = 4
	style_box.corner_radius_top_right = 4
	style_box.corner_radius_bottom_left = 4
	style_box.corner_radius_bottom_right = 4
	
	panel.add_theme_stylebox_override("panel", style_box)

## 获取颜色
static func get_color(name: String) -> Color:
	match name:
		"background": return COLOR_BACKGROUND
		"text_primary": return COLOR_TEXT_PRIMARY
		"causal_strong": return COLOR_CAUSAL_STRONG
		"causal_weak": return COLOR_CAUSAL_WEAK
		"error": return COLOR_ERROR
		_: return Color.WHITE
