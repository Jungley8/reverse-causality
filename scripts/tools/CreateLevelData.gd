@tool
extends EditorScript

## 关卡数据生成工具
## 在编辑器中运行此脚本来生成关卡数据资源文件

func _run():
	print("开始生成关卡数据...")
	
	_create_level_01()
	_create_level_02()
	_create_level_03()
	
	print("关卡数据生成完成！")

func _create_level_01():
	var level = LevelData.new()
	level.result_id = "city_system_collapse"
	level.required_strength = 2.8
	level.max_steps = 6
	
	# 创建候选节点
	var candidates: Array[CauseNode] = []
	
	# 结果节点
	var result_node = CauseNode.new()
	result_node.id = "city_system_collapse"
	result_node.label = "2038年：某大型城市发生系统性崩溃"
	result_node.tags.assign(["crisis", "system"])
	result_node.time_stage = 2
	candidates.append(result_node)
	
	# 候选原因节点
	var nodes_data = [
		{"id": "tech_breakthrough", "label": "通用自动化技术突然成熟", "tags": ["tech"], "time": 0},
		{"id": "job_displacement", "label": "大规模结构性失业", "tags": ["economy", "social"], "time": 1},
		{"id": "welfare_lag", "label": "社会保障体系响应滞后", "tags": ["policy"], "time": 1},
		{"id": "social_unrest", "label": "社会情绪持续恶化", "tags": ["social"], "time": 1},
		{"id": "infra_overload", "label": "城市基础设施长期超负荷", "tags": ["infrastructure"], "time": 1},
		{"id": "capital_flight", "label": "资本外流", "tags": ["economy"], "time": 1},
		{"id": "climate_event", "label": "极端气候事件", "tags": ["environment"], "time": 0},
		{"id": "misinformation", "label": "信息系统被大量噪声污染", "tags": ["information"], "time": 1}
	]
	
	for node_data in nodes_data:
		var node = CauseNode.new()
		node.id = node_data.id
		node.label = node_data.label
		node.tags.assign(node_data.tags)
		node.time_stage = node_data.time
		candidates.append(node)
	
	level.candidates = candidates
	
	# 创建因果规则
	var rules: Array[CausalRule] = []
	var rules_data = [
		{"from": "tech_breakthrough", "to": "job_displacement", "strength": 0.7},
		{"from": "job_displacement", "to": "social_unrest", "strength": 0.6},
		{"from": "social_unrest", "to": "city_system_collapse", "strength": 0.8},
		{"from": "welfare_lag", "to": "social_unrest", "strength": 0.5},
		{"from": "infra_overload", "to": "city_system_collapse", "strength": 0.7},
		{"from": "climate_event", "to": "infra_overload", "strength": 0.6},
		{"from": "misinformation", "to": "social_unrest", "strength": 0.3},
		{"from": "capital_flight", "to": "city_system_collapse", "strength": 0.4},
		{"from": "job_displacement", "to": "welfare_lag", "strength": 0.5},
		{"from": "tech_breakthrough", "to": "infra_overload", "strength": 0.4}
	]
	
	for rule_data in rules_data:
		var rule = CausalRule.new()
		rule.from_id = rule_data.from
		rule.to_id = rule_data.to
		rule.strength = rule_data.strength
		rules.append(rule)
	
	level.rules = rules
	
	# 保存资源
	var path = "res://data/levels/level_01.tres"
	ResourceSaver.save(level, path)
	print("已创建：", path)

