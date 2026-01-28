class_name ChainSlot
extends PanelContainer

## 因果链槽位组件
## 用于放置因果节点卡片的槽位

signal card_placed(slot: ChainSlot, card: CauseCard)
signal card_removed(slot: ChainSlot, card_id: String)  # 添加card_id参数

enum State {
	EMPTY,
	FILLED,
	HOVER_VALID,
	HOVER_INVALID
}

var current_state: State = State.EMPTY
var current_card: CauseCard = null

@onready var card_container = $CardContainer
@onready var placeholder_label = $PlaceholderLabel

func _ready():
	_setup_style()
	_update_visual()

func _setup_style():
	# 创建基础样式
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.12, 0.15, 0.5)  # 半透明深色背景
	style.border_color = Color(0.3, 0.35, 0.4, 0.8)  # 浅色边框
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	
	add_theme_stylebox_override("panel", style)
	
	# 设置占位符标签样式
	if placeholder_label:
		placeholder_label.add_theme_font_size_override("font_size", 24)
		placeholder_label.add_theme_color_override("font_color", ThemeManager.get_color("text_primary"))

func _update_visual():
	var style = get_theme_stylebox("panel") as StyleBoxFlat
	if not style:
		_setup_style()
		style = get_theme_stylebox("panel") as StyleBoxFlat
	
	if not style:
		return
	
	match current_state:
		State.EMPTY:
			style.bg_color = Color(0.1, 0.12, 0.15, 0.3)
			style.border_color = Color(0.3, 0.35, 0.4, 0.5)
			modulate = Color.WHITE
			placeholder_label.visible = true
			if I18nManager:
				placeholder_label.text = I18nManager.translate("ui.chain_slot.placeholder")
			else:
				placeholder_label.text = "?"
		State.FILLED:
			style.bg_color = Color(0.15, 0.18, 0.22, 0.6)
			style.border_color = Color(0.4, 0.45, 0.5, 0.8)
			modulate = Color.WHITE
			placeholder_label.visible = false
		State.HOVER_VALID:
			style.bg_color = Color(0.2, 0.4, 0.2, 0.8)
			style.border_color = ThemeManager.get_color("causal_strong")
			modulate = Color(1.1, 1.1, 1.0)
			placeholder_label.visible = true
			if I18nManager:
				placeholder_label.text = I18nManager.translate("ui.chain_slot.valid")
			else:
				placeholder_label.text = "✓"
			if placeholder_label:
				placeholder_label.modulate = ThemeManager.get_color("causal_strong")
		State.HOVER_INVALID:
			style.bg_color = Color(0.4, 0.2, 0.2, 0.8)
			style.border_color = ThemeManager.get_color("error")
			modulate = Color(1.0, 0.9, 0.9)
			placeholder_label.visible = true
			if I18nManager:
				placeholder_label.text = I18nManager.translate("ui.chain_slot.invalid")
			else:
				placeholder_label.text = "✗"
			if placeholder_label:
				placeholder_label.modulate = ThemeManager.get_color("error")

## 检查是否可以接受卡片
func can_accept_card(card: CauseCard) -> bool:
	if not card or not card.cause_data:
		return false
	
	# 检查是否重复
	var chain_area = get_parent()
	if chain_area:
		for slot in chain_area.get_children():
			if slot is ChainSlot and slot != self and slot.current_card:
				if slot.current_card.cause_data.id == card.cause_data.id:
					return false
	
	return true

## 放置卡片
func place_card(card: CauseCard):
	if not can_accept_card(card):
		# 播放放置失败音效
		if AudioManager:
			AudioManager.play_place_fail()
		return
	
	# 播放放置成功音效
	if AudioManager:
		AudioManager.play_place()
	
	# 如果槽位已有卡片，先移除
	if current_card:
		remove_card()
	
	# 保存原始卡片引用（用于获取数据）
	current_card = card
	current_state = State.FILLED
	
	# 创建卡片副本并添加到槽位（用于显示）
	var card_clone = card.duplicate()
	card_clone.cause_data = card.cause_data  # 确保数据被复制
	card_clone.set_used(true)
	card_clone.mouse_filter = MOUSE_FILTER_IGNORE
	card_container.add_child(card_clone)
	
	# 设置卡片初始位置（从原卡片位置开始）
	var card_global_pos = card.global_position
	var slot_global_pos = global_position
	card_clone.position = card_global_pos - slot_global_pos
	card_clone.size = card.size
	
	# 标记原卡片为已使用（隐藏原卡片）
	card.set_used(true)
	
	# 放置动画：平滑移动到槽位中心并调整大小
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(card_clone, "position", Vector2.ZERO, 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_property(card_clone, "size", size, 0.3).set_ease(Tween.EASE_OUT)
	
	_update_visual()
	card_placed.emit(self, card)

## 移除卡片
func remove_card():
	# 保存card_id，因为emit信号时需要
	var card_id = ""
	if current_card and current_card.cause_data:
		card_id = current_card.cause_data.id
		current_card.set_used(false)
		current_card = null
	
	current_state = State.EMPTY
	
	# 清除槽内卡片
	for child in card_container.get_children():
		child.queue_free()
	
	_update_visual()
	card_removed.emit(self, card_id)

## 拖拽检测
func _can_drop_data(_at_position: Vector2, data) -> bool:
	if data is CauseCard:
		var valid = can_accept_card(data)
		current_state = State.HOVER_VALID if valid else State.HOVER_INVALID
		_update_visual()
		return valid
	return false

func _drop_data(_at_position: Vector2, data):
	if data is CauseCard:
		place_card(data)
		current_state = State.FILLED if current_card else State.EMPTY
		_update_visual()

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		if current_state in [State.HOVER_VALID, State.HOVER_INVALID]:
			current_state = State.FILLED if current_card else State.EMPTY
			_update_visual()
