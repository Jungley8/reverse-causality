extends Node

## 响应式UI管理器
## 全局自动加载单例，负责处理不同屏幕尺寸下的UI适配

const BASE_WIDTH = 1280
const BASE_HEIGHT = 720

signal ui_scale_changed(scale: float)

var current_scale: float = 1.0

func _ready():
	# 监听视口大小变化
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	# 初始计算
	_update_scale()

func _on_viewport_size_changed():
	_update_scale()

func _update_scale():
	var viewport_size = get_viewport().get_visible_rect().size
	
	# 计算缩放比例（基于宽度和高度的最小值，保持宽高比）
	var scale_x = viewport_size.x / BASE_WIDTH
	var scale_y = viewport_size.y / BASE_HEIGHT
	var new_scale = min(scale_x, scale_y)
	
	# 限制缩放范围（0.5x 到 2.0x）
	new_scale = clamp(new_scale, 0.5, 2.0)
	
	if abs(new_scale - current_scale) > 0.01:  # 避免微小变化触发
		current_scale = new_scale
		ui_scale_changed.emit(current_scale)
		_apply_scale_to_root()

func _apply_scale_to_root():
	# 使用Stretch模式来处理响应式布局
	# Godot的viewport stretch设置应该在项目设置中配置
	# 这里主要提供缩放比例信息，供UI节点使用
	pass

## 获取当前缩放比例
func get_scale() -> float:
	return current_scale

## 将像素值转换为当前缩放下的值
func scale_pixel(value: float) -> float:
	return value * current_scale
