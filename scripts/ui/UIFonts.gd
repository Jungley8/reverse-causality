extends Node

## UIFonts - 统一字体管理
## 解决中文字体渲染问题的核心模块
##
## 用法：
##   var settings = UIFonts.get_label_settings("h1")
##   label.label_settings = settings
##
##   # 或者直接应用到 Label
##   UIFonts.apply_to_label(label, "body")

# === 字体大小定义 ===
class SIZES:
	const DISPLAY = 52    # 游戏标题
	const H1 = 36         # 一级标题
	const H2 = 28         # 二级标题
	const H3 = 24         # 三级标题
	const BODY_LG = 22    # 正文大（卡片文字）
	const BODY = 20       # 正文（按钮、主要内容）
	const BODY_SM = 18    # 正文小
	const CAPTION = 16    # 说明文字
	const SMALL = 14      # 小字

# === 字重定义 ===
class WEIGHTS:
	const REGULAR = 400
	const MEDIUM = 500
	const SEMIBOLD = 600
	const BOLD = 700

# 字体文件路径
const FONT_PATH = "res://NotoSansSC-VariableFont_wght.ttf"

# 缓存
var _font: Font = null
var _label_settings_cache: Dictionary = {}

func _ready():
	_load_font()

# === 加载字体 ===
func _load_font():
	if ResourceLoader.exists(FONT_PATH):
		_font = load(FONT_PATH)
		print("✅ UIFonts: 字体已加载 - ", FONT_PATH)
	else:
		push_error("❌ UIFonts: 字体文件不存在 - ", FONT_PATH)
		_font = ThemeDB.fallback_font

# === 获取字体 ===
func get_font() -> Font:
	if not _font:
		_load_font()
	return _font

# === 获取 LabelSettings ===
## 返回预配置的 LabelSettings，包含正确的字体、大小、颜色
## preset: "display", "h1", "h2", "h3", "body_lg", "body", "body_sm", "caption", "small"
## color: 可选，覆盖默认颜色
func get_label_settings(preset: String, color: Color = Color(-1, -1, -1, -1)) -> LabelSettings:
	# 检查缓存（只缓存默认颜色的）
	var cache_key = preset if color.a < 0 else ""
	if cache_key and _label_settings_cache.has(cache_key):
		return _label_settings_cache[cache_key]
	
	var settings = LabelSettings.new()
	settings.font = get_font()
	
	# 设置字体大小和字重
	match preset:
		"display":
			settings.font_size = SIZES.DISPLAY
		"h1":
			settings.font_size = SIZES.H1
		"h2":
			settings.font_size = SIZES.H2
		"h3":
			settings.font_size = SIZES.H3
		"body_lg":
			settings.font_size = SIZES.BODY_LG
		"body":
			settings.font_size = SIZES.BODY
		"body_sm":
			settings.font_size = SIZES.BODY_SM
		"caption":
			settings.font_size = SIZES.CAPTION
		"small":
			settings.font_size = SIZES.SMALL
		_:
			settings.font_size = SIZES.BODY
	
	# 设置颜色
	if color.a >= 0:
		settings.font_color = color
	else:
		# 使用默认颜色（从 UITokens 获取，如果可用）
		if has_node("/root/UITokens"):
			var tokens = get_node("/root/UITokens")
			settings.font_color = tokens.COLOR.TEXT_PRIMARY
		else:
			settings.font_color = Color("#FAF6F0")  # 高对比米白
	
	# 中文友好的渲染设置
	# 轮廓：增加清晰度（可选，根据需要调整）
	# settings.outline_size = 0
	# settings.outline_color = Color(0, 0, 0, 0.3)
	
	# 阴影：增加对比度（可选）
	settings.shadow_size = 1
	settings.shadow_color = Color(0, 0, 0, 0.3)
	settings.shadow_offset = Vector2(1, 1)
	
	# 缓存
	if cache_key:
		_label_settings_cache[cache_key] = settings
	
	return settings

# === 应用到 Label ===
## 将字体设置应用到 Label 节点
func apply_to_label(label: Label, preset: String = "body", color: Color = Color(-1, -1, -1, -1)):
	if not label:
		return
	
	label.label_settings = get_label_settings(preset, color)

# === 应用到 Button ===
## 将字体设置应用到 Button 节点
func apply_to_button(button: Button, size: int = SIZES.BODY):
	if not button:
		return
	
	button.add_theme_font_override("font", get_font())
	button.add_theme_font_size_override("font_size", size)

# === 应用到 RichTextLabel ===
func apply_to_rich_text(rtl: RichTextLabel, size: int = SIZES.BODY):
	if not rtl:
		return
	
	rtl.add_theme_font_override("normal_font", get_font())
	rtl.add_theme_font_size_override("normal_font_size", size)

# === 清除缓存（主题更改时调用） ===
func clear_cache():
	_label_settings_cache.clear()
