extends Node

## 性能监控工具
## 用于调试和性能分析

const DEBUG_MODE = false  # 设置为true启用性能监控

var fps_label: Label = null
var memory_label: Label = null
var stats_container: Control = null

var frame_count: int = 0
var fps_history: Array[float] = []
var max_fps_history: int = 60  # 记录60帧的FPS

var memory_usage_mb: float = 0.0

func _ready():
	if not DEBUG_MODE:
		return
	
	_create_debug_ui()

func _create_debug_ui():
	# 创建调试UI容器
	stats_container = Control.new()
	stats_container.name = "PerformanceStats"
	stats_container.set_anchors_preset(Control.PRESET_TOP_LEFT)
	stats_container.offset_left = 10
	stats_container.offset_top = 10
	stats_container.offset_right = 300
	stats_container.offset_bottom = 100
	stats_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# FPS标签
	fps_label = Label.new()
	fps_label.name = "FPSLabel"
	fps_label.text = "FPS: --"
	fps_label.add_theme_font_size_override("font_size", 14)
	fps_label.modulate = Color(0, 1, 0)  # 绿色
	stats_container.add_child(fps_label)
	
	# 内存标签
	memory_label = Label.new()
	memory_label.name = "MemoryLabel"
	memory_label.text = "Memory: -- MB"
	memory_label.add_theme_font_size_override("font_size", 14)
	memory_label.modulate = Color(0, 1, 0)
	memory_label.position.y = 25
	stats_container.add_child(memory_label)
	
	# 添加到场景树
	get_tree().root.add_child(stats_container)
	stats_container.set_as_top_level(true)

func _process(_delta: float):
	if not DEBUG_MODE or not stats_container:
		return
	
	frame_count += 1
	
	# 更新FPS
	var current_fps = Engine.get_frames_per_second()
	fps_history.append(current_fps)
	if fps_history.size() > max_fps_history:
		fps_history.pop_front()
	
	# 计算平均FPS
	var avg_fps = 0.0
	if not fps_history.is_empty():
		for fps in fps_history:
			avg_fps += fps
		avg_fps /= fps_history.size()
	
	# 更新FPS显示（每10帧更新一次）
	if frame_count % 10 == 0:
		if fps_label:
			var color = Color(0, 1, 0)  # 绿色
			if avg_fps < 30:
				color = Color(1, 0, 0)  # 红色
			elif avg_fps < 50:
				color = Color(1, 1, 0)  # 黄色
			
			fps_label.text = "FPS: %.1f (Avg: %.1f)" % [current_fps, avg_fps]
			fps_label.modulate = color
		
		# 更新内存显示
		if memory_label:
			_update_memory_display()

func _update_memory_display():
	if not memory_label:
		return
	
	# 获取内存使用情况（Godot 4的方法）
	var memory_usage = Performance.get_monitor(Performance.MEMORY_STATIC)
	memory_usage_mb = memory_usage / (1024.0 * 1024.0)  # 转换为MB
	
	var color = Color(0, 1, 0)  # 绿色
	if memory_usage_mb > 500:
		color = Color(1, 0, 0)  # 红色
	elif memory_usage_mb > 200:
		color = Color(1, 1, 0)  # 黄色
	
	memory_label.text = "Memory: %.1f MB" % memory_usage_mb
	memory_label.modulate = color

## 获取当前FPS
func get_current_fps() -> float:
	return Engine.get_frames_per_second()

## 获取平均FPS
func get_average_fps() -> float:
	if fps_history.is_empty():
		return 0.0
	
	var sum = 0.0
	for fps in fps_history:
		sum += fps
	return sum / fps_history.size()

## 获取内存使用（MB）
func get_memory_usage_mb() -> float:
	return memory_usage_mb

## 启用/禁用调试模式
func set_debug_mode(enabled: bool):
	if enabled and not stats_container:
		_create_debug_ui()
	elif not enabled and stats_container:
		if stats_container:
			stats_container.queue_free()
			stats_container = null
			fps_label = null
			memory_label = null