func _create_level_02():
	var level = LevelData.new()
	level.result_id = "ai_ban"
	level.required_strength = 3.0
	level.max_steps = 6
	
	var candidates: Array[CauseNode] = []
	
	# 结果节点
	var result_node = CauseNode.new()
	result_node.id = "ai_ban"
	result_node.label = "2042年：某国全面禁止通用AI"
	result_node.tags.assign(["policy", "ai"])
	result_node.time_stage = 2
	candidates.append(result_node)
	
	# 候选节点
	var nodes_data = [
		{"id": "ai_military_incident", "label": "AI军事系统严重事故", "tags": ["military", "ai"], "time": 0},
		{"id": "public_fear", "label": "公共恐慌扩大", "tags": ["social"], "time": 1},
		{"id": "political_opportunism", "label": "政治力量借机表态", "tags": ["politics"], "time": 1},
		{"id": "regulatory_capture", "label": "监管被既得利益绑架", "tags": ["policy"], "time": 1},
		{"id": "tech_backlash", "label": "技术信任全面崩溃", "tags": ["tech", "social"], "time": 1},
		{"id": "foreign_competition", "label": "他国AI领先", "tags": ["politics", "tech"], "time": 0},
		{"id": "ethics_report", "label": "高风险伦理评估报告", "tags": ["ethics"], "time": 0},
		{"id": "social_media_spike", "label": "社交媒体讨论激增", "tags": ["social", "media"], "time": 1}
	]
	
	for node_data in nodes_data:
		var node = CauseNode.new()
		node.id = node_data.id
		node.label = node_data.label
		node.tags.assign(node_data.tags)
		node.time_stage = node_data.time
		candidates.append(node)
	
	level.candidates = candidates
	
	# 创建规则
	var rules: Array[CausalRule] = []
	var rules_data = [
		{"from": "ai_military_incident", "to": "public_fear", "strength": 0.8},
		{"from": "public_fear", "to": "tech_backlash", "strength": 0.7},
		{"from": "tech_backlash", "to": "political_opportunism", "strength": 0.6},
		{"from": "political_opportunism", "to": "ai_ban", "strength": 0.8},
		{"from": "ethics_report", "to": "public_fear", "strength": 0.5},
		{"from": "foreign_competition", "to": "regulatory_capture", "strength": 0.4},
		{"from": "regulatory_capture", "to": "ai_ban", "strength": 0.6},
		{"from": "social_media_spike", "to": "public_fear", "strength": 0.3}  # 弱因果
	]
	
	for rule_data in rules_data:
		var rule = CausalRule.new()
		rule.from_id = rule_data.from
		rule.to_id = rule_data.to
		rule.strength = rule_data.strength
		rules.append(rule)
	
	level.rules = rules
	
	var path = "res://data/levels/level_02.tres"
	ResourceSaver.save(level, path)
	print("已创建：", path)

func _create_level_03():
	var level = LevelData.new()
	level.result_id = "ai_legal_personhood"
	level.required_strength = 3.2
	level.max_steps = 6
	
	var candidates: Array[CauseNode] = []
	
	# 结果节点
	var result_node = CauseNode.new()
	result_node.id = "ai_legal_personhood"
	result_node.label = "2050年：AI被赋予有限法律人格"
	result_node.tags.assign(["legal", "ai"])
	result_node.time_stage = 2
	candidates.append(result_node)
	
	# 候选节点
	var nodes_data = [
		{"id": "autonomous_economy", "label": "AI参与完整经济活动", "tags": ["economy", "ai"], "time": 0},
		{"id": "contract_dispute", "label": "大规模AI合约纠纷", "tags": ["legal", "economy"], "time": 1},
		{"id": "accountability_gap", "label": "责任无法明确归属", "tags": ["legal"], "time": 1},
		{"id": "legal_deadlock", "label": "现行法律失效", "tags": ["legal"], "time": 1},
		{"id": "judicial_pressure", "label": "司法系统负担爆炸", "tags": ["legal"], "time": 1},
		{"id": "corporate_lobbying", "label": "企业游说立法", "tags": ["politics", "economy"], "time": 1},
		{"id": "public_acceptance", "label": "社会心理逐步接受", "tags": ["social"], "time": 1},
		{"id": "media_framing", "label": "媒体叙事引导", "tags": ["media", "social"], "time": 1}
	]
	
	for node_data in nodes_data:
		var node = CauseNode.new()
		node.id = node_data.id
		node.label = node_data.label
		node.tags.assign(node_data.tags)
		node.time_stage = node_data.time
		candidates.append(node)
	
	level.candidates = candidates
	
	# 创建规则
	var rules: Array[CausalRule] = []
	var rules_data = [
		{"from": "autonomous_economy", "to": "contract_dispute", "strength": 0.7},
		{"from": "contract_dispute", "to": "accountability_gap", "strength": 0.8},
		{"from": "accountability_gap", "to": "legal_deadlock", "strength": 0.7},
		{"from": "legal_deadlock", "to": "ai_legal_personhood", "strength": 0.9},
		{"from": "legal_deadlock", "to": "judicial_pressure", "strength": 0.6},
		{"from": "judicial_pressure", "to": "corporate_lobbying", "strength": 0.5},
		{"from": "corporate_lobbying", "to": "ai_legal_personhood", "strength": 0.6},
		{"from": "public_acceptance", "to": "ai_legal_personhood", "strength": 0.4},
		{"from": "media_framing", "to": "public_acceptance", "strength": 0.5}
	]
	
	for rule_data in rules_data:
		var rule = CausalRule.new()
		rule.from_id = rule_data.from
		rule.to_id = rule_data.to
		rule.strength = rule_data.strength
		rules.append(rule)
	
	level.rules = rules
	
	var path = "res://data/levels/level_03.tres"
	ResourceSaver.save(level, path)
	print("已创建：", path)
