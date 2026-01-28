class_name LevelData
extends Resource

## 关卡数据资源类
## 包含一个关卡的所有数据：结果节点、候选节点、规则等

@export var result_id: String = ""
@export var required_strength: float = 0.0
@export var max_steps: int = 6
@export var candidates: Array[CauseNode] = []
@export var rules: Array[CausalRule] = []
@export var valid_paths: Array[Dictionary] = []  # [{ name: String, path: Array[String], difficulty: int, bonus_multiplier: float }]
