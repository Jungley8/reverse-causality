class_name ColorPalette
extends Object

## 配色系统
## 暖色学术主题（琥珀金 + 暖绿 + 砖红）

# === 背景层级（Backgrounds） ===
const BG_BASE = Color("#0A0D12")        # 最深背景（纯黑）
const BG_SURFACE = Color("#0E1117")     # 主要表面（深灰棕）
const BG_ELEVATED = Color("#161A23")    # 抬升表面（抬升卡片）
const BG_OVERLAY = Color("#1E232E")     # 叠加层（悬停背景）

# === 边框/分割线（Borders） ===
const BORDER_SUBTLE = Color("#3D3832")   # 微弱边框（暖灰）
const BORDER_DEFAULT = Color("#483F38")  # 默认边框
const BORDER_STRONG = Color("#5A4E45")   # 强边框
const BORDER_ACCENT = Color("#6B5D54")   # 强调边框

# === 文本层级（Text） ===
const TEXT_PRIMARY = Color("#FAF6F0")    # 主要文本（高对比米白）
const TEXT_SECONDARY = Color("#B8B0A4")  # 次要文本（暖灰）
const TEXT_TERTIARY = Color("#8B8378")   # 三级文本（更暗的灰）
const TEXT_DISABLED = Color("#6B6360")   # 禁用文本
const TEXT_INVERSE = Color("#0A0D12")    # 反色文本（用于强按钮）

# === 功能色（Functional） ===
# 成功/因果强 - 暖绿
const SUCCESS_DEFAULT = Color("#4A9C5C")
const SUCCESS_EMPHASIS = Color("#5CB871")  # 悬停
const SUCCESS_MUTED = Color("#2D7A42")     # 弱化
const SUCCESS_SUBTLE = Color("#1A4D2B")    # 背景

# 警告/因果中等 - 琥珀金
const WARNING_DEFAULT = Color("#D4A84B")
const WARNING_EMPHASIS = Color("#E5BE60")
const WARNING_MUTED = Color("#B8923E")
const WARNING_SUBTLE = Color("#5A3F0F")

# 错误/危险 - 砖红
const DANGER_DEFAULT = Color("#C94A4A")
const DANGER_EMPHASIS = Color("#DD6B6B")
const DANGER_MUTED = Color("#A03A3A")
const DANGER_SUBTLE = Color("#4A1816")

# 信息/中性 - 柔和蓝
const INFO_DEFAULT = Color("#7EB8E8")
const INFO_EMPHASIS = Color("#A0CFF0")
const INFO_MUTED = Color("#5A8BA8")
const INFO_SUBTLE = Color("#1A3A5A")

# === 点缀色（Accent） ===
const ACCENT_CYAN = Color("#76E3EA")      # 科技感
const ACCENT_PURPLE = Color("#BC8CFF")    # 神秘感
const ACCENT_GOLD = Color("#E3B341")      # 高级感（S级评价）

# === 半透明层（Overlays） ===
const OVERLAY_DARK_10 = Color(0, 0, 0, 0.1)
const OVERLAY_DARK_30 = Color(0, 0, 0, 0.3)
const OVERLAY_DARK_50 = Color(0, 0, 0, 0.5)
const OVERLAY_DARK_80 = Color(0, 0, 0, 0.8)

const OVERLAY_LIGHT_10 = Color(1, 1, 1, 0.1)
const OVERLAY_LIGHT_20 = Color(1, 1, 1, 0.2)
const OVERLAY_LIGHT_30 = Color(1, 1, 1, 0.3)

# === 组件颜色映射 ===
# CauseCard
const CARD_BG_NORMAL = BG_ELEVATED
const CARD_BG_HOVER = BG_OVERLAY
const CARD_BG_ACTIVE = BG_SURFACE
const CARD_BORDER_NORMAL = BORDER_DEFAULT
const CARD_BORDER_HOVER = BORDER_ACCENT
const CARD_BORDER_FOCUS = SUCCESS_DEFAULT

# ChainSlot
const SLOT_BG_EMPTY = BG_SURFACE
const SLOT_BG_VALID = SUCCESS_SUBTLE
const SLOT_BG_INVALID = DANGER_SUBTLE
const SLOT_BORDER_EMPTY = BORDER_SUBTLE
const SLOT_BORDER_VALID = SUCCESS_DEFAULT
const SLOT_BORDER_INVALID = DANGER_DEFAULT

# Button - 主按钮改为绿色
const BUTTON_PRIMARY_BG = SUCCESS_DEFAULT
const BUTTON_PRIMARY_HOVER = SUCCESS_EMPHASIS
const BUTTON_PRIMARY_ACTIVE = SUCCESS_MUTED
const BUTTON_SECONDARY_BG = BG_ELEVATED
const BUTTON_SECONDARY_HOVER = BG_OVERLAY
