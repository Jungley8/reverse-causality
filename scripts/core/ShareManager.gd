extends RefCounted

## 社交分享管理器
## 生成分享内容和图片

class_name ShareManager

## 生成分享文本
## level_id: int - 关卡ID
## chain: Array[String] - 因果链
## grade: String - 评分
## result: Dictionary - 结果信息（包含路径、共振等）
## 返回: String - 分享文本
static func generate_share_text(level_id: int, chain: Array[String], grade: String, result: Dictionary) -> String:
	var text_parts: Array[String] = []
	
	# 标题
	text_parts.append(I18nManager.translate("share.title", {"level": str(level_id)}))
	text_parts.append("")
	
	# 因果链（转换为标签）
	var chain_labels = _get_chain_labels(level_id, chain)
	text_parts.append(I18nManager.translate("share.chain", {"chain": " → ".join(chain_labels)}))
	text_parts.append("")
	
	# 评分
	text_parts.append(I18nManager.translate("share.grade", {"grade": grade}))
	
	# 发现的路径
	if result.has("path_info") and result.path_info.get("matched", false):
		var path_name = result.path_info.get("path_name", "")
		text_parts.append(I18nManager.translate("ui.result_panel.path") + "：" + path_name)
	
	# 解锁的共振
	if result.has("resonances") and not result.resonances.is_empty():
		var resonance_names = []
		for resonance in result.resonances:
			if resonance.get("is_new", false):
				resonance_names.append(resonance.get("name", ""))
		if not resonance_names.is_empty():
			text_parts.append(I18nManager.translate("ui.result_panel.unlocked") + "：" + "、".join(resonance_names))
	
	text_parts.append("")
	text_parts.append(I18nManager.translate("share.play_now"))
	
	return "\n".join(text_parts)

## 获取因果链标签
static func _get_chain_labels(level_id: int, chain: Array[String]) -> Array[String]:
	var labels: Array[String] = []
	
	# 尝试加载关卡数据
	var level_path = "res://data/levels/level_%02d.tres" % level_id
	if level_id == 101:
		level_path = "res://data/levels/level_hidden_01.tres"
	
	if not ResourceLoader.exists(level_path):
		return chain  # 如果找不到，返回ID
	
	var level_data = load(level_path) as LevelData
	if not level_data:
		return chain
	
	# 创建 ID到标签的映射，优先使用 i18n
	var id_to_label = {}
	for candidate in level_data.candidates:
		var translated = I18nManager.translate("nodes." + candidate.id)
		if translated.begins_with("nodes."):
			id_to_label[candidate.id] = candidate.label
		else:
			id_to_label[candidate.id] = translated
	
	# 转换 ID 为标签
	for node_id in chain:
		if id_to_label.has(node_id):
			labels.append(id_to_label[node_id])
		else:
			# 如果没有在 level 中找到，尝试直接翻译
			var translated = I18nManager.translate("nodes." + node_id)
			if translated.begins_with("nodes."):
				labels.append(node_id)
			else:
				labels.append(translated)
	
	return labels

## 复制文本到剪贴板
## 返回 true 表示已尝试写入剪贴板，false 表示未支持（如 Web 下无 JavaScriptBridge）
static func copy_to_clipboard(text: String) -> bool:
	if OS.get_name() == "Web":
		if Engine.has_singleton("JavaScriptBridge"):
			var bridge = Engine.get_singleton("JavaScriptBridge")
			var escaped = text.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n").replace("\r", "\\r")
			var js_code = "(function(){ var t = '" + escaped + "'; if (navigator.clipboard && navigator.clipboard.writeText) { navigator.clipboard.writeText(t).catch(function(e){ console.error(e); }); } else { var ta = document.createElement('textarea'); ta.value = t; ta.style.position = 'fixed'; ta.style.opacity = '0'; document.body.appendChild(ta); ta.select(); document.execCommand('copy'); document.body.removeChild(ta); } })();"
			bridge.eval(js_code, true)
			return true
		else:
			print("分享文本（Web 未提供 JavaScriptBridge）：")
			print(text)
			return false
	else:
		DisplayServer.clipboard_set(text)
		return true

## 生成分享图片（简化版：返回文本描述）
## 完整实现需要渲染到Image并保存
static func generate_share_image(level_id: int, chain: Array[String], grade: String, result: Dictionary) -> Image:
	# 创建一个简单的图片
	var image = Image.create(800, 600, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.1, 0.1, 0.15))  # 深色背景
	
	# 注意：实际实现需要：
	# 1. 使用RenderingServer或CanvasItem绘制文本和图形
	# 2. 或者使用第三方库
	# 这里只提供基础框架
	
	return image

## 分享到社交媒体（Web平台）
static func share_to_social_media(text: String, url: String = ""):
	if OS.get_name() == "Web":
		# 使用Web Share API
		var js_code = """
		if (navigator.share) {
			navigator.share({
				title: '逆果溯因',
				text: '%s',
				url: '%s'
			}).then(() => {
				console.log('Shared successfully');
			}).catch(err => {
				console.error('Error sharing:', err);
			});
		} else {
			console.log('Web Share API not supported');
		}
		""" % [text, url]
		
		# JavaScript.eval(js_code)
		print("分享到社交媒体（需要Web Share API支持）")
	else:
		print("当前平台不支持Web Share API")
