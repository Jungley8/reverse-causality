extends Node

## 资源预加载系统
## 全局自动加载单例，负责预加载关键场景和资源，提升性能

signal preload_progress(progress: float)  # 加载进度信号 (0.0 - 1.0)
signal preload_complete  # 预加载完成信号

var preloaded_scenes: Dictionary = {}
var preloaded_audio: Dictionary = {}
var is_preloading: bool = false
var preload_progress_value: float = 0.0

## 关键场景路径
const CRITICAL_SCENES = {
	"main_menu": "res://scenes/ui/MainMenu.tscn",
	"level_select": "res://scenes/ui/LevelSelect.tscn",
	"game_main": "res://scenes/game/GameMain.tscn",
	"result_panel": "res://scenes/ui/ResultPanel.tscn",
	"archive": "res://scenes/ui/Archive.tscn",
	"tutorial": "res://scenes/tutorial/Tutorial.tscn"
}

## 常用音效路径（如果存在）
const COMMON_AUDIO = {
	"drag": "res://assets/audio/drag.ogg",
	"place": "res://assets/audio/place.ogg",
	"place_fail": "res://assets/audio/place_fail.ogg",
	"validate": "res://assets/audio/validate.ogg",
	"success": "res://assets/audio/success.ogg",
	"fail": "res://assets/audio/fail.ogg",
	"unlock": "res://assets/audio/unlock.ogg"
}

func _ready():
	# 延迟预加载，避免阻塞游戏启动
	call_deferred("start_preload")

## 开始预加载
func start_preload():
	if is_preloading:
		return
	
	is_preloading = true
	preload_progress_value = 0.0
	
	# 异步预加载
	await _preload_critical_resources()

## 预加载关键资源
func _preload_critical_resources():
	var total_items = CRITICAL_SCENES.size() + COMMON_AUDIO.size()
	var loaded_items = 0
	
	# 预加载场景
	for scene_name in CRITICAL_SCENES:
		var scene_path = CRITICAL_SCENES[scene_name]
		if ResourceLoader.exists(scene_path):
			# 使用异步加载
			ResourceLoader.load_threaded_request(scene_path)
			await get_tree().process_frame
			
			# 等待加载完成
			while true:
				var progress = []
				var status = ResourceLoader.load_threaded_get_status(scene_path, progress)
				
				if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
					await get_tree().process_frame
				elif status == ResourceLoader.THREAD_LOAD_LOADED:
					var scene = ResourceLoader.load_threaded_get(scene_path)
					if scene:
						preloaded_scenes[scene_name] = scene
					break
				else:
					# 加载失败，尝试同步加载
					if ResourceLoader.exists(scene_path):
						var scene = load(scene_path)
						if scene:
							preloaded_scenes[scene_name] = scene
					break
		
		loaded_items += 1
		preload_progress_value = float(loaded_items) / float(total_items)
		preload_progress.emit(preload_progress_value)
		await get_tree().process_frame
	
	# 预加载音效（如果存在）
	for audio_name in COMMON_AUDIO:
		var audio_path = COMMON_AUDIO[audio_name]
		if ResourceLoader.exists(audio_path):
			var audio = load(audio_path)
			if audio:
				preloaded_audio[audio_name] = audio
		
		loaded_items += 1
		preload_progress_value = float(loaded_items) / float(total_items)
		preload_progress.emit(preload_progress_value)
		await get_tree().process_frame
	
	is_preloading = false
	preload_complete.emit()

## 获取预加载的场景
func get_scene(scene_name: String) -> PackedScene:
	if preloaded_scenes.has(scene_name):
		return preloaded_scenes[scene_name]
	
	# 如果未预加载，尝试直接加载
	var scene_path = CRITICAL_SCENES.get(scene_name, "")
	if scene_path and ResourceLoader.exists(scene_path):
		var scene = load(scene_path)
		if scene:
			preloaded_scenes[scene_name] = scene
			return scene
	
	return null

## 获取预加载的音效
func get_audio(audio_name: String) -> AudioStream:
	if preloaded_audio.has(audio_name):
		return preloaded_audio[audio_name]
	
	# 如果未预加载，尝试直接加载
	var audio_path = COMMON_AUDIO.get(audio_name, "")
	if audio_path and ResourceLoader.exists(audio_path):
		var audio = load(audio_path)
		if audio:
			preloaded_audio[audio_name] = audio
			return audio
	
	return null

## 检查场景是否已预加载
func is_scene_preloaded(scene_name: String) -> bool:
	return preloaded_scenes.has(scene_name)

## 检查音效是否已预加载
func is_audio_preloaded(audio_name: String) -> bool:
	return preloaded_audio.has(audio_name)

## 获取预加载进度
func get_progress() -> float:
	return preload_progress_value

## 检查是否正在预加载
func is_preloading_active() -> bool:
	return is_preloading
