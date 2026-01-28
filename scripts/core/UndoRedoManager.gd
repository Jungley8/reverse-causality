class_name UndoRedoManager
extends Node

## 撤销/重做管理器
## 记录操作历史，支持撤销和重做功能

const MAX_HISTORY = 20

enum ActionType {
	PLACE,   # 放置节点
	REMOVE   # 移除节点
}

## 操作记录数据结构
class ActionRecord:
	var action_type: ActionType
	var slot_index: int
	var card_id: String
	var timestamp: int
	
	func _init(type: ActionType, slot_idx: int, cid: String):
		action_type = type
		slot_index = slot_idx
		card_id = cid
		timestamp = Time.get_ticks_msec()

var undo_stack: Array[ActionRecord] = []
var redo_stack: Array[ActionRecord] = []

## 记录放置操作
func record_place(slot_index: int, card_id: String):
	var action = ActionRecord.new(ActionType.PLACE, slot_index, card_id)
	undo_stack.append(action)
	
	# 限制历史记录数量
	if undo_stack.size() > MAX_HISTORY:
		undo_stack.pop_front()
	
	# 清除重做栈（新操作后不能重做之前的操作）
	redo_stack.clear()

## 记录移除操作
func record_remove(slot_index: int, card_id: String):
	var action = ActionRecord.new(ActionType.REMOVE, slot_index, card_id)
	undo_stack.append(action)
	
	# 限制历史记录数量
	if undo_stack.size() > MAX_HISTORY:
		undo_stack.pop_front()
	
	# 清除重做栈
	redo_stack.clear()

## 撤销操作
func undo() -> ActionRecord:
	if undo_stack.is_empty():
		return null
	
	var action = undo_stack.pop_back()
	redo_stack.append(action)
	return action

## 重做操作
func redo() -> ActionRecord:
	if redo_stack.is_empty():
		return null
	
	var action = redo_stack.pop_back()
	undo_stack.append(action)
	return action

## 检查是否可以撤销
func can_undo() -> bool:
	return not undo_stack.is_empty()

## 检查是否可以重做
func can_redo() -> bool:
	return not redo_stack.is_empty()

## 清空历史记录
func clear():
	undo_stack.clear()
	redo_stack.clear()
