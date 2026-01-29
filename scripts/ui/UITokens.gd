extends Node

## UITokens - 设计令牌
## 所有视觉常量的唯一来源
##
## 用法：
##   var bg = UITokens.COLOR.BG_BASE
##   var spacing = UITokens.SPACING.MD

# === 颜色令牌 ===
class COLOR:
	# 背景层级
	const BG_BASE = Color("#0A0D12")        # 最深背景
	const BG_SURFACE = Color("#0E1117")     # 主表面
	const BG_ELEVATED = Color("#161A23")    # 抬升表面（卡片、面板）
	const BG_OVERLAY = Color("#1E232E")     # 叠加层（悬停）
	
	# 文本层级
	const TEXT_PRIMARY = Color("#FAF6F0")   # 主要文本（高对比米白）
	const TEXT_SECONDARY = Color("#B8B0A4") # 次要文本（暖灰）
	const TEXT_TERTIARY = Color("#8B8378")  # 三级文本
	const TEXT_DISABLED = Color("#6B6360")  # 禁用文本
	const TEXT_INVERSE = Color("#0A0D12")   # 反色文本（用于亮色按钮）
	
	# 边框层级
	const BORDER_SUBTLE = Color("#3D3832")  # 微弱边框
	const BORDER_DEFAULT = Color("#483F38") # 默认边框
	const BORDER_STRONG = Color("#5A4E45")  # 强边框
	const BORDER_ACCENT = Color("#6B5D54")  # 强调边框
	
	# 功能色 - 成功/暖绿
	const SUCCESS = Color("#4A9C5C")
	const SUCCESS_HOVER = Color("#5CB871")
	const SUCCESS_MUTED = Color("#2D7A42")
	const SUCCESS_SUBTLE = Color("#1A4D2B")
	
	# 功能色 - 警告/琥珀金
	const WARNING = Color("#D4A84B")
	const WARNING_HOVER = Color("#E5BE60")
	const WARNING_MUTED = Color("#B8923E")
	const WARNING_SUBTLE = Color("#5A3F0F")
	
	# 功能色 - 错误/砖红
	const DANGER = Color("#C94A4A")
	const DANGER_HOVER = Color("#DD6B6B")
	const DANGER_MUTED = Color("#A03A3A")
	const DANGER_SUBTLE = Color("#4A1816")
	
	# 功能色 - 信息/柔和蓝
	const INFO = Color("#7EB8E8")
	const INFO_HOVER = Color("#A0CFF0")
	const INFO_MUTED = Color("#5A8BA8")
	const INFO_SUBTLE = Color("#1A3A5A")
	
	# 点缀色
	const ACCENT_GOLD = Color("#E3B341")    # S级评价
	const ACCENT_SILVER = Color("#C0C0C0")  # A级评价
	const ACCENT_BRONZE = Color("#CD7F32")  # B级评价

# === 间距令牌 ===
class SPACING:
	const NONE = 0
	const XXS = 4
	const XS = 8
	const SM = 12
	const MD = 16
	const LG = 24
	const XL = 32
	const XXL = 48
	const XXXL = 64

# === 圆角令牌 ===
class RADIUS:
	const NONE = 0
	const SM = 4
	const MD = 8
	const LG = 12
	const XL = 16
	const FULL = 9999  # 完全圆角

# === 阴影令牌 ===
class SHADOW:
	# 返回 Dictionary: {color, size, offset}
	static func none() -> Dictionary:
		return {"color": Color(0, 0, 0, 0), "size": 0, "offset": Vector2.ZERO}
	
	static func sm() -> Dictionary:
		return {"color": Color(0, 0, 0, 0.15), "size": 2, "offset": Vector2(0, 1)}
	
	static func md() -> Dictionary:
		return {"color": Color(0, 0, 0, 0.25), "size": 6, "offset": Vector2(0, 3)}
	
	static func lg() -> Dictionary:
		return {"color": Color(0, 0, 0, 0.35), "size": 12, "offset": Vector2(0, 6)}
	
	# 发光效果（用于悬停）
	static func glow(base_color: Color, intensity: float = 0.35) -> Dictionary:
		var glow_color = base_color
		glow_color.a = intensity
		return {"color": glow_color, "size": 10, "offset": Vector2.ZERO}

# === 边框宽度令牌 ===
class BORDER:
	const NONE = 0
	const THIN = 1
	const DEFAULT = 2
	const THICK = 3

# === 动画令牌 ===
class ANIMATION:
	const DURATION_FAST = 0.1
	const DURATION_NORMAL = 0.2
	const DURATION_SLOW = 0.3
	
	const EASE_DEFAULT = Tween.EASE_OUT
	const TRANS_DEFAULT = Tween.TRANS_QUAD

# === 尺寸令牌 ===
class SIZE:
	# 卡片
	const CARD_MIN_WIDTH = 180
	const CARD_MIN_HEIGHT = 100
	const CARD_PADDING = 20
	
	# 槽位
	const SLOT_MIN_WIDTH = 180
	const SLOT_MIN_HEIGHT = 100
	
	# 按钮
	const BUTTON_MIN_HEIGHT = 52
	const BUTTON_PADDING_H = 32
	const BUTTON_PADDING_V = 14
	
	# 页面
	const PAGE_PADDING = 40
