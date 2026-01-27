class_name CauseNode
extends Resource

## 因果节点资源类
## 表示游戏中的一个因果节点（原因或结果）

@export var id: String = ""
@export var label: String = ""
@export var tags: Array[String] = []
@export var time_stage: int = 1  # 0=early, 1=mid, 2=late
