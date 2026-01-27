# 🎮《逆果溯因》完整开发指南
## Web 版本 · 基于 Godot 4.x

**游戏定位**：认知型推理游戏  
**导出目标**：Web（HTML5）  
**开发周期**：3 周 MVP → 6 周完整版

---

# 📋 目录

1. [UI/UX 完整设计](#一uiux-完整设计)
2. [技术实现细节](#二技术实现细节)
3. [游戏流程设计](#三游戏流程设计)
4. [新增机制实现](#四新增机制实现)
5. [开发优先级](#五开发优先级)
6. [Web 优化方案](#六web-优化方案)

---

# 一、UI/UX 完整设计

## 1.1 主菜单界面

### 布局结构
```
┌─────────────────────────────────────┐
│                                     │
│         逆 果 溯 因                  │
│      REVERSE CAUSALITY              │
│                                     │
│     ┌─────────────────┐             │
│     │   开始游戏       │ ←────────   │
│     └─────────────────┘             │
│     ┌─────────────────┐             │
│     │   继续游戏       │             │
│     └─────────────────┘             │
│     ┌─────────────────┐             │
│     │   因果图鉴       │             │
│     └─────────────────┘             │
│                                     │
│            v0.1.0                   │
└─────────────────────────────────────┘
```

### 场景实现（MainMenu.tscn）
```
MainMenu (Control)
 ├─ Background (ColorRect)
 ├─ TitleContainer (VBoxContainer)
 │   ├─ GameTitle (Label)
 │   └─ Subtitle (Label)
 ├─ MenuButtons (VBoxContainer)
 │   ├─ StartButton (Button)
 │   ├─ ContinueButton (Button)
 │   └─ ArchiveButton (Button)
 └─ VersionLabel (Label)
```

### GDScript 控制器
```gdscript
# MainMenu.gd
extends Control

@onready var continue_btn = $MenuButtons/ContinueButton

func _ready():
	# 检查是否有存档
	if not SaveGame.has_save():
		continue_btn.disabled = true
		continue_btn.modulate = Color(0.5, 0.5, 0.5)

func _on_start_pressed():
	SaveGame.reset_progress()
	get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")

func _on_archive_pressed():
	get_tree().change_scene_to_file("res://scenes/Archive.tscn")
```

---

## 1.2 关卡选择界面

### 设计方案（卡片式布局）

```
┌─────────────────────────────────────┐
│  ← 返回                              │
│                                     │
│  选择关卡                            │
│                                     │
│  ┌──────┐  ┌──────┐  ┌──────┐      │
│  │ 01   │  │ 02   │  │ 03   │      │
│  │ ✓    │  │ 🔒   │  │ 🔒   │      │
│  │ S级  │  │      │  │      │      │
│  └──────┘  └──────┘  └──────┘      │
│                                     │
│  城市崩溃  AI禁令    法律人格        │
│                                     │
└─────────────────────────────────────┘
```

### 场景结构
```
LevelSelect (Control)
 ├─ Background (ColorRect)
 ├─ Header (HBoxContainer)
 │   ├─ BackButton (Button)
 │   └─ Title (Label)
 ├─ LevelGrid (GridContainer)
 │   ├─ LevelCard1
 │   ├─ LevelCard2
 │   └─ LevelCard3
 └─ LevelDescription (Panel)
```

### LevelCard 组件设计
```gdscript
# LevelCard.gd
extends PanelContainer

signal level_selected(level_id: int)

@export var level_id: int
@export var level_title: String
@export var is_locked: bool = true

@onready var status_icon = $VBox/StatusIcon
@onready var grade_label = $VBox/GradeLabel
@onready var title_label = $VBox/TitleLabel

func _ready():
	_update_visuals()

func _update_visuals():
	if is_locked:
		modulate = Color(0.4, 0.4, 0.4)
		status_icon.text = "🔒"
		grade_label.text = ""
	else:
		var grade = SaveGame.get_level_grade(level_id)
		if grade:
			status_icon.text = "✓"
			grade_label.text = grade
		else:
			status_icon.text = "○"
			grade_label.text = "未完成"

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if not is_locked:
			level_selected.emit(level_id)
```

### 关卡解锁逻辑
```gdscript
# LevelSelect.gd
extends Control

func _ready():
	_load_level_states()

func _load_level_states():
	var completed_levels = SaveGame.get_completed_levels()
	
	for i in range(3):
		var card = $LevelGrid.get_child(i)
		
		# 关卡 1 默认解锁，后续关卡需要前一关 B 级以上
		if i == 0:
			card.is_locked = false
		else:
			var prev_grade = SaveGame.get_level_grade(i)
			card.is_locked = not (prev_grade in ["B", "A", "S"])
		
		card.level_selected.connect(_on_level_selected)

func _on_level_selected(level_id: int):
	GameManager.current_level_id = level_id
	get_tree().change_scene_to_file("res://scenes/GameMain.tscn")
```

---

## 1.3 游戏主界面（核心）

### 完整布局设计

```
┌─────────────────────────────────────────────┐
│  关卡 01                    ⚙ 设置           │
├─────────────────────────────────────────────┤
│                                             │
│  🎯 结果节点                                 │
│  ┌──────────────────────────────────────┐   │
│  │ 2038 年：某大型城市发生系统性崩溃      │   │
│  └──────────────────────────────────────┘   │
│                                             │
│  📊 因果强度                                 │
│  ████████░░░░ 2.4 / 3.0                     │
│                                             │
│  🧩 因果链构建区                             │
│  ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐             │
│  │ ? │→│ ? │→│ ? │→│ ? │→│结果│             │
│  └───┘ └───┘ └───┘ └───┘ └───┘             │
│                                             │
│  📦 候选因果节点                             │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐           │
│  │技术 │ │失业 │ │保障 │ │动荡 │           │
│  │突破 │ │     │ │滞后 │ │     │           │
│  └─────┘ └─────┘ └─────┘ └─────┘           │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐           │
│  │基建 │ │资本 │ │气候 │ │信息 │           │
│  │超负荷│ │外逃 │ │事件 │ │污染 │           │
│  └─────┘ └─────┘ └─────┘ └─────┘           │
│                                             │
│  ┌──────┐  ┌──────┐  ┌──────┐              │
│  │ 验证 │  │ 清空 │  │ 提示 │              │
│  └──────┘  └──────┘  └──────┘              │
└─────────────────────────────────────────────┘
```

### 场景结构
```
GameMain (Control)
 ├─ Header (HBoxContainer)
 │   ├─ LevelLabel
 │   └─ SettingsButton
 ├─ ResultCardContainer (MarginContainer)
 │   └─ ResultCard (Panel)
 ├─ StrengthBar (ProgressBar)
 │   └─ StrengthLabel (Label)
 ├─ ChainArea (Panel)
 │   └─ ChainSlots (HBoxContainer)
 │       ├─ Slot1 (ChainSlot)
 │       ├─ Arrow1 (Label "→")
 │       ├─ Slot2 (ChainSlot)
 │       ├─ Arrow2
 │       ├─ ...
 │       └─ ResultSlot (固定显示结果)
 ├─ CandidateArea (Panel)
 │   └─ CandidateGrid (GridContainer)
 │       ├─ CauseCard1
 │       ├─ CauseCard2
 │       └─ ...
 └─ ActionButtons (HBoxContainer)
     ├─ ValidateButton
     ├─ ClearButton
     └─ HintButton
```

---

## 1.4 拖拽系统详细设计

### 1.4.1 CauseCard 组件（可拖拽卡片）

#### 视觉状态设计

| 状态 | 视觉效果 | 实现方式 |
|-----|---------|---------|
| **默认** | 深灰背景 + 白字 | `modulate = Color.WHITE` |
| **悬停** | 轻微高亮 + 边框发光 | `scale = 1.05`, 添加 glow shader |
| **拖拽中** | 半透明 + 跟随鼠标 | `modulate.a = 0.7`, `global_position = mouse_pos` |
| **可放置** | 绿色提示 | `modulate = Color(0.6, 1.0, 0.6)` |
| **不可放置** | 红色禁止 | `modulate = Color(1.0, 0.4, 0.4)` |
| **已使用** | 灰暗不可拖 | `modulate = Color(0.3, 0.3, 0.3)` |

#### 完整实现代码
```gdscript
# CauseCard.gd
class_name CauseCard
extends PanelContainer

signal drag_started(card: CauseCard)
signal drag_ended(card: CauseCard)

@export var cause_data: CauseNode
var is_dragging := false
var is_used := false
var original_position: Vector2

@onready var label = $MarginContainer/Label

func _ready():
	label.text = cause_data.label
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	if not is_used:
		scale = Vector2(1.05, 1.05)

func _on_mouse_exited():
	if not is_dragging:
		scale = Vector2.ONE

func _gui_input(event: InputEvent):
	if is_used:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag()
			else:
				_end_drag()

func _start_drag():
	is_dragging = true
	original_position = global_position
	modulate.a = 0.7
	z_index = 100  # 置顶显示
	drag_started.emit(self)

func _end_drag():
	is_dragging = false
	modulate.a = 1.0
	scale = Vector2.ONE
	z_index = 0
	drag_ended.emit(self)

func _process(_delta):
	if is_dragging:
		global_position = get_global_mouse_position() - size / 2

func set_used(used: bool):
	is_used = used
	if used:
		modulate = Color(0.3, 0.3, 0.3)
	else:
		modulate = Color.WHITE

func return_to_original():
	var tween = create_tween()
	tween.tween_property(self, "global_position", original_position, 0.2)
```

---

### 1.4.2 ChainSlot 组件（放置槽）

#### 视觉状态设计

| 状态 | 外观 | 提示文本 |
|-----|------|---------|
| **空槽** | 虚线边框 | "拖拽节点到此" |
| **悬停（可放）** | 绿色实线 | "松开放置" |
| **悬停（不可放）** | 红色虚线 | "❌ 不可重复" |
| **已填充** | 实心卡片 | 显示因果内容 |
| **可替换** | 黄色边框闪烁 | "拖拽替换" |

#### 完整实现
```gdscript
# ChainSlot.gd
class_name ChainSlot
extends PanelContainer

signal card_placed(slot: ChainSlot, card: CauseCard)
signal card_removed(slot: ChainSlot)

enum State { EMPTY, HOVER_VALID, HOVER_INVALID, FILLED }

var current_state := State.EMPTY
var current_card: CauseCard = null
var slot_index: int

@onready var placeholder_label = $PlaceholderLabel
@onready var card_container = $CardContainer

func _ready():
	_update_visual()

func _update_visual():
	match current_state:
		State.EMPTY:
			placeholder_label.visible = true
			placeholder_label.text = "?"
			add_theme_stylebox_override("panel", _create_dashed_border())
		
		State.HOVER_VALID:
			add_theme_stylebox_override("panel", _create_solid_border(Color.GREEN))
		
		State.HOVER_INVALID:
			add_theme_stylebox_override("panel", _create_solid_border(Color.RED))
		
		State.FILLED:
			placeholder_label.visible = false

func _create_dashed_border() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.border_width_all = 2
	style.border_color = Color(0.5, 0.5, 0.5)
	style.bg_color = Color(0.1, 0.1, 0.1)
	return style

func _create_solid_border(color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.border_width_all = 3
	style.border_color = color
	style.bg_color = Color(0.15, 0.15, 0.15)
	return style

func can_accept_card(card: CauseCard) -> bool:
	# 检查是否重复
	var chain_area = get_parent()
	for slot in chain_area.get_children():
		if slot is ChainSlot and slot.current_card:
			if slot.current_card.cause_data.id == card.cause_data.id:
				return false
	return true

func place_card(card: CauseCard):
	if current_card:
		remove_card()
	
	current_card = card
	current_state = State.FILLED
	
	# 将卡片移到槽内
	var card_clone = card.duplicate()
	card_container.add_child(card_clone)
	card.set_used(true)
	
	_update_visual()
	card_placed.emit(self, card)

func remove_card():
	if current_card:
		current_card.set_used(false)
		current_card = null
		current_state = State.EMPTY
		
		# 清除槽内卡片
		for child in card_container.get_children():
			child.queue_free()
		
		_update_visual()
		card_removed.emit(self)

# 拖拽检测
func _can_drop_data(_at_position, data) -> bool:
	if data is CauseCard:
		var valid = can_accept_card(data)
		current_state = State.HOVER_VALID if valid else State.HOVER_INVALID
		_update_visual()
		return valid
	return false

func _drop_data(_at_position, data):
	if data is CauseCard:
		place_card(data)
	current_state = State.FILLED if current_card else State.EMPTY
	_update_visual()

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		if current_state in [State.HOVER_VALID, State.HOVER_INVALID]:
			current_state = State.FILLED if current_card else State.EMPTY
			_update_visual()
```

---

### 1.4.3 拖拽流程控制器

```gdscript
# GameMain.gd
extends Control

var current_dragging_card: CauseCard = null

func _ready():
	_connect_all_cards()
	_connect_all_slots()

func _connect_all_cards():
	for card in $CandidateArea/CandidateGrid.get_children():
		if card is CauseCard:
			card.drag_started.connect(_on_card_drag_started)
			card.drag_ended.connect(_on_card_drag_ended)

func _connect_all_slots():
	for slot in $ChainArea/ChainSlots.get_children():
		if slot is ChainSlot:
			slot.card_placed.connect(_on_card_placed)
			slot.card_removed.connect(_on_card_removed)

func _on_card_drag_started(card: CauseCard):
	current_dragging_card = card
	# 显示所有槽位的可放置状态
	_update_slot_hints(card)

func _on_card_drag_ended(card: CauseCard):
	# 检查是否放置到槽位
	var placed = false
	for slot in $ChainArea/ChainSlots.get_children():
		if slot is ChainSlot and slot.get_global_rect().has_point(get_global_mouse_position()):
			if slot.can_accept_card(card):
				slot.place_card(card)
				placed = true
				break
	
	if not placed:
		card.return_to_original()
	
	current_dragging_card = null
	_clear_slot_hints()

func _update_slot_hints(card: CauseCard):
	for slot in $ChainArea/ChainSlots.get_children():
		if slot is ChainSlot:
			if slot.can_accept_card(card):
				slot.current_state = ChainSlot.State.HOVER_VALID
			else:
				slot.current_state = ChainSlot.State.HOVER_INVALID
			slot._update_visual()

func _clear_slot_hints():
	for slot in $ChainArea/ChainSlots.get_children():
		if slot is ChainSlot:
			slot.current_state = ChainSlot.State.FILLED if slot.current_card else ChainSlot.State.EMPTY
			slot._update_visual()

func _on_card_placed(slot: ChainSlot, card: CauseCard):
	_update_strength_bar()

func _on_card_removed(slot: ChainSlot):
	_update_strength_bar()

func _update_strength_bar():
	var chain = _get_current_chain()
	var strength = _calculate_current_strength(chain)
	$StrengthBar.value = (strength / GameManager.current_level.required_strength) * 100
	$StrengthBar/StrengthLabel.text = "%.1f / %.1f" % [strength, GameManager.current_level.required_strength]
```

---

## 1.5 操作按钮设计

### 验证按钮
```gdscript
func _on_validate_pressed():
	var chain = _get_current_chain()
	
	if chain.size() < 2:
		_show_error("请至少放置 2 个因果节点")
		return
	
	var validator = CausalValidator.new()
	var result = validator.validate_chain(chain, GameManager.current_level)
	var grade = validator.calculate_grade(chain, result)
	
	_show_result_panel(result, grade)
```

### 清空按钮
```gdscript
func _on_clear_pressed():
	# 显示确认对话框
	$ConfirmDialog.dialog_text = "确定要清空当前因果链吗？"
	$ConfirmDialog.popup_centered()

func _on_confirm_clear():
	for slot in $ChainArea/ChainSlots.get_children():
		if slot is ChainSlot:
			slot.remove_card()
	
	_update_strength_bar()
```

### 撤销/重做系统（P1）
```gdscript
# UndoRedoManager.gd
class_name UndoRedoManager
extends Node

var history: Array[Dictionary] = []
var current_index: int = -1
const MAX_HISTORY = 20

func record_action(action_type: String, data: Dictionary):
	# 清除当前索引之后的历史
	if current_index < history.size() - 1:
		history = history.slice(0, current_index + 1)
	
	history.append({
		"type": action_type,
		"data": data,
		"timestamp": Time.get_ticks_msec()
	})
	
	current_index += 1
	
	# 限制历史记录数量
	if history.size() > MAX_HISTORY:
		history.pop_front()
		current_index -= 1

func undo() -> Dictionary:
	if current_index < 0:
		return {}
	
	var action = history[current_index]
	current_index -= 1
	return action

func redo() -> Dictionary:
	if current_index >= history.size() - 1:
		return {}
	
	current_index += 1
	return history[current_index]

func can_undo() -> bool:
	return current_index >= 0

func can_redo() -> bool:
	return current_index < history.size() - 1
```

**使用示例**：
```gdscript
# 在 GameMain.gd 中
var undo_manager = UndoRedoManager.new()

func _on_card_placed(slot: ChainSlot, card: CauseCard):
	undo_manager.record_action("place", {
		"slot_index": slot.slot_index,
		"card_id": card.cause_data.id
	})

func _on_undo_pressed():
	var action = undo_manager.undo()
	if action:
		_restore_state(action)

func _input(event):
	if event.is_action_pressed("ui_undo"):  # Ctrl+Z
		_on_undo_pressed()
	elif event.is_action_pressed("ui_redo"):  # Ctrl+Y
		_on_redo_pressed()
```

---

## 1.6 结果反馈界面

### 布局设计
```
┌─────────────────────────────────────┐
│                                     │
│          🎖 评估结果                 │
│                                     │
│            ███ S 级                 │
│                                     │
│  ✅ 因果完整度：95%                  │
│  ✅ 因果强度：3.2 / 3.0              │
│  ✅ 逻辑洁净度：100%                 │
│                                     │
│  💬 "你构建了一条高度自洽的系统性      │
│      因果链。在现实世界中，这种推理    │
│      能力极其稀缺。"                  │
│                                     │
│  🎁 解锁：因果共振 "卢德循环"         │
│                                     │
│  ┌──────────┐  ┌──────────┐        │
│  │ 下一关   │  │ 重新挑战 │        │
│  └──────────┘  └──────────┘        │
│                                     │
└─────────────────────────────────────┘
```

### 实现代码
```gdscript
# ResultPanel.gd
extends Panel

signal next_level_pressed
signal retry_pressed

@onready var grade_label = $VBox/GradeLabel
@onready var completeness_bar = $VBox/CompletenessBar
@onready var strength_bar = $VBox/StrengthBar
@onready var cleanliness_bar = $VBox/CleanlinessBar
@onready var comment_label = $VBox/CommentLabel
@onready var unlock_label = $VBox/UnlockLabel

func show_result(result: Dictionary, grade: String):
	visible = true
	
	# 设置评级
	grade_label.text = _get_grade_symbol(grade)
	grade_label.modulate = _get_grade_color(grade)
	
	# 动画显示进度条
	_animate_bars(result)
	
	# 显示评语
	comment_label.text = _get_comment(grade)
	
	# 检查解锁
	if result.has("unlocks"):
		unlock_label.text = "🎁 解锁：" + result.unlocks
		unlock_label.visible = true
	else:
		unlock_label.visible = false

func _get_grade_symbol(grade: String) -> String:
	match grade:
		"S": return "███ S 级"
		"A": return "██░ A 级"
		"B": return "█░░ B 级"
		_: return "░░░ 未通过"

func _get_grade_color(grade: String) -> Color:
	match grade:
		"S": return Color(1.0, 0.84, 0.0)  # 金色
		"A": return Color(0.75, 0.75, 0.75)  # 银色
		"B": return Color(0.8, 0.5, 0.2)  # 铜色
		_: return Color(0.5, 0.5, 0.5)

func _animate_bars(result: Dictionary):
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(completeness_bar, "value", result.completeness * 100, 0.5)
	tween.tween_property(strength_bar, "value", result.strength_ratio * 100, 0.5)
	tween.tween_property(cleanliness_bar, "value", result.cleanliness * 100, 0.5)

func _get_comment(grade: String) -> String:
	var comments = {
		"S": "你构建了一条高度自洽的系统性因果链。\n在现实世界中，这种推理能力极其稀缺。",
		"A": "逻辑成立，但你忽略了至少一个关键中介。\n试试能否找到更完整的路径？",
		"B": "相关性被当成了因果性。\n这是人类最常见的推理陷阱。",
		"FAIL": "因果链存在断裂或逻辑冲突。\n重新审视节点之间的连接关系。"
	}
	return comments.get(grade, "")
```

---

# 二、技术实现细节

## 2.1 拖拽系统完整实现

### Godot 拖拽机制说明

Godot 提供两种拖拽方式：

#### 方案 A：使用内置 Drag & Drop API（推荐）
```gdscript
# 在被拖拽的节点中
func _get_drag_data(_position):
	# 返回要传递的数据
	var preview = self.duplicate()
	preview.modulate.a = 0.7
	set_drag_preview(preview)
	return self

# 在目标节点中
func _can_drop_data(_position, data) -> bool:
	return data is CauseCard

func _drop_data(_position, data):
	if data is CauseCard:
		place_card(data)
```

#### 方案 B：手动实现拖拽（更灵活）
```gdscript
# CauseCard.gd
var is_dragging = false

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
		else:
			is_dragging = false
			_check_drop_target()

func _process(_delta):
	if is_dragging:
		global_position = get_global_mouse_position() - size / 2

func _check_drop_target():
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	
	var result = space_state.intersect_point(query)
	for collision in result:
		if collision.collider is ChainSlot:
			collision.collider.try_place_card(self)
```

**本项目采用方案 A + 方案 B 混合**：
- 使用 `_get_drag_data` 传递数据
- 使用手动 `_process` 实现跟随效果

---

## 2.2 数据持久化系统

### 存档数据结构
```gdscript
# SaveGame.gd
extends Node

const SAVE_PATH = "user://save_data.json"

var save_data = {
	"version": "0.1.0",
	"player_name": "玩家",
	"total_playtime": 0,
	"level_progress": {},  # { level_id: { grade, score, best_chain, unlocks } }
	"archive": {
		"resonances": [],  # 已发现的因果共振
		"world_logs": []   # 世界线日志
	},
	"settings": {
		"sound_volume": 1.0,
		"music_volume": 0.7
	}
}

func _ready():
	load_game()

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		print("游戏已保存")
	else:
		push_error("无法保存游戏：", FileAccess.get_open_error())

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("未找到存档，使用默认数据")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(content)
		
		if error == OK:
			save_data = json.data
			print("游戏已加载")
		else:
			push_error("存档解析失败：", json.get_error_message())

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func reset_progress():
	save_data.level_progress.clear()
	save_data.archive.resonances.clear()
	save_data.archive.world_logs.clear()
	save_game()

# 关卡相关
func save_level_result(level_id: int, grade: String, score: float, chain: Array):
	if not save_data.level_progress.has(level_id):
		save_data.level_progress[level_id] = {}
	
	var level_data = save_data.level_progress[level_id]
	
	# 只保存最好成绩
	if not level_data.has("grade") or _grade_value(grade) > _grade_value(level_data.grade):
		level_data.grade = grade
		level_data.score = score
		level_data.best_chain = chain
		level_data.completed_time = Time.get_unix_time_from_system()
	
	save_game()

func get_level_grade(level_id: int) -> String:
	if save_data.level_progress.has(level_id):
		return save_data.level_progress[level_id].get("grade", "")
	return ""

func get_completed_levels() -> Array:
	return save_data.level_progress.keys()

func _grade_value(grade: String) -> int:
	match grade:
		"S": return 4
		"A": return 3
		"B": return 2
		_: return 0

# 图鉴相关
func unlock_resonance(resonance_id: String):
	if not resonance_id in save_data.archive.resonances:
		save_data.archive.resonances.append(resonance_id)
		save_game()

func add_world_log(log: Dictionary):
	save_data.archive.world_logs.append(log)
	save_game()
```

### 自动保存机制
```gdscript
# GameManager.gd（全局自动加载）
extends Node

var auto_save_timer: Timer

func _ready():
	# 每 30 秒自动保存
	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = 30.0
	auto_save_timer.timeout.connect(_on_auto_save)
	add_child(auto_save_timer)
	auto_save_timer.start()

func _on_auto_save():
	SaveGame.save_game()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveGame.save_game()
		get_tree().quit()
```

---

## 2.3 错误处理与边界情况

### 输入验证
```gdscript
# CausalValidator.gd
func validate_chain(chain: Array[String], level: LevelData) -> Dictionary:
	var errors = []
	
	# 边界情况 1：空链
	if chain.is_empty():
		errors.append({
			"type": "empty_chain",
			"message": "因果链为空，请至少放置 2 个节点"
		})
		return _create_fail_result(errors)
	
	# 边界情况 2：单节点
	if chain.size() == 1:
		errors.append({
			"type": "insufficient_nodes",
			"message": "因果链过短，至少需要 2 个节点"
		})
		return _create_fail_result(errors)
	
	# 边界情况 3：超长链
	if chain.size() > level.max_steps:
		errors.append({
			"type": "chain_too_long",
			"message": "因果链过长（最多 %d 个节点）" % level.max_steps
		})
		return _create_fail_result(errors)
	
	# 边界情况 4：重复节点
	var unique_nodes = []
	for node_id in chain:
		if node_id in unique_nodes:
			errors.append({
				"type": "duplicate_node",
				"message": "因果链中存在重复节点：%s" % node_id
			})
			return _create_fail_result(errors)
		unique_nodes.append(node_id)
	
	# 正常验证逻辑
	var total_strength = 0.0
	for i in range(chain.size() - 1):
		var rule = _find_rule(chain[i], chain[i + 1], level.rules)
		if rule == null:
			errors.append({
				"type": "broken_chain",
				"message": "因果断裂：%s → %s" % [chain[i], chain[i + 1]]
			})
		else:
			total_strength += rule.strength
	
	if not errors.is_empty():
		return _create_fail_result(errors)
	
	# 强度检查
	if total_strength < level.required_strength:
		errors.append({
			"type": "insufficient_strength",
			"message": "因果强度不足（%.2f / %.2f）" % [total_strength, level.required_strength]
		})
		return _create_fail_result(errors)
	
	return {
		"passed": true,
		"strength": total_strength,
		"errors": [],
		"completeness": _calculate_completeness(chain, level),
		"strength_ratio": total_strength / level.required_strength,
		"cleanliness": 1.0  # 无错误
	}

func _create_fail_result(errors: Array) -> Dictionary:
	return {
		"passed": false,
		"strength": 0.0,
		"errors": errors,
		"completeness": 0.0,
		"strength_ratio": 0.0,
		"cleanliness": 0.0
	}
```

---

## 2.4 Web 导出优化

### 项目导出设置

**Export → Web (HTML5)**：

| 选项 | 设置 | 说明 |
|-----|------|------|
| **HTML文件名** | `index.html` | 标准入口 |
| **线程支持** | 关闭 | Web 兼容性 |
| **渐进式 Web 应用** | 开启 | 支持离线 |
| **Head Include** | 自定义 meta 标签 | SEO 优化 |

### 自定义 HTML 模板
```html
<!-- export_templates/web/index.html -->
<!DOCTYPE html>
<html lang="zh-CN">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>逆果溯因 - 认知型推理游戏</title>
	<meta name="description" content="构建合理的因果链，挑战系统性思维">
	
	<style>
		body {
			margin: 0;
			padding: 0;
			background: #0E1117;
			display: flex;
			justify-content: center;
			align-items: center;
			height: 100vh;
			font-family: 'Inter', sans-serif;
		}
		
		#canvas-container {
			width: 100%;
			max-width: 1280px;
			max-height: 720px;
			aspect-ratio: 16 / 9;
		}
		
		canvas {
			width: 100%;
			height: 100%;
			display: block;
		}
		
		#loading-screen {
			position: absolute;
			width: 100%;
			height: 100%;
			background: #0E1117;
			display: flex;
			flex-direction: column;
			justify-content: center;
			align-items: center;
			color: #E6EDF3;
		}
		
		.spinner {
			border: 4px solid rgba(255,255,255,0.1);
			border-top: 4px solid #3FB950;
			border-radius: 50%;
			width: 40px;
			height: 40px;
			animation: spin 1s linear infinite;
		}
		
		@keyframes spin {
			0% { transform: rotate(0deg); }
			100% { transform: rotate(360deg); }
		}
	</style>
</head>
<body>
	<div id="canvas-container">
		<div id="loading-screen">
			<div class="spinner"></div>
			<p style="margin-top: 20px;">加载中...</p>
		</div>
		<canvas id="canvas"></canvas>
	</div>
	
	<script src="index.js"></script>
	<script>
		// 加载完成后隐藏 loading
		window.addEventListener('load', () => {
			document.getElementById('loading-screen').style.display = 'none';
		});
	</script>
</body>
</html>
```

### 响应式适配脚本
```gdscript
# ResponsiveUI.gd（全局自动加载）
extends Node

var base_resolution = Vector2(1280, 720)
var scale_factor = 1.0

func _ready():
	get_viewport().size_changed.connect(_on_viewport_resized)
	_on_viewport_resized()

func _on_viewport_resized():
	var viewport_size = get_viewport().get_visible_rect().size
	
	# 计算缩放比例
	var width_scale = viewport_size.x / base_resolution.x
	var height_scale = viewport_size.y / base_resolution.y
	scale_factor = min(width_scale, height_scale)
	
	# 通知所有 UI 节点调整
	get_tree().call_group("responsive_ui", "_on_scale_changed", scale_factor)

# 在需要响应的节点中使用
# func _on_scale_changed(new_scale: float):
#     scale = Vector2(new_scale, new_scale)
```

### 性能优化检查清单

- [ ] 关闭不必要的 `_process` 和 `_physics_process`
- [ ] 使用对象池管理卡片实例
- [ ] 图片资源压缩（WebP 格式）
- [ ] 音频使用 OGG 格式（Web 友好）
- [ ] 禁用 3D 渲染器（使用 2D 模式）
- [ ] 限制粒子效果数量

---

# 三、游戏流程设计

## 3.1 完整流程图

```
┌──────────┐
│ 启动游戏  │
└─────┬────┘
      │
      ▼
┌──────────┐     是否有存档？
│ 主菜单   │───────┐
└─────┬────┘       │
      │            ▼ 是
      │         显示"继续游戏"
      │            │
      ▼ 开始游戏   │
┌──────────┐◄──────┘
│关卡选择   │
└─────┬────┘
      │
      ▼ 选择关卡
┌──────────┐
│首次引导？ │──是──▶ 教程模式
└─────┬────┘
      │ 否
      ▼
┌──────────┐
│ 游戏主界面│◄──┐
└─────┬────┘   │
      │        │ 重试
      ▼        │
┌──────────┐   │
│ 验证结果 │───┘
└─────┬────┘
      │
      ▼
┌──────────┐
│ 解锁检查 │
└─────┬────┘
      │
      ▼
  返回关卡选择
```

## 3.2 首次引导系统（P1）

### 教程关卡设计（关卡 0）

**目标**：教会玩家拖拽、因果判断、验证流程

```gdscript
# TutorialLevel.gd
extends Control

enum TutorialStep {
	INTRO,           # 介绍游戏目标
	DRAG_CARD,       # 教拖拽
	PLACE_CARD,      # 教放置
	BUILD_CHAIN,     # 教构建链
	VALIDATE,        # 教验证
	UNDERSTAND_RESULT, # 解读结果
	COMPLETE
}

var current_step = TutorialStep.INTRO
var highlight_node: Control = null

func _ready():
	_show_step(current_step)

func _show_step(step: TutorialStep):
	match step:
		TutorialStep.INTRO:
			_show_message(
				"欢迎来到《逆果溯因》",
				"你需要从给定的结果，构建一条合理的因果链。\n\n点击继续..."
			)
		
		TutorialStep.DRAG_CARD:
			_highlight_element($CandidateArea/CandidateGrid.get_child(0))
			_show_message(
				"拖拽节点",
				"点击并拖拽这个节点到上方的槽位中"
			)
		
		TutorialStep.PLACE_CARD:
			_highlight_element($ChainArea/ChainSlots.get_child(0))
			_show_message(
				"放置节点",
				"松开鼠标，将节点放入槽位"
			)
		
		TutorialStep.BUILD_CHAIN:
			_show_message(
				"构建因果链",
				"继续拖拽节点，组成一条完整的因果链\n至少需要 3 个节点"
			)
		
		TutorialStep.VALIDATE:
			_highlight_element($ActionButtons/ValidateButton)
			_show_message(
				"验证结果",
				"点击"验证"按钮，检查你的因果链是否成立"
			)
		
		TutorialStep.UNDERSTAND_RESULT:
			_show_message(
				"理解反馈",
				"系统会告诉你：\n• 因果是否成立\n• 逻辑强度如何\n• 是否存在伪因果"
			)
		
		TutorialStep.COMPLETE:
			_show_message(
				"教程完成！",
				"现在你可以挑战正式关卡了"
			)
			SaveGame.save_data.tutorial_completed = true
			SaveGame.save_game()

func _highlight_element(element: Control):
	if highlight_node:
		_remove_highlight()
	
	highlight_node = element
	var highlight = ColorRect.new()
	highlight.color = Color(1, 1, 0, 0.3)
	highlight.size = element.size
	highlight.position = element.position
	element.add_child(highlight)

func _remove_highlight():
	if highlight_node and highlight_node.get_child_count() > 0:
		highlight_node.get_child(-1).queue_free()
```

### 教程触发条件
```gdscript
# LevelSelect.gd
func _ready():
	if not SaveGame.save_data.get("tutorial_completed", false):
		get_tree().change_scene_to_file("res://scenes/Tutorial.tscn")
		return
	
	_load_level_states()
```

---

## 3.3 关卡解锁机制

### 解锁规则
```gdscript
# LevelUnlockManager.gd
class_name LevelUnlockManager
extends Node

# 关卡解锁条件
const UNLOCK_REQUIREMENTS = {
	1: {},  # 默认解锁
	2: { "prev_level": 1, "min_grade": "B" },
	3: { "prev_level": 2, "min_grade": "B" },
	# 后续关卡...
}

func is_level_unlocked(level_id: int) -> bool:
	if not UNLOCK_REQUIREMENTS.has(level_id):
		return false
	
	var req = UNLOCK_REQUIREMENTS[level_id]
	
	# 无条件的关卡直接解锁
	if req.is_empty():
		return true
	
	# 检查前置关卡
	if req.has("prev_level"):
		var prev_grade = SaveGame.get_level_grade(req.prev_level)
		if prev_grade.is_empty():
			return false
		
		if req.has("min_grade"):
			var grade_values = { "S": 4, "A": 3, "B": 2 }
			if grade_values.get(prev_grade, 0) < grade_values.get(req.min_grade, 0):
				return false
	
	return true

func get_unlock_hint(level_id: int) -> String:
	if is_level_unlocked(level_id):
		return ""
	
	var req = UNLOCK_REQUIREMENTS[level_id]
	if req.has("prev_level") and req.has("min_grade"):
		return "需要完成关卡 %d 并达到 %s 级" % [req.prev_level, req.min_grade]
	
	return "未知解锁条件"
```

---

# 四、新增机制实现

## 4.1 干扰节点系统

### 数据标记
```gdscript
# CauseNode.gd
class_name CauseNode
extends Resource

@export var id: String
@export var label: String
@export var tags: Array[String]
@export var time_stage: int

# 新增：干扰节点标记
@export var is_distractor: bool = false
@export var distractor_type: String = ""  # "pseudo", "reverse", "weak"
```

### 视觉区分
```gdscript
# CauseCard.gd
func _ready():
	label.text = cause_data.label
	
	# 干扰节点使用不同样式
	if cause_data.is_distractor:
		_apply_distractor_style()

func _apply_distractor_style():
	# 添加微妙的视觉提示（不能太明显）
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.12, 0.12)  # 略微偏红
	style.border_width_all = 1
	style.border_color = Color(0.3, 0.25, 0.25)
	add_theme_stylebox_override("panel", style)
```

### 验证逻辑
```gdscript
# CausalValidator.gd
func validate_chain(chain: Array[String], level: LevelData) -> Dictionary:
	var errors = []
	var total_strength = 0.0
	var used_distractor = false
	
	for i in range(chain.size() - 1):
		var from_node = _get_node_by_id(chain[i], level)
		var to_node = _get_node_by_id(chain[i + 1], level)
		
		# 检查干扰节点
		if from_node.is_distractor:
			used_distractor = true
			errors.append({
				"type": "distractor_used",
				"message": "使用了伪因果节点：%s" % from_node.label,
				"detail": _get_distractor_explanation(from_node.distractor_type)
			})
		
		var rule = _find_rule(chain[i], chain[i + 1], level.rules)
		if rule:
			total_strength += rule.strength
	
	var result = {
		"passed": errors.is_empty(),
		"strength": total_strength,
		"errors": errors,
		"used_distractor": used_distractor
	}
	
	# 计算洁净度
	result.cleanliness = 0.0 if used_distractor else 1.0
	
	return result

func _get_distractor_explanation(type: String) -> String:
	match type:
		"pseudo":
			return "这是伪因果：两者相关但不存在因果关系"
		"reverse":
			return "这是反向因果：时间顺序错误"
		"weak":
			return "这是弱因果：影响过于间接"
		_:
			return "这不是有效的因果节点"
```

---

## 4.2 因果共振系统

### 共振规则定义
```gdscript
# ResonanceDatabase.gd
class_name ResonanceDatabase
extends Resource

const RESONANCE_PATTERNS = {
	"luddite_loop": {
		"name": "卢德循环",
		"pattern": ["tech_breakthrough", "job_displacement", "social_unrest"],
		"description": "技术进步 → 失业 → 社会动荡\n这是工业革命以来反复出现的模式",
		"bonus_multiplier": 1.2,
		"unlock_text": "你重现了 200 年前的经典因果链"
	},
	
	"black_swan": {
		"name": "黑天鹅事件",
		"pattern": ["climate_event", "infra_overload", "system_collapse"],
		"description": "极端事件 → 系统超负荷 → 崩溃\n小概率事件的巨大影响",
		"bonus_multiplier": 1.5,
		"unlock_text": "你发现了隐藏的黑天鹅路径"
	},
	
	"information_cascade": {
		"name": "信息级联",
		"pattern": ["misinformation", "public_fear", "policy_shift"],
		"description": "虚假信息 → 公众恐慌 → 政策转向\n信息时代的特有现象",
		"bonus_multiplier": 1.3,
		"unlock_text": "你识别出了信息级联效应"
	}
}
```

### 检测逻辑
```gdscript
# ResonanceDetector.gd
class_name ResonanceDetector
extends Node

func detect_resonances(chain: Array[String]) -> Array:
	var found_resonances = []
	
	for resonance_id in ResonanceDatabase.RESONANCE_PATTERNS.keys():
		var pattern = ResonanceDatabase.RESONANCE_PATTERNS[resonance_id].pattern
		
		if _check_pattern_match(chain, pattern):
			found_resonances.append(resonance_id)
	
	return found_resonances

func _check_pattern_match(chain: Array[String], pattern: Array) -> bool:
	# 检查 pattern 是否是 chain 的子序列
	var pattern_index = 0
	
	for node_id in chain:
		if node_id == pattern[pattern_index]:
			pattern_index += 1
			if pattern_index == pattern.size():
				return true
	
	return false

func apply_resonance_bonus(base_score: float, resonances: Array) -> float:
	var multiplier = 1.0
	
	for resonance_id in resonances:
		var data = ResonanceDatabase.RESONANCE_PATTERNS[resonance_id]
		multiplier *= data.bonus_multiplier
	
	return base_score * multiplier
```

### 解锁提示
```gdscript
# GameMain.gd
func _on_validate_pressed():
	var chain = _get_current_chain()
	var result = validator.validate_chain(chain, GameManager.current_level)
	
	# 检测共振
	var detector = ResonanceDetector.new()
	var resonances = detector.detect_resonances(chain)
	
	if resonances.size() > 0:
		result.unlocks = []
		for res_id in resonances:
			var data = ResonanceDatabase.RESONANCE_PATTERNS[res_id]
			result.unlocks.append(data.name + ": " + data.unlock_text)
			SaveGame.unlock_resonance(res_id)
		
		# 应用加成
		result.score = detector.apply_resonance_bonus(result.score, resonances)
	
	_show_result_panel(result, grade)
```

---

## 4.3 多解路径检测

### 路径定义
```gdscript
# LevelData.gd
class_name LevelData
extends Resource

@export var result_id: String
@export var required_strength: float
@export var max_steps: int
@export var candidates: Array[CauseNode]
@export var rules: Array[CausalRule]

# 新增：预定义的有效路径
@export var valid_paths: Array[Dictionary] = [
	{
		"id": "mainstream",
		"name": "主流叙事",
		"chain": ["tech_breakthrough", "job_displacement", "social_unrest", "city_collapse"],
		"difficulty": 1,
		"bonus": 1.0
	},
	{
		"id": "hidden",
		"name": "环境因素",
		"chain": ["climate_event", "infra_overload", "capital_flight", "city_collapse"],
		"difficulty": 2,
		"bonus": 1.3
	},
	{
		"id": "black_swan",
		"name": "信息崩溃",
		"chain": ["misinformation", "decision_paralysis", "system_failure", "city_collapse"],
		"difficulty": 3,
		"bonus": 1.5
	}
]
```

### 识别逻辑
```gdscript
# PathAnalyzer.gd
class_name PathAnalyzer
extends Node

func identify_path(chain: Array[String], level: LevelData) -> Dictionary:
	for path_data in level.valid_paths:
		if _is_path_match(chain, path_data.chain):
			return path_data
	
	# 未知路径
	return {
		"id": "custom",
		"name": "自定义路径",
		"difficulty": 0,
		"bonus": 1.0
	}

func _is_path_match(chain: Array[String], expected: Array) -> bool:
	if chain.size() != expected.size():
		return false
	
	for i in range(chain.size()):
		if chain[i] != expected[i]:
			return false
	
	return true

func calculate_discovery_bonus(path_id: String) -> float:
	# 首次发现路径给额外奖励
	if not SaveGame.save_data.has("discovered_paths"):
		SaveGame.save_data.discovered_paths = []
	
	if not path_id in SaveGame.save_data.discovered_paths:
		SaveGame.save_data.discovered_paths.append(path_id)
		SaveGame.save_game()
		return 1.2  # 首次发现 +20%
	
	return 1.0
```

---

## 4.4 时空压力系统

### 时间窗口计算
```gdscript
# CausalRule.gd
class_name CausalRule
extends Resource

@export var from_id: String
@export var to_id: String
@export var strength: float

# 新增：时间约束
@export var min_time_gap: int = 0  # 最小间隔（年）
@export var max_time_gap: int = 10  # 最大间隔
@export var optimal_gap: int = 3   # 最佳间隔
```

### 时序验证
```gdscript
# CausalValidator.gd
func validate_chain(chain: Array[String], level: LevelData) -> Dictionary:
	var errors = []
	var total_strength = 0.0
	var time_penalties = 0.0
	
	for i in range(chain.size() - 1):
		var from_node = _get_node_by_id(chain[i], level)
		var to_node = _get_node_by_id(chain[i + 1], level)
		var rule = _find_rule(chain[i], chain[i + 1], level.rules)
		
		if rule:
			# 检查时间跨度
			var time_gap = abs(to_node.time_stage - from_node.time_stage)
			var strength_modifier = _calculate_time_modifier(time_gap, rule)
			
			var adjusted_strength = rule.strength * strength_modifier
			total_strength += adjusted_strength
			
			if strength_modifier < 1.0:
				time_penalties += (1.0 - strength_modifier)
				errors.append({
					"type": "time_gap_warning",
					"message": "时间跨度较大：%s → %s（强度 ×%.1f）" % [
						from_node.label, to_node.label, strength_modifier
					]
				})
	
	return {
		"passed": errors.is_empty() or time_penalties < 0.5,
		"strength": total_strength,
		"errors": errors,
		"time_quality": 1.0 - (time_penalties / chain.size())
	}

func _calculate_time_modifier(gap: int, rule: CausalRule) -> float:
	if gap < rule.min_time_gap:
		return 0.5  # 间隔过短，因果尚未显现
	elif gap > rule.max_time_gap:
		return 0.6  # 间隔过长，因果已衰减
	elif gap == rule.optimal_gap:
		return 1.0  # 最佳时机
	else:
		# 线性衰减
		var distance_from_optimal = abs(gap - rule.optimal_gap)
		return 1.0 - (distance_from_optimal * 0.1)
```

---

# 五、开发优先级

## P0 - MVP 必需功能（第 1-2 周）

### Week 1
- [x] 数据结构设计（CauseNode, CausalRule, LevelData）
- [x] 基础拖拽系统
- [x] 槽位放置逻辑
- [x] 因果验证核心
- [x] 评分计算
- [ ] 第一个可玩关卡（关卡 1）
- [ ] 基础 UI 布局
- [ ] 保存/加载系统

### Week 2
- [ ] 主菜单界面
- [ ] 关卡选择界面
- [ ] 结果反馈面板
- [ ] 3 个完整关卡
- [ ] 音效集成
- [ ] Web 导出测试

---

## P1 - 体验优化（第 3-4 周）

### Week 3
- [ ] 首次引导教程
- [ ] 撤销/重做功能
- [ ] 因果强度实时显示
- [ ] 干扰节点系统
- [ ] 拖拽动画优化
- [ ] 错误提示优化

### Week 4
- [ ] 关卡解锁动画
- [ ] 成就/图鉴 UI
- [ ] 音乐集成
- [ ] 性能优化
- [ ] Bug 修复
- [ ] 平衡性调整

---

## P2 - 完整版功能（第 5-6 周）

### Week 5
- [ ] 因果共振系统
- [ ] 多解路径检测
- [ ] 世界线日志生成
- [ ] 因果图鉴完整实现
- [ ] 隐藏关卡
- [ ] 挑战模式

### Week 6
- [ ] 数据分析（玩家行为）
- [ ] 社交分享功能
- [ ] 排行榜系统（可选）
- [ ] 完整音效库
- [ ] 最终打磨
- [ ] 发布准备

---

# 六、Web 优化方案

## 6.1 资源优化

### 图片资源
```
/assets
  /textures
    card_bg.webp       # 256x256, 质量 80
    slot_empty.webp    # 128x128, 质量 70
    particle.webp      # 64x64, 质量 60
```

**优化命令**：
```bash
# 使用 ImageMagick 批量压缩
for img in *.png; do
  convert "$img" -quality 80 -define webp:lossless=false "${img%.png}.webp"
done
```

### 音频资源
```
/assets
  /audio
    drag.ogg          # 单声道, 22kHz
    place.ogg
    validate.ogg
    success.ogg
    fail.ogg
    bgm_menu.ogg      # 立体声, 44kHz, 循环
```

**Godot 导入设置**：
- 音效：单声道，22050 Hz
- 音乐：立体声，44100 Hz，启用循环

---

## 6.2 加载优化

### 预加载关键资源
```gdscript
# Preloader.gd（全局自动加载）
extends Node

var preloaded_scenes = {}
var preloaded_audio = {}

func _ready():
	_preload_critical_resources()

func _preload_critical_resources():
	preloaded_scenes["main_menu"] = load("res://scenes/MainMenu.tscn")
	preloaded_scenes["level_select"] = load("res://scenes/LevelSelect.tscn")
	preloaded_scenes["game_main"] = load("res://scenes/GameMain.tscn")
	
	preloaded_audio["drag"] = load("res://assets/audio/drag.ogg")
	preloaded_audio["place"] = load("res://assets/audio/place.ogg")

func get_scene(scene_name: String) -> PackedScene:
	return preloaded_scenes.get(scene_name)

func get_audio(audio_name: String) -> AudioStream:
	return preloaded_audio.get(audio_name)
```

### 异步场景切换
```gdscript
# SceneTransition.gd
extends CanvasLayer

signal transition_finished

@onready var anim_player = $AnimationPlayer
@onready var progress_bar = $ProgressBar

func change_scene_async(scene_path: String):
	anim_player.play("fade_out")
	await anim_player.animation_finished
	
	var loader = ResourceLoader.load_threaded_request(scene_path)
	
	while true:
		var progress = []
		var status = ResourceLoader.load_threaded_get_status(scene_path, progress)
		
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = progress[0] * 100
			await get_tree().process_frame
		elif status == ResourceLoader.THREAD_LOAD_LOADED:
			var scene = ResourceLoader.load_threaded_get(scene_path)
			get_tree().change_scene_to_packed(scene)
			break
		else:
			push_error("场景加载失败：" + scene_path)
			break
	
	anim_player.play("fade_in")
	await anim_player.animation_finished
	transition_finished.emit()
```

---

## 6.3 性能监控

### FPS 显示（调试用）
```gdscript
# DebugOverlay.gd
extends CanvasLayer

@onready var fps_label = $FPSLabel

func _process(_delta):
	if OS.is_debug_build():
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
		fps_label.visible = true
	else:
		fps_label.visible = false
```

### 内存监控
```gdscript
func _process(_delta):
	var mem_usage = OS.get_static_memory_usage()
	if mem_usage > 100 * 1024 * 1024:  # 超过 100MB
		push_warning("内存占用较高：%.2f MB" % (mem_usage / 1024.0 / 1024.0))
```

---

# 附录：快速开发检查清单

## 每日开发流程

### 开发前
- [ ] 拉取最新代码（如果使用版本控制）
- [ ] 检查 Godot 编辑器版本（4.2+）
- [ ] 确认 Web 导出模板已安装

### 开发中
- [ ] 每完成一个功能立即测试
- [ ] 使用 `print()` 调试而非复杂断点
- [ ] 定期保存场景（Ctrl+S）
- [ ] 每 1 小时提交一次代码

### 开发后
- [ ] 运行 Web 导出
- [ ] 在浏览器中测试
- [ ] 检查控制台错误
- [ ] 更新开发日志

---

## 常见问题快速索引

| 问题 | 解决方案 | 位置 |
|-----|---------|------|
| 拖拽不工作 | 检查 `_get_drag_data` 返回值 | 2.1 |
| 存档丢失 | 检查 `SAVE_PATH` 权限 | 2.2 |
| Web 无法加载 | 检查线程支持设置 | 2.4 |
| 卡片重叠 | 调整 `z_index` | 1.4.1 |
| 性能卡顿 | 关闭不必要的 `_process` | 6.2 |

---

## 联系与反馈

**开发者笔记**：
- 记录每个关卡的测试数据
- 收集玩家的困惑点
- 跟踪评分分布

**社区反馈渠道**：
- itch.io 评论区
- Discord / QQ 群
- GitHub Issues

---

**文档版本**：v1.0  
**最后更新**：2026-01-28  
**适用引擎**：Godot 4.2+  
**目标平台**：Web (HTML5)

---

# 🎯 立即开始

**下一步行动**：
1. 创建 Godot 项目：`逆果溯因`
2. 导入本文档中的脚本
3. 设计第一个关卡数据
4. 构建 MVP UI
5. 第一周结束前完成可玩原型

**祝开发顺利！** 🚀
