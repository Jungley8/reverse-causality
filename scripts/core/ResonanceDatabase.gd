extends RefCounted

## 因果共振规则数据库
## 定义所有可检测的共振模式

class_name ResonanceDatabase

## 共振模式数据结构
class ResonancePattern:
	var id: String
	var name: String
	var pattern: Array[String]  # 节点ID序列
	var description: String
	var bonus_multiplier: float
	var unlock_text: String
	
	func _init(p_id: String, p_name: String, p_pattern: Array[String], p_description: String, p_bonus: float, p_unlock_text: String):
		id = p_id
		name = p_name
		pattern = p_pattern
		description = p_description
		bonus_multiplier = p_bonus
		unlock_text = p_unlock_text

## 所有共振模式
static var patterns: Array[ResonancePattern] = []

## 初始化共振模式
static func initialize():
	if not patterns.is_empty():
		return  # 已经初始化过
	
	# 卢德循环：技术进步 → 失业 → 社会动荡
	patterns.append(ResonancePattern.new(
		"luddite_loop",
		"卢德循环",
		["tech_breakthrough", "job_displacement", "social_unrest"],
		"技术进步 → 失业 → 社会动荡",
		1.2,
		"你重现了 200 年前的经典因果链"
	))
	
	# 黑天鹅事件：气候事件 → 基础设施过载 → 系统崩溃
	patterns.append(ResonancePattern.new(
		"black_swan",
		"黑天鹅事件",
		["climate_event", "infra_overload", "system_collapse"],
		"气候事件 → 基础设施过载 → 系统崩溃",
		1.3,
		"你发现了不可预测的极端因果链"
	))
	
	# 信息级联：错误信息 → 公众恐慌 → 政策转变
	patterns.append(ResonancePattern.new(
		"info_cascade",
		"信息级联",
		["misinformation", "public_fear", "policy_shift"],
		"错误信息 → 公众恐慌 → 政策转变",
		1.15,
		"你揭示了信息传播的连锁反应"
	))
	
	# 技术依赖陷阱：技术依赖 → 技能退化 → 脆弱性增加
	patterns.append(ResonancePattern.new(
		"tech_dependency",
		"技术依赖陷阱",
		["tech_dependency", "skill_degradation", "vulnerability"],
		"技术依赖 → 技能退化 → 脆弱性增加",
		1.1,
		"你发现了过度依赖技术的危险"
	))
	
	# 资源争夺：资源稀缺 → 竞争加剧 → 冲突升级
	patterns.append(ResonancePattern.new(
		"resource_conflict",
		"资源争夺",
		["resource_scarcity", "competition", "conflict_escalation"],
		"资源稀缺 → 竞争加剧 → 冲突升级",
		1.25,
		"你揭示了资源分配的根本矛盾"
	))

## 获取所有共振模式
static func get_all_patterns() -> Array[ResonancePattern]:
	if patterns.is_empty():
		initialize()
	return patterns

## 根据ID获取共振模式
static func get_pattern_by_id(pattern_id: String) -> ResonancePattern:
	if patterns.is_empty():
		initialize()
	
	for pattern in patterns:
		if pattern.id == pattern_id:
			return pattern
	return null
