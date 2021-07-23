extends CanvasLayer

var text = preload("res://GodetteVN/fundamentals/details/textBoxInHistory.tscn")
var atBottom = false


func _ready():
	vn.inSetting = true
	var container = $ScrollContainer/textContainer
	for i in game.history.size():
		var textbox = text.instance()
		var temp = game.history[i]
		var c = stage.get_character_info(temp[0])
		textbox.setName(c["display_name"], c["name_color"])
		textbox.setText(temp[1])
		container.add_child(textbox)

func _on_returnButton_pressed():
	vn.inSetting = false
	self.queue_free()

func _process(_delta):
	if not atBottom:
		var scrollContainer = $ScrollContainer
		var bar = scrollContainer.get_v_scrollbar()
		scrollContainer.set_v_scroll(bar.max_value)
		atBottom = true
		set_process(false)
	
func _input(ev):
	if ev.is_action_pressed('ui_cancel') or ev.is_action_pressed('vn_cancel'):
		get_tree().set_input_as_handled()
		vn.inSetting = false
		self.queue_free()
		
