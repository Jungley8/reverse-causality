extends Node

## 数据持久化系统
## 全局自动加载单例，负责保存和加载游戏进度

const SAVE_PATH = "user://save_data.json"

var save_data = {
	"version": "0.1.0",
	"player_name": "玩家",
	"total_playtime": 0,
	"level_progress": {},  # { level_id: { grade, score, best_chain, completed_time } }
	"settings": {
		"sound_volume": 1.0,
		"music_volume": 0.7
	}
}

func _ready():
	load_game()

## 保存游戏
func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		print("游戏已保存")
	else:
		push_error("无法保存游戏：", FileAccess.get_open_error())

## 加载游戏
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

## 检查是否有存档
func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

## 重置进度
func reset_progress():
	save_data.level_progress.clear()
	save_game()

## 保存关卡结果
func save_level_result(level_id: int, grade: String, score: float, chain: Array):
	if not save_data.level_progress.has(str(level_id)):
		save_data.level_progress[str(level_id)] = {}
	
	var level_data = save_data.level_progress[str(level_id)]
	
	# 只保存最好成绩
	if not level_data.has("grade") or _grade_value(grade) > _grade_value(level_data.get("grade", "")):
		level_data.grade = grade
		level_data.score = score
		level_data.best_chain = chain
		level_data.completed_time = Time.get_unix_time_from_system()
	
	save_game()

## 获取关卡评级
func get_level_grade(level_id: int) -> String:
	var level_id_str = str(level_id)
	if save_data.level_progress.has(level_id_str):
		return save_data.level_progress[level_id_str].get("grade", "")
	return ""

## 获取已完成的关卡列表
func get_completed_levels() -> Array:
	var completed = []
	for level_id_str in save_data.level_progress.keys():
		completed.append(int(level_id_str))
	return completed

## 评级数值（用于比较）
func _grade_value(grade: String) -> int:
	match grade:
		"S": return 4
		"A": return 3
		"B": return 2
		_: return 0
