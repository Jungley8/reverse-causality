class_name CausalRule
extends Resource

## 因果规则资源类
## 定义两个节点之间的因果关系和强度

@export var from_id: String = ""
@export var to_id: String = ""
@export var strength: float = 0.0  # 因果强度，范围 0.0-1.0
