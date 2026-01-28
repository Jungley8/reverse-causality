extends RefCounted

## 世界线日志模板
## 定义生成世界线日志的模板

class_name WorldLogTemplates

## 模板列表
static var templates: Array[String] = [
	"在这个世界线中，{cause_1}的到来摧毁了旧有的{cause_2}。\n当{cause_3}未能跟上技术变革的步伐时，\n人类社会迎来了不可避免的{result}...",
	
	"历史的车轮在{cause_1}的推动下开始转动。\n{cause_2}的连锁反应如多米诺骨牌般展开，\n最终导致了{cause_3}，并迎来了{result}的结局。",
	
	"当{cause_1}成为现实，{cause_2}便开始显现。\n没有人预料到，{cause_3}会成为压垮骆驼的最后一根稻草，\n将世界推向{result}的深渊。",
	
	"在因果的洪流中，{cause_1}点燃了第一把火。\n{cause_2}如野火般蔓延，{cause_3}成为催化剂，\n最终世界线收束于{result}。",
	
	"{cause_1}的种子被播下，{cause_2}为其提供养分。\n当{cause_3}成为必然时，{result}已无可避免。\n这就是因果的残酷逻辑。",
	
	"时间线在{cause_1}的节点发生分叉。\n{cause_2}加速了进程，{cause_3}锁定了结局。\n{result}成为这条世界线的最终归宿。"
]

## 获取随机模板
static func get_random_template() -> String:
	if templates.is_empty():
		return "世界线已记录。"
	return templates[randi() % templates.size()]

## 填充模板变量
## template: String - 模板文本
## chain: Array[String] - 因果链（节点ID数组）
## level: LevelData - 关卡数据
## 返回: String - 填充后的文本
static func fill_template(template: String, chain: Array[String], level: LevelData) -> String:
	if not level or chain.size() < 2:
		return template
	
	# 获取节点标签
	var node_labels = _get_node_labels(chain, level)
	
	# 替换变量
	var result = template
	result = result.replace("{cause_1}", node_labels[0] if node_labels.size() > 0 else "未知原因")
	result = result.replace("{cause_2}", node_labels[1] if node_labels.size() > 1 else "未知原因")
	result = result.replace("{cause_3}", node_labels[2] if node_labels.size() > 2 else "未知原因")
	
	# 结果节点（最后一个）
	var result_label = node_labels[node_labels.size() - 1] if node_labels.size() > 0 else "未知结果"
	result = result.replace("{result}", result_label)
	
	return result

## 获取节点标签
static func _get_node_labels(chain: Array[String], level: LevelData) -> Array[String]:
	var labels: Array[String] = []
	
	# 创建ID到标签的映射
	var id_to_label = {}
	for candidate in level.candidates:
		id_to_label[candidate.id] = candidate.label
	
	# 转换ID为标签
	for node_id in chain:
		if id_to_label.has(node_id):
			labels.append(id_to_label[node_id])
		else:
			labels.append(node_id)  # 如果找不到，使用ID
	
	return labels
