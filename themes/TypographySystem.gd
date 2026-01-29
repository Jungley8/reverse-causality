class_name TypographySystem
extends Object

## 字体系统
## 定义字阶、字重、行高、字间距

# === 字阶定义 ===
const FONT_SIZE_DISPLAY = 52      # 大标题（主菜单游戏名）
const FONT_SIZE_H1 = 36           # 一级标题
const FONT_SIZE_H2 = 28           # 二级标题
const FONT_SIZE_H3 = 24           # 三级标题
const FONT_SIZE_BODY_LARGE = 20   # 正文大（主要内容）
const FONT_SIZE_BODY = 18         # 正文（按钮、卡片）
const FONT_SIZE_BODY_SMALL = 16   # 正文小
const FONT_SIZE_CAPTION = 14      # 说明文字

# === 字重 ===
# 注：Godot需要导入不同字重的字体文件
const WEIGHT_LIGHT = "Light"      # 300
const WEIGHT_REGULAR = "Regular"  # 400
const WEIGHT_MEDIUM = "Medium"    # 500
const WEIGHT_SEMIBOLD = "SemiBold" # 600
const WEIGHT_BOLD = "Bold"        # 700

# === 行高系数 ===
const LINE_HEIGHT_TIGHT = 1.2     # 紧凑（标题）
const LINE_HEIGHT_NORMAL = 1.5    # 正常（正文）
const LINE_HEIGHT_RELAXED = 1.8   # 宽松（长文本）

# === 字间距 ===
const LETTER_SPACING_TIGHT = -0.5
const LETTER_SPACING_NORMAL = 0.0
const LETTER_SPACING_WIDE = 1.0
