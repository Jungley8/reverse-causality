extends CanvasLayer

## 异步场景切换系统
## 提供流畅的场景切换动画和异步加载功能

signal transition_finished

@onready var fade_rect: ColorRect = $FadeRect
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var progress_label: Label = $ProgressLabel

var is_transitioning: bool = false

func _ready():
	# 初始化淡入淡出矩形
	if not fade_rect:
		fade_rect = ColorRect.new()
		fade_rect.name = "FadeRect"
		fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		fade_rect.color = Color(0, 0, 0, 0)
		fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(fade_rect)
	
	# 初始化进度条
	if not progress_bar:
		progress_bar = ProgressBar.new()
		progress_bar.name = "ProgressBar"
		progress_bar.set_anchors_preset(Control.PRESET_CENTER_TOP)
		progress_bar.offset_left = -200
		progress_bar.offset_top = 50
		progress_bar.offset_right = 200
		progress_bar.offset_bottom = 70
		progress_bar.max_value = 100
		progress_bar.value = 0
		progress_bar.visible = false
		add_child(progress_bar)
	
	# 初始化进度标签
	if not progress_label:
		progress_label = Label.new()
		progress_label.name = "ProgressLabel"
		progress_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
		progress_label.offset_left = -100
		progress_label.offset_top = 80
		progress_label.offset_right = 100
		progress_label.offset_bottom = 100
		progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		progress_label.text = ""
		progress_label.visible = false
		add_child(progress_label)
	
	# 确保在最上层
	layer = 100

## 切换场景（带淡入淡出动画）
func change_scene(scene_path: String, show_progress: bool = true):
	if is_transitioning:
		return
	
	is_transitioning = true
	
	# 淡出
	await _fade_out()
	
	# 异步加载场景
	if show_progress:
		progress_bar.visible = true
		progress_label.visible = true
	
	await _load_scene_async(scene_path)
	
	if show_progress:
		progress_bar.visible = false
		progress_label.visible = false
	
	# 淡入
	await _fade_in()
	
	is_transitioning = false
	transition_finished.emit()

## 使用预加载的场景切换（更快）
func change_scene_preloaded(scene_name: String):
	if is_transitioning:
		return
	
	if not Preloader:
		# 如果没有Preloader，使用普通切换
		var scene_path = Preloader.CRITICAL_SCENES.get(scene_name, "")
		if scene_path:
			await change_scene(scene_path)
		return
	
	# 检查是否已预加载
	if Preloader.is_scene_preloaded(scene_name):
		is_transitioning = true
		await _fade_out()
		
		var scene = Preloader.get_scene(scene_name)
		if scene:
			get_tree().change_scene_to_packed(scene)
		else:
			# 如果预加载失败，使用普通加载
			var scene_path = Preloader.CRITICAL_SCENES.get(scene_name, "")
			if scene_path:
				await change_scene(scene_path)
		
		await _fade_in()
		is_transitioning = false
		transition_finished.emit()
	else:
		# 未预加载，使用普通切换
		var scene_path = Preloader.CRITICAL_SCENES.get(scene_name, "")
		if scene_path:
			await change_scene(scene_path)

## 异步加载场景
func _load_scene_async(scene_path: String):
	if not ResourceLoader.exists(scene_path):
		push_error("场景不存在: " + scene_path)
		return
	
	# 请求异步加载
	ResourceLoader.load_threaded_request(scene_path)
	
	# 等待加载完成
	while true:
		var progress = []
		var status = ResourceLoader.load_threaded_get_status(scene_path, progress)
		
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			# 更新进度条
			var progress_value = progress[0] * 100
			progress_bar.value = progress_value
			progress_label.text = "加载中... %.0f%%" % progress_value
			await get_tree().process_frame
		elif status == ResourceLoader.THREAD_LOAD_LOADED:
			# 加载完成，获取场景
			var scene = ResourceLoader.load_threaded_get(scene_path)
			if scene:
				get_tree().change_scene_to_packed(scene)
			else:
				push_error("场景加载失败: " + scene_path)
			break
		else:
			# 加载失败，尝试同步加载
			push_warning("异步加载失败，尝试同步加载: " + scene_path)
			var scene = load(scene_path)
			if scene:
				get_tree().change_scene_to_packed(scene)
			else:
				push_error("场景加载失败: " + scene_path)
			break

## 淡出动画
func _fade_out() -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.3)
	await tween.finished

## 淡入动画
func _fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, 0.3)
	await tween.finished

## 检查是否正在切换
func is_transitioning_active() -> bool:
	return is_transitioning
