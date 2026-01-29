extends RefCounted

## 主题管理器
## 统一管理UI主题和样式（静态工具类）

class_name ThemeManager

static var default_theme: Theme
static var current_theme: Theme
static var is_loaded: bool = false

# === 初始化 ===
static func initialize():
	if not is_loaded:
		load_theme()
		is_loaded = true

static func load_theme(path: String = "res://themes/default_theme.tres"):
	if ResourceLoader.exists(path):
		default_theme = load(path)
		current_theme = default_theme
		print("✅ 主题已加载：", path)
	else:
		push_warning("⚠️ 主题文件不存在：", path, " - 请运行 GenerateTheme.gd 生成主题文件")
		# 创建一个基础主题作为回退
		default_theme = Theme.new()
		current_theme = default_theme
		# 设置基础颜色
		default_theme.set_color("font_color", "Label", Color("#E6EDF3"))
		default_theme.set_font_size("font_size", "Label", 16)

# === 应用主题 ===
static func apply_theme_to_node(node: Node):
	if node is Control:
		node.theme = current_theme

static func apply_theme_to_scene(scene: Node):
	if not current_theme:
		initialize()
	_apply_recursive(scene)

static func _apply_recursive(node: Node):
	if node is Control:
		node.theme = current_theme
		if node.get_parent() == null or not (node.get_parent() is Control):
			if node.has_method("set_background_color"):
				node.set_background_color(Color("#0f0e0c"))
	
	for child in node.get_children():
		_apply_recursive(child)

# === 获取颜色（向后兼容） ===
static func get_color(color_name: String) -> Color:
	# 向后兼容旧的颜色名称
	# 直接使用后备颜色值（避免 ColorPalette 类加载问题）
	return _get_color_direct(color_name)

# 直接颜色值（暖色学术主题：琥珀金 + 暖绿 + 砖红）
static func _get_color_direct(color_name: String) -> Color:
	match color_name:
		"background": return Color("#0E1117")      # 主表面
		"surface": return Color("#0E1117")         # 表面底
		"surface_raised": return Color("#161A23") # 抬升区域
		"text_primary": return Color("#FAF6F0")    # 主文本（高对比米白）
		"primary_text": return Color("#FAF6F0")
		"secondary_text": return Color("#B8B0A4")  # 次要文本（暖灰）
		"accent": return Color("#D4A84B")          # 琥珀金强调
		"accent_dim": return Color("#B8923E")
		"causal_strong": return Color("#4A9C5C")  # 暖绿（成功）
		"causal_weak": return Color("#D4A84B")    # 琥珀金（警告）
		"error": return Color("#C94A4A")           # 砖红（失败）
		"success": return Color("#4A9C5C")
		"warning": return Color("#D4A84B")
		"danger": return Color("#C94A4A")
		"info": return Color("#7EB8E8")            # 柔和蓝
		_:
			push_warning("未知颜色名称：", color_name)
			return Color.WHITE

# === 获取 StyleBox ===
static func get_button_style(variant: String = "primary", state: String = "normal") -> StyleBox:
	if not current_theme:
		initialize()
	
	var type_name = "Button"
	if variant != "":
		# 手动首字母大写
		type_name = "Button" + variant.substr(0, 1).to_upper() + variant.substr(1)
	
	return current_theme.get_stylebox(state, type_name)

static func get_panel_style(variant: String = "default") -> StyleBox:
	if not current_theme:
		initialize()
	
	var type_name = "Panel"
	if variant != "default":
		# 手动首字母大写
		type_name = "Panel" + variant.substr(0, 1).to_upper() + variant.substr(1)
	
	return current_theme.get_stylebox("panel", type_name)

# === 创建自定义样式 ===
static func create_card_style(is_distractor: bool = false) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	
	if is_distractor:
		style.bg_color = Color("#1e1616")
		style.border_color = Color("#c94a4a")
	else:
		style.bg_color = Color("#1a1814")
		style.border_color = Color("#3d3832")
	
	# 更粗的边框
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	# 更大的圆角
	apply_stylebox_corner_radius(style, 10)
	
	# 应用更明显的阴影
	var shadow = _shadow_md()
	style.shadow_color = shadow.shadow_color
	style.shadow_size = shadow.shadow_size
	style.shadow_offset = shadow.shadow_offset
	
	# 内边距
	var padding = 20  # 更大的内边距
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding
	style.content_margin_bottom = padding
	
	return style

static func create_slot_style(state: String = "empty") -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	
	var border_width = 2  # 默认更粗的边框
	match state:
		"empty":
			style.bg_color = Color("#141210")
			style.border_color = Color("#3d3832")
			style.draw_center = false
			border_width = 2
		"filled":
			style.bg_color = Color("#242019")
			style.border_color = Color("#7eb8e8")
			border_width = 3
		"hover_valid":
			style.bg_color = Color("#1a2e1e")
			style.border_color = Color("#4a9c5c")
			border_width = 3
			style.shadow_color = Color(74, 156, 92, 0.35)
			style.shadow_size = 8
			style.shadow_offset = Vector2(0, 0)
		"hover_invalid":
			style.bg_color = Color("#2e1a1a")
			style.border_color = Color("#c94a4a")
			border_width = 3
			style.shadow_color = Color(201, 74, 74, 0.35)
			style.shadow_size = 8
			style.shadow_offset = Vector2(0, 0)
	
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	
	# 更大的圆角
	apply_stylebox_corner_radius(style, 10)
	
	var padding = 20  # 更大的内边距
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding
	style.content_margin_bottom = padding
	
	return style

# === 辅助扩展方法 ===
static func apply_stylebox_corner_radius(style: StyleBoxFlat, radius: int):
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius

# 阴影辅助方法（避免依赖 ShadowSystem）
static func _shadow_sm() -> Dictionary:
	return {"shadow_color": Color(0, 0, 0, 0.25), "shadow_size": 4, "shadow_offset": Vector2(0, 2)}

static func _shadow_md() -> Dictionary:
	return {"shadow_color": Color(0, 0, 0, 0.35), "shadow_size": 8, "shadow_offset": Vector2(0, 4)}
