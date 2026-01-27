extends Panel

## 结果反馈面板
## 显示关卡完成后的评分和反馈

signal next_level_pressed
signal retry_pressed

@onready var grade_label = $VBox/GradeLabel
@onready var completeness_bar = $VBox/CompletenessBar
@onready var strength_bar = $VBox/StrengthBar
@onready var cleanliness_bar = $VBox/CleanlinessBar
@onready var comment_label = $VBox/CommentLabel
@onready var unlock_label = $VBox/UnlockLabel
@onready var next_button = $VBox/Buttons/NextButton
@onready var retry_button = $VBox/Buttons/RetryButton

func _ready():
	visible = false
	next_button.pressed.connect(_on_next_pressed)
	retry_button.pressed.connect(_on_retry_pressed)

## 显示结果
func show_result(result: Dictionary, grade: String):
	visible = true
	
	# 设置评级
	grade_label.text = _get_grade_symbol(grade)
	grade_label.modulate = _get_grade_color(grade)
	
	# 计算并显示指标
	var completeness = _calculate_completeness(result)
	var strength_ratio = result.get("strength", 0.0) / result.get("required_strength", 1.0)
	var cleanliness = _calculate_cleanliness(result, grade)
	
	# 动画显示进度条
	_animate_bars(completeness, strength_ratio, cleanliness)
	
	# 显示评语
	comment_label.text = _get_comment(grade)
	
	# 检查解锁
	if result.has("unlocks"):
		unlock_label.text = "🎁 解锁：" + result.unlocks
		unlock_label.visible = true
	else:
		unlock_label.visible = false

func _get_grade_symbol(grade: String) -> String:
	match grade:
		"S": return "███ S 级"
		"A": return "██░ A 级"
		"B": return "█░░ B 级"
		_: return "░░░ 未通过"

func _get_grade_color(grade: String) -> Color:
	match grade:
		"S": return Color(1.0, 0.84, 0.0)  # 金色
		"A": return Color(0.75, 0.75, 0.75)  # 银色
		"B": return Color(0.8, 0.5, 0.2)  # 铜色
		_: return Color(0.5, 0.5, 0.5)

func _calculate_completeness(result: Dictionary) -> float:
	# 基于是否有错误来判断完整度
	if result.get("errors", []).is_empty():
		return 1.0
	else:
		# 有错误则降低完整度
		return max(0.0, 1.0 - (result.errors.size() * 0.2))

func _calculate_cleanliness(result: Dictionary, grade: String) -> float:
	# 基于评级判断洁净度
	match grade:
		"S": return 1.0
		"A": return 0.8
		"B": return 0.6
		_: return 0.3

func _animate_bars(completeness: float, strength_ratio: float, cleanliness: float):
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(completeness_bar, "value", completeness * 100, 0.5)
	tween.tween_property(strength_bar, "value", clamp(strength_ratio * 100, 0.0, 100.0), 0.5)
	tween.tween_property(cleanliness_bar, "value", cleanliness * 100, 0.5)

func _get_comment(grade: String) -> String:
	var comments = {
		"S": "你构建了一条高度自洽的系统性因果链。\n在现实世界中，这种推理能力极其稀缺。",
		"A": "逻辑成立，但你忽略了至少一个关键中介。\n试试能否找到更完整的路径？",
		"B": "相关性被当成了因果性。\n这是人类最常见的推理陷阱。",
		"FAIL": "因果链存在断裂或逻辑冲突。\n重新审视节点之间的连接关系。"
	}
	return comments.get(grade, "")

func _on_next_pressed():
	next_level_pressed.emit()
	visible = false

func _on_retry_pressed():
	retry_pressed.emit()
	visible = false
