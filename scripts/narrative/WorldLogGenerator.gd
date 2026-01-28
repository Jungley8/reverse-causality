extends RefCounted

## 世界线日志生成器
## 根据玩家构建的因果链生成叙事文本

class_name WorldLogGenerator

## 生成世界线日志
## chain: Array[String] - 节点ID数组（包含结果节点）
## level: LevelData - 关卡数据
## result: Dictionary - 验证结果（包含路径、共振等信息）
## 返回: String - 生成的世界线日志文本
static func generate_world_log(chain: Array[String], level: LevelData, result: Dictionary) -> String:
	if not level or chain.size() < 2:
		return "世界线记录不完整。"
	
	# 获取随机模板
	var template = WorldLogTemplates.get_random_template()
	
	# 填充模板
	var log_text = WorldLogTemplates.fill_template(template, chain, level)
	
	# 添加路径和共振信息（如果有）
	var additional_info = []
	
	# 路径信息
	if result.has("path_info") and result.path_info.get("matched", false):
		var path_name = result.path_info.get("path_name", "")
		var difficulty = result.path_info.get("difficulty", 1)
		var difficulty_names = {1: "主流叙事", 2: "隐藏路径", 3: "黑天鹅链"}
		additional_info.append("\n\n发现的路径：" + path_name + "（" + difficulty_names.get(difficulty, "未知") + "）")
	
	# 共振信息
	if result.has("resonances") and not result.resonances.is_empty():
		var resonance_names = []
		for resonance in result.resonances:
			resonance_names.append(resonance.get("name", ""))
		if not resonance_names.is_empty():
			additional_info.append("\n触发的共振：" + "、".join(resonance_names))
	
	# 组合最终文本
	if not additional_info.is_empty():
		log_text += "\n".join(additional_info)
	
	return log_text

## 保存世界线日志
## level_id: int - 关卡ID
## chain: Array[String] - 因果链
## log_text: String - 日志文本
static func save_world_log(level_id: int, chain: Array[String], log_text: String):
	SaveGame.add_world_log(level_id, chain, log_text)
