extends Panel

## 结果反馈面板
## 显示关卡完成后的评分和反馈

signal next_level_pressed
signal retry_pressed

var current_result: Dictionary = {}
var current_grade: String = ""
var current_chain: Array[String] = []

@onready var grade_label = $VBox/GradeLabel
@onready var completeness_bar = $VBox/CompletenessBar
@onready var strength_bar = $VBox/StrengthBar
@onready var cleanliness_bar = $VBox/CleanlinessBar
@onready var comment_label = $VBox/CommentLabel
@onready var unlock_label = $VBox/UnlockLabel
@onready var next_button = $VBox/Buttons/NextButton
@onready var retry_button = $VBox/Buttons/RetryButton
@onready var share_button = $VBox/Buttons/ShareButton

func _ready():
	visible = false
	next_button.pressed.connect(_on_next_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	if share_button:
		share_button.pressed.connect(_on_share_pressed)

## 显示结果
func show_result(result: Dictionary, grade: String):
	visible = true
	current_result = result
	current_grade = grade
	current_chain = result.get("chain", [])
	
	# 检查等级提升
	var previous_grade = SaveGame.get_level_grade(GameManager.current_level_id)
	var grade_improved = _is_grade_improved(previous_grade, grade)
	
	# 设置评级
	grade_label.text = _get_grade_symbol(grade)
	grade_label.modulate = _get_grade_color(grade)
	
	# 如果等级提升，播放动画
	if grade_improved and grade != "FAIL":
		_play_grade_up_animation()
	
	# 计算并显示指标
	var completeness = _calculate_completeness(result)
	var strength_ratio = result.get("strength", 0.0) / result.get("required_strength", 1.0)
	var cleanliness = _calculate_cleanliness(result, grade)
	
	# 动画显示进度条
	_animate_bars(completeness, strength_ratio, cleanliness)
	
	# 显示评语
	comment_label.text = _get_comment(grade)
	
	# 检查共振、路径和解锁
	var unlock_texts = []
	
	# 显示路径信息
	if result.has("path_info") and result.path_info.get("matched", false):
		var path_name = result.path_info.get("path_name", "")
		var is_new = result.path_info.get("is_new", false)
		if is_new:
			unlock_texts.append("🛤️ 发现新路径：" + path_name + "（+20%奖励）")
		else:
			unlock_texts.append("🛤️ 路径：" + path_name)
	
	# 显示共振信息
	if result.has("resonances") and not result.resonances.is_empty():
		for resonance in result.resonances:
			if resonance.get("is_new", false):
				unlock_texts.append("✨ " + resonance.get("name", "") + "：" + resonance.get("unlock_text", ""))
			else:
				unlock_texts.append("💫 " + resonance.get("name", "") + "（已解锁）")
	
	# 检查其他解锁
	if result.has("unlocks"):
		unlock_texts.append("🎁 " + result.unlocks)
	
	if not unlock_texts.is_empty():
		unlock_label.text = "\n".join(unlock_texts)
		unlock_label.visible = true
	else:
		unlock_label.visible = false

func _is_grade_improved(old_grade: String, new_grade: String) -> bool:
	if old_grade.is_empty():
		return new_grade != "FAIL"
	
	var grade_values = {"S": 4, "A": 3, "B": 2, "FAIL": 0}
	var old_value = grade_values.get(old_grade, 0)
	var new_value = grade_values.get(new_grade, 0)
	return new_value > old_value

func _play_grade_up_animation():
	# 等级提升动画：缩放 + 颜色闪烁
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 缩放脉冲
	tween.tween_property(grade_label, "scale", Vector2(1.3, 1.3), 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(grade_label, "scale", Vector2(1.0, 1.0), 0.2).set_delay(0.2).set_ease(Tween.EASE_IN)
	
	# 颜色闪烁（金色）
	var original_color = grade_label.modulate
	tween.tween_property(grade_label, "modulate", Color(1.0, 0.84, 0.0), 0.2)
	tween.tween_property(grade_label, "modulate", original_color, 0.2).set_delay(0.2)

func _get_grade_symbol(grade: String) -> String:
	if I18nManager:
		match grade:
			"S": return I18nManager.translate("ui.result_panel.grade_s")
			"A": return I18nManager.translate("ui.result_panel.grade_a")
			"B": return I18nManager.translate("ui.result_panel.grade_b")
			_: return I18nManager.translate("ui.result_panel.grade_fail")
	else:
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
	if I18nManager:
		match grade:
			"S": return I18nManager.translate("ui.result_panel.comment_s")
			"A": return I18nManager.translate("ui.result_panel.comment_a")
			"B": return I18nManager.translate("ui.result_panel.comment_b")
			"FAIL": return I18nManager.translate("ui.result_panel.comment_fail")
			_: return ""
	else:
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

func _on_share_pressed():
	if current_chain.is_empty():
		return
	
	# 生成分享文本
	var share_text = ShareManager.generate_share_text(
		GameManager.current_level_id,
		current_chain,
		current_grade,
		current_result
	)
	
	# 复制到剪贴板
	ShareManager.copy_to_clipboard(share_text)
	
	# 显示提示（可以扩展为Toast提示）
	print("分享内容已复制到剪贴板")
