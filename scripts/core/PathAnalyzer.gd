extends RefCounted

## 多解路径分析器
## 检测玩家构建的因果链是否匹配预定义的路径

class_name PathAnalyzer

## 路径数据结构
class ValidPath:
	var name: String
	var path: Array[String]  # 节点ID序列（包含结果节点）
	var difficulty: int  # 1=主流叙事, 2=隐藏路径, 3=黑天鹅链
	var bonus_multiplier: float
	
	func _init(p_name: String, p_path: Array[String], p_difficulty: int, p_bonus: float):
		name = p_name
		path = p_path
		difficulty = p_difficulty
		bonus_multiplier = p_bonus

## 检测链是否匹配任何有效路径
## chain: Array[String] - 节点ID数组（包含结果节点）
## level: LevelData - 关卡数据
## 返回: Dictionary - { matched: bool, path_name: String, is_new: bool, bonus_multiplier: float }
static func detect_path(chain: Array[String], level: LevelData) -> Dictionary:
	if not level or level.valid_paths.is_empty():
		return {"matched": false}
	
	# 检查每个有效路径
	for path_data in level.valid_paths:
		var path_name = path_data.get("name", "")
		var path_nodes = path_data.get("path", [])
		var difficulty = path_data.get("difficulty", 1)
		var bonus_multiplier = path_data.get("bonus_multiplier", 1.0)
		
		if _matches_path(chain, path_nodes):
			# 检查是否首次发现
			var discovered_paths = SaveGame.get_discovered_paths(GameManager.current_level_id)
			var is_new = not path_name in discovered_paths
			
			if is_new:
				# 标记为已发现
				SaveGame.mark_path_discovered(GameManager.current_level_id, path_name)
			
			return {
				"matched": true,
				"path_name": path_name,
				"difficulty": difficulty,
				"bonus_multiplier": bonus_multiplier,
				"is_new": is_new
			}
	
	return {"matched": false}

## 检查链是否完全匹配路径（严格匹配）
## chain: Array[String] - 玩家构建的链
## path: Array[String] - 预定义的路径
static func _matches_path(chain: Array[String], path: Array[String]) -> bool:
	if chain.size() != path.size():
		return false
	
	# 严格匹配：每个位置必须完全一致
	for i in range(chain.size()):
		if chain[i] != path[i]:
			return false
	
	return true

## 计算路径加成后的强度
## base_strength: float - 基础强度
## path_info: Dictionary - 路径检测结果
## 返回: float - 加成后的强度
static func apply_path_bonus(base_strength: float, path_info: Dictionary) -> float:
	if not path_info.get("matched", false):
		return base_strength
	
	var bonus_multiplier = path_info.get("bonus_multiplier", 1.0)
	var is_new = path_info.get("is_new", false)
	
	# 首次发现额外奖励
	if is_new:
		bonus_multiplier *= 1.2
	
	return base_strength * bonus_multiplier
