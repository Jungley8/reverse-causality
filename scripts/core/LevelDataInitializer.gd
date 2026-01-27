extends Node

## 关卡数据初始化器
## 在游戏启动时检查并创建关卡数据（如果不存在）

func _ready():
	# 只在开发模式下运行
	if OS.is_debug_build():
		_ensure_level_data_exists()

func _ensure_level_data_exists():
	var level_paths = [
		"res://data/levels/level_01.tres",
		"res://data/levels/level_02.tres",
		"res://data/levels/level_03.tres"
	]
	
	for path in level_paths:
		if not ResourceLoader.exists(path):
			print("警告：关卡数据文件不存在：", path)
			print("请在编辑器中运行 scripts/tools/CreateLevelData.gd 来生成关卡数据")
