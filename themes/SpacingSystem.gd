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
const SPACING_XXXL = 64    # 16 units

# === 组件特定间距 ===
const CARD_PADDING = 20            # 卡片内边距
const CARD_MARGIN = SPACING_MD     # 卡片外间距 16px
const BUTTON_PADDING_H = SPACING_LG  # 水平内边距 24px
const BUTTON_PADDING_V = SPACING_SM  # 垂直内边距 12px
const PANEL_PADDING = 40           # 页面内边距
const GRID_GAP = 16                # 网格间距 16px

# === 颜色元素 ===
const PAGE_PADDING = 40      # 页面稍后稍右边距
const SECTION_SPACING = 32   # 博上下章节间距
const COMPONENT_SPACING = 24 # 主要组件间距
const ITEM_SPACING = 16      # 项目中间距
