extends Node

## 音效管理器
## 全局自动加载单例，负责播放音效和背景音乐

const MAX_SFX_PLAYERS = 5

var sfx_players: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer = null

# 音效资源（占位符，实际需要添加音频文件）
var sfx_drag: AudioStream
var sfx_place: AudioStream
var sfx_place_fail: AudioStream
var sfx_validate: AudioStream
var sfx_success: AudioStream
var sfx_fail: AudioStream
var sfx_unlock: AudioStream
var sfx_resonance_unlock: AudioStream
var sfx_path_discover: AudioStream
var sfx_world_log_generate: AudioStream
var sfx_challenge_complete: AudioStream
var sfx_share: AudioStream

func _ready():
	# 创建音效播放器池
	for i in range(MAX_SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		sfx_players.append(player)
		add_child(player)
	
	# 创建背景音乐播放器
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
	# 加载音效资源（如果存在）
	_load_sfx_resources()
	
	# 加载背景音乐资源（如果存在）
	_load_bgm_resources()
	
	# 设置初始音量
	_update_volumes()

func _load_sfx_resources():
	# 尝试加载音效文件（如果不存在则使用占位符）
	var audio_paths = {
		"sfx_drag": "res://assets/audio/drag.ogg",
		"sfx_place": "res://assets/audio/place.ogg",
		"sfx_place_fail": "res://assets/audio/place_fail.ogg",
		"sfx_validate": "res://assets/audio/validate.ogg",
		"sfx_success": "res://assets/audio/success.ogg",
		"sfx_fail": "res://assets/audio/fail.ogg",
		"sfx_unlock": "res://assets/audio/unlock.ogg",
		"sfx_resonance_unlock": "res://assets/audio/resonance_unlock.ogg",
		"sfx_path_discover": "res://assets/audio/path_discover.ogg",
		"sfx_world_log_generate": "res://assets/audio/world_log_generate.ogg",
		"sfx_challenge_complete": "res://assets/audio/challenge_complete.ogg",
		"sfx_share": "res://assets/audio/share.ogg"
	}
	
	for key in audio_paths:
		var path = audio_paths[key]
		if ResourceLoader.exists(path):
			set(key, load(path))
		else:
			# 如果文件不存在，使用空占位符（不播放音效）
			set(key, null)

func _update_volumes():
	var settings = SaveGame.save_data.get("settings", {})
	var sfx_volume = settings.get("sound_volume", 1.0)
	var music_volume = settings.get("music_volume", 0.7)
	
	for player in sfx_players:
		player.volume_db = linear_to_db(sfx_volume)
	
	if music_player:
		music_player.volume_db = linear_to_db(music_volume)

## 播放音效
func play_sfx(stream: AudioStream):
	if not stream:
		return  # 如果音效文件不存在，不播放
	
	var player = _get_available_player()
	if player:
		player.stream = stream
		player.play()

## 获取可用的音效播放器
func _get_available_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	# 如果所有播放器都在使用，使用第一个（覆盖）
	return sfx_players[0]

## 播放背景音乐
func play_music(stream: AudioStream, loop: bool = true):
	if not music_player:
		return
	
	if music_player.stream == stream and music_player.playing:
		return  # 已经在播放相同的音乐
	
	music_player.stream = stream
	if stream:
		music_player.play()
		# 设置循环（如果stream支持）
		if stream is AudioStreamOggVorbis:
			stream.loop = loop

## 停止背景音乐
func stop_music():
	if music_player:
		music_player.stop()

## 设置音效音量
func set_sfx_volume(volume: float):
	var settings = SaveGame.save_data.get("settings", {})
	settings["sound_volume"] = clamp(volume, 0.0, 1.0)
	SaveGame.save_data["settings"] = settings
	SaveGame.save_game()
	_update_volumes()

## 设置音乐音量
func set_music_volume(volume: float):
	var settings = SaveGame.save_data.get("settings", {})
	settings["music_volume"] = clamp(volume, 0.0, 1.0)
	SaveGame.save_data["settings"] = settings
	SaveGame.save_game()
	_update_volumes()

## 便捷方法：播放各种音效
func play_drag():
	play_sfx(sfx_drag)

func play_place():
	play_sfx(sfx_place)

func play_place_fail():
	play_sfx(sfx_place_fail)

func play_validate():
	play_sfx(sfx_validate)

func play_success():
	play_sfx(sfx_success)

func play_fail():
	play_sfx(sfx_fail)

func play_unlock():
	play_sfx(sfx_unlock)

func play_resonance_unlock():
	play_sfx(sfx_resonance_unlock)

func play_path_discover():
	play_sfx(sfx_path_discover)

func play_world_log_generate():
	play_sfx(sfx_world_log_generate)

func play_challenge_complete():
	play_sfx(sfx_challenge_complete)

func play_share():
	play_sfx(sfx_share)

## 背景音乐资源
var bgm_menu: AudioStream
var bgm_game: AudioStream
var bgm_result: AudioStream

func _load_bgm_resources():
	var bgm_paths = {
		"bgm_menu": "res://assets/audio/bgm_menu.ogg",
		"bgm_game": "res://assets/audio/bgm_game.ogg",
		"bgm_result": "res://assets/audio/bgm_result.ogg"
	}
	
	for key in bgm_paths:
		var path = bgm_paths[key]
		if ResourceLoader.exists(path):
			set(key, load(path))
		else:
			set(key, null)

## 播放背景音乐（带淡入淡出）
func play_music_with_fade(stream: AudioStream, fade_time: float = 1.0):
	if not music_player:
		return
	
	if music_player.stream == stream and music_player.playing:
		return
	
	# 淡出当前音乐
	if music_player.playing:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, fade_time)
		await tween.finished
		music_player.stop()
	
	# 设置新音乐并淡入
	music_player.stream = stream
	if stream:
		music_player.volume_db = -80.0
		music_player.play()
		var tween = create_tween()
		var target_volume = linear_to_db(SaveGame.save_data.get("settings", {}).get("music_volume", 0.7))
		tween.tween_property(music_player, "volume_db", target_volume, fade_time)

## 便捷方法：播放各种背景音乐
func play_menu_music():
	play_music_with_fade(bgm_menu)

func play_game_music():
	play_music_with_fade(bgm_game)

func play_result_music():
	play_music_with_fade(bgm_result)
