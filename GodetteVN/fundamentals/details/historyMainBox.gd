extends ScrollContainer

var tb = preload("res://GodetteVN/fundamentals/details/textBoxInHistory.tscn")
var atBottom = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in game.history.size():
		var textbox = tb.instance()
		var temp = game.history[i]
		var c = chara.all_chara[temp[0]]
		textbox.setName(c["display_name"], c["name_color"])
		textbox.setText(temp[1])
		if temp.size()>= 3:
			textbox.setVoice(temp[2])
		$textContainer.add_child(textbox)

func _process(_delta):
	if not atBottom:
		var bar = get_v_scrollbar()
		set_v_scroll(bar.max_value)
		atBottom = true
		set_process(false)
