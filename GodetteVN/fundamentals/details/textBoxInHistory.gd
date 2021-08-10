extends Control

var voiceButton = preload("res://GodetteVN/fundamentals/details/voiceButton.tscn")

func setName(name, color):
	$box/VBoxContainer/speaker.set("custom_colors/font_color", color)
	$box/VBoxContainer/speaker.text = name + ": "
	
func setVoice(path:String):
	var vb = voiceButton.instance()
	vb.path = path
	get_node("box/VBoxContainer").add_child(vb)

func setText(text):
	$box/HBoxContainer/text.bbcode_text = text
	
