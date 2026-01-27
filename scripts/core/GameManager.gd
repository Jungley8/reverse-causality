extends Node

## 游戏管理器
## 管理当前关卡状态等全局游戏状态

var current_level_id: int = 1
var current_level: LevelData = null

func load_level(level_id: int):
	current_level_id = level_id
	var level_path = "res://data/levels/level_%02d.tres" % level_id
	if ResourceLoader.exists(level_path):
		current_level = load(level_path) as LevelData
		return current_level
	else:
		push_error("关卡文件不存在：", level_path)
		return null
