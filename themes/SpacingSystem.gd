class_name SpacingSystem
extends Object

## 间距系统
## 所有间距都是基础单位的倍数

# === 基础单位 ===
const UNIT = 4  # 所有间距都是4的倍数

# === 间距等级 ===
const SPACING_NONE = 0
const SPACING_XXS = 4      # 1 unit
const SPACING_XS = 8       # 2 units
const SPACING_SM = 12      # 3 units
const SPACING_MD = 16      # 4 units （默认）
const SPACING_LG = 24      # 6 units
const SPACING_XL = 32      # 8 units
const SPACING_XXL = 48     # 12 units
const SPACING_XXXL = 64   # 16 units

# === 组件特定间距 ===
const CARD_PADDING = SPACING_MD
const CARD_MARGIN = SPACING_SM
const BUTTON_PADDING_H = SPACING_LG  # 水平内边距
const BUTTON_PADDING_V = SPACING_SM  # 垂直内边距
const PANEL_PADDING = SPACING_LG
const GRID_GAP = SPACING_MD
