class_name CausalValidator
extends RefCounted

## 因果链验证器
## 负责验证因果链的有效性、计算强度、评分等

## 验证因果链
## chain: Array[String] - 节点ID数组
## level: LevelData - 关卡数据
## 返回: Dictionary { passed: bool, strength: float, errors: Array[String] }
func validate_chain(chain: Array[String], level: LevelData) -> Dictionary:
	var total_strength := 0.0
	var errors: Array[String] = []
	
	# 边界情况检查
	if chain.is_empty():
		errors.append("因果链为空")
		return {
			"passed": false,
			"strength": 0.0,
			"errors": errors
		}
	
	if chain.size() == 1:
		errors.append("因果链至少需要2个节点")
		return {
			"passed": false,
			"strength": 0.0,
			"errors": errors
		}
	
	# 检查是否超过最大步数
	if chain.size() > level.max_steps + 1:  # +1 因为包含结果节点
		errors.append("因果链过长（最多 %d 步）" % level.max_steps)
	
	# 检查是否有重复节点
	var seen_ids = {}
	for node_id in chain:
		if seen_ids.has(node_id):
			errors.append("节点重复：%s" % node_id)
		seen_ids[node_id] = true
	
	# 检查最后一个节点是否为结果节点
	if chain[chain.size() - 1] != level.result_id:
		errors.append("因果链必须以结果节点结尾")
	
	# 检查因果链是否连续（每个相邻节点是否有规则）
	for i in range(chain.size() - 1):
		var from_id = chain[i]
		var to_id = chain[i + 1]
		
		var rule = _find_rule(from_id, to_id, level.rules)
		if rule == null:
			errors.append("因果断裂：%s → %s 不成立" % [from_id, to_id])
		else:
			total_strength += rule.strength
	
	# 检查因果强度是否足够
	if total_strength < level.required_strength:
		errors.append("因果强度不足（%.2f / %.2f）" % [total_strength, level.required_strength])
	
	return {
		"passed": errors.is_empty(),
		"strength": total_strength,
		"errors": errors,
		"chain_length": chain.size()
	}

## 查找规则
func _find_rule(from_id: String, to_id: String, rules: Array[CausalRule]) -> CausalRule:
	for rule in rules:
		if rule.from_id == from_id and rule.to_id == to_id:
			return rule
	return null

## 计算评分等级
## chain: Array[String] - 节点ID数组
## result: Dictionary - validate_chain 返回的结果
## 返回: String - "S", "A", "B", 或 "FAIL"
func calculate_grade(chain: Array[String], result: Dictionary) -> String:
	if not result.passed:
		return "FAIL"
	
	# 强度得分（60%）：基于实际强度与要求强度的比值
	# 需要从 level 数据中获取 required_strength，这里使用默认值
	var required_strength = result.get("required_strength", 3.0)
	var strength_score = clamp(result.strength / (required_strength * 1.2), 0.0, 1.0)
	
	# 步数得分（40%）：理想步数约为5，偏离越远得分越低
	var ideal_steps = 5
	var step_diff = abs(chain.size() - ideal_steps)
	var step_score = clamp(1.0 - (step_diff * 0.15), 0.0, 1.0)
	
	# 综合得分
	var final_score = strength_score * 0.6 + step_score * 0.4
	
	# 评级
	if final_score > 0.85:
		return "S"
	elif final_score > 0.7:
		return "A"
	elif final_score > 0.6:
		return "B"
	else:
		return "FAIL"
