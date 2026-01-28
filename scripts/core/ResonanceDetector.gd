extends RefCounted

## 因果共振检测器
## 检测玩家构建的因果链是否匹配共振模式

class_name ResonanceDetector

## 检测因果链中的共振模式
## chain: Array[String] - 节点ID数组（包含结果节点）
## 返回: Array[Dictionary] - 匹配的共振信息 [{ id, name, bonus_multiplier, unlock_text }]
static func detect_resonances(chain: Array[String]) -> Array[Dictionary]:
	var matched_resonances: Array[Dictionary] = []
	
	if chain.size() < 3:
		return matched_resonances  # 至少需要3个节点才能形成共振
	
	# 获取所有共振模式
	var patterns = ResonanceDatabase.get_all_patterns()
	
	# 检查每个共振模式
	for pattern in patterns:
		if _matches_pattern(chain, pattern.pattern):
			# 检查是否已解锁（避免重复检测）
			if not SaveGame.is_resonance_unlocked(pattern.id):
				# 解锁共振
				SaveGame.unlock_resonance(pattern.id)
				
				matched_resonances.append({
					"id": pattern.id,
					"name": pattern.name,
					"description": pattern.description,
					"bonus_multiplier": pattern.bonus_multiplier,
					"unlock_text": pattern.unlock_text,
					"is_new": true
				})
			else:
				# 已解锁，但仍应用加成
				matched_resonances.append({
					"id": pattern.id,
					"name": pattern.name,
					"description": pattern.description,
					"bonus_multiplier": pattern.bonus_multiplier,
					"unlock_text": "",
					"is_new": false
				})
	
	return matched_resonances

## 检查链是否匹配模式
## chain: Array[String] - 完整的因果链（包含结果节点）
## pattern: Array[String] - 共振模式（不包含结果节点）
static func _matches_pattern(chain: Array[String], pattern: Array[String]) -> bool:
	if chain.size() < pattern.size():
		return false
	
	# 在链中查找匹配的子序列
	# 模式中的节点必须按顺序出现在链中（不要求连续）
	var pattern_index = 0
	for node_id in chain:
		if pattern_index < pattern.size() and node_id == pattern[pattern_index]:
			pattern_index += 1
			if pattern_index >= pattern.size():
				return true  # 所有模式节点都找到了
	
	return pattern_index >= pattern.size()

## 计算共振加成后的强度
## base_strength: float - 基础强度
## resonances: Array[Dictionary] - 检测到的共振
## 返回: float - 加成后的强度
static func apply_resonance_bonus(base_strength: float, resonances: Array[Dictionary]) -> float:
	if resonances.is_empty():
		return base_strength
	
	# 使用最大的加成倍数（不叠加，避免过度奖励）
	var max_multiplier = 1.0
	for resonance in resonances:
		if resonance.has("bonus_multiplier"):
			max_multiplier = max(max_multiplier, resonance.bonus_multiplier)
	
	return base_strength * max_multiplier
