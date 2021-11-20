extends ScrollContainer

var voiceButton = preload("res://GodetteVN/fundamentals/details/voiceButton.tscn")
var tb = preload("res://GodetteVN/fundamentals/details/textBoxInHistory.tscn")
var atBottom = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in game.history.size():
		var textbox = tb.instance()
		var temp = game.history[i]
		
		if vn.Chs.all_chara.has(temp[0]): # temp[0] = uid
			var c = vn.Chs.all_chara[temp[0]] 
			textbox.setName(c["display_name"], c["name_color"])
		else:
			textbox.setName(temp[0])
		textbox.setText(temp[1])
		if temp.size()>= 3:
			var vb = voiceButton.instance()
			vb.path = temp[2]
			textbox.get_node("box/VBoxContainer").add_child(vb)
		$textContainer.add_child(textbox)

func _process(_delta):
	if not atBottom:
		var bar = get_v_scrollbar()
		set_v_scroll(bar.max_value)
		atBottom = true
		set_process(false)
