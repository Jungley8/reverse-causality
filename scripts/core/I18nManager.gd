extends Node

## 国际化管理器
## 全局自动加载单例，负责多语言支持

signal language_changed(language: String)

const DEFAULT_LANGUAGE = "zh_CN"
const LOCALE_PATH = "res://data/locales/"

var current_language: String = DEFAULT_LANGUAGE
var default_translations: Dictionary = {}
var translations: Dictionary = {}

func _ready():
	# 预加载默认语言包作为后备
	_load_default_locale()
	
	# 从SaveGame加载语言偏好
	var settings = SaveGame.save_data.get("settings", {})
	var saved_language = settings.get("language", DEFAULT_LANGUAGE)
	set_language(saved_language)

## 设置语言
func set_language(language: String):
	if language == current_language and not translations.is_empty():
		return  # 已经是当前语言
	
	current_language = language
	
	# 加载语言包
	_load_locale(language)
	
	# 保存到设置
	var settings = SaveGame.save_data.get("settings", {})
	settings["language"] = language
	SaveGame.save_data["settings"] = settings
	SaveGame.save_game()
	
	# 发送信号
	language_changed.emit(language)

## 加载语言包
func _load_locale(language: String):
	var locale_file = LOCALE_PATH + language + ".json"
	
	if not ResourceLoader.exists(locale_file):
		push_warning("语言包不存在: " + locale_file + "，使用默认语言")
		if language != DEFAULT_LANGUAGE:
			_load_locale(DEFAULT_LANGUAGE)
		return
	
	var file = FileAccess.open(locale_file, FileAccess.READ)
	if not file:
		push_error("无法打开语言包: " + locale_file)
		return
	
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(content)
	
	if error == OK:
		translations = json.data
		print("已加载语言包: " + language)
	else:
		push_error("语言包解析失败: " + json.get_error_message())
		translations = {}

## 加载默认语言包
func _load_default_locale():
	var locale_file = LOCALE_PATH + DEFAULT_LANGUAGE + ".json"
	if not ResourceLoader.exists(locale_file):
		return
		
	var file = FileAccess.open(locale_file, FileAccess.READ)
	if not file:
		return
		
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(content) == OK:
		default_translations = json.data

## 翻译文本
## key: 翻译键，格式如 "ui.main_menu.start_game"
## format_dict: 可选的格式化字典，用于替换 {key} 占位符
func translate(key: String, format_dict: Dictionary = {}) -> String:
	if translations.is_empty():
		return key  # 如果未加载语言包，返回键本身
	
	var keys = key.split(".")
	var value = translations
	
	for k in keys:
		if value.has(k):
			value = value[k]
		else:
			# 如果找不到，尝试使用默认语言
			if current_language != DEFAULT_LANGUAGE:
				return _translate_fallback(key, format_dict)
			return key  # 返回键本身作为后备
	
	if typeof(value) == TYPE_STRING:
		var result = value
		# 应用格式化
		if not format_dict.is_empty():
			for format_key in format_dict:
				var placeholder = "{" + format_key + "}"
				var format_value = str(format_dict[format_key])
				result = result.replace(placeholder, format_value)
		return result
	else:
		return key  # 如果值不是字符串，返回键

## 使用默认语言作为后备
func _translate_fallback(key: String, format_dict: Dictionary = {}) -> String:
	if default_translations.is_empty():
		return key
		
	var keys = key.split(".")
	var value = default_translations
	
	for k in keys:
		if value.has(k):
			value = value[k]
		else:
			return key
	
	if typeof(value) == TYPE_STRING:
		var result = value
		# 应用格式化
		if not format_dict.is_empty():
			for format_key in format_dict:
				var placeholder = "{" + format_key + "}"
				var format_value = str(format_dict[format_key])
				result = result.replace(placeholder, format_value)
		return result
	else:
		return key

## 获取当前语言
func get_current_language() -> String:
	return current_language

## 获取可用语言列表
func get_available_languages() -> Array[String]:
	return ["zh_CN", "en_US"]

## 获取语言显示名称
func get_language_display_name(language: String) -> String:
	match language:
		"zh_CN":
			return "简体中文"
		"en_US":
			return "English"
		_:
			return language
