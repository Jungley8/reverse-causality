class_name ColorPalette
extends Object

## 配色系统
## Dark Academic 主题的完整配色方案

# === 背景层级（Backgrounds） ===
const BG_BASE = Color("#0A0D12")        # 最深背景
const BG_SURFACE = Color("#0E1117")     # 主要表面
const BG_ELEVATED = Color("#161A23")    # 抬升表面
const BG_OVERLAY = Color("#1E232E")     # 叠加层

# === 边框/分割线（Borders） ===
const BORDER_SUBTLE = Color("#1C2128")   # 微弱边框
const BORDER_DEFAULT = Color("#2D3139")  # 默认边框
const BORDER_STRONG = Color("#3D4149")   # 强边框
const BORDER_ACCENT = Color("#484F58")   # 强调边框

# === 文本层级（Text） ===
const TEXT_PRIMARY = Color("#E6EDF3")    # 主要文本
const TEXT_SECONDARY = Color("#9EA7B3")  # 次要文本
const TEXT_TERTIARY = Color("#6E7781")   # 三级文本
const TEXT_DISABLED = Color("#484F58")   # 禁用文本
const TEXT_INVERSE = Color("#0A0D12")    # 反色文本（用于强调按钮）

# === 功能色（Functional） ===
# 成功/因果强
const SUCCESS_DEFAULT = Color("#3FB950")
const SUCCESS_EMPHASIS = Color("#4AC45A")  # 悬停
const SUCCESS_MUTED = Color("#2D8A3E")     # 弱化
const SUCCESS_SUBTLE = Color("#1C4D2B")    # 背景

# 警告/因果中等
const WARNING_DEFAULT = Color("#D29922")
const WARNING_EMPHASIS = Color("#E5A82E")
const WARNING_MUTED = Color("#9E7419")
const WARNING_SUBTLE = Color("#4A3410")

# 错误/危险
const DANGER_DEFAULT = Color("#F85149")
const DANGER_EMPHASIS = Color("#FF6B62")
const DANGER_MUTED = Color("#C93A31")
const DANGER_SUBTLE = Color("#4A1C18")

# 信息/中性
const INFO_DEFAULT = Color("#58A6FF")
const INFO_EMPHASIS = Color("#79C0FF")
const INFO_MUTED = Color("#388BFD")
const INFO_SUBTLE = Color("#0D3A66")

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
const CARD_BORDER_FOCUS = INFO_DEFAULT

# ChainSlot
const SLOT_BG_EMPTY = BG_SURFACE
const SLOT_BG_VALID = SUCCESS_SUBTLE
const SLOT_BG_INVALID = DANGER_SUBTLE
const SLOT_BORDER_EMPTY = BORDER_SUBTLE
const SLOT_BORDER_VALID = SUCCESS_DEFAULT
const SLOT_BORDER_INVALID = DANGER_DEFAULT

# Button
const BUTTON_PRIMARY_BG = INFO_DEFAULT
const BUTTON_PRIMARY_HOVER = INFO_EMPHASIS
const BUTTON_PRIMARY_ACTIVE = INFO_MUTED
const BUTTON_SECONDARY_BG = BG_ELEVATED
const BUTTON_SECONDARY_HOVER = BG_OVERLAY
