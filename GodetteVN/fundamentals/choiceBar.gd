extends TextureButton

signal choice_made(event)

var choice_action = null

func setup_choice(text:String, ev:Dictionary, infer_chosen:bool=false):
	setup_choice_event(text,ev)
	var cur_sc = game.currentNodePath
	if infer_chosen and fileRelated.system_data.has(cur_sc):
		var cur_bl = game.currentBlock
		var cur_idx = game.currentIndex
		match ev:
			{'then',..}:
				cur_bl = ev['then']
				cur_idx = -1
				
		var max_idx = fileRelated.system_data[cur_sc][cur_bl]
		if max_idx > cur_idx:
			# set it 
			$text.add_color_override("default_color", Color("#535252"))
			

func setup_choice_event(t: String, ev: Dictionary):
	get_node('text').bbcode_text = "[center]" + t + "[/center]"
	choice_action = ev

func _on_choiceBar_pressed():
	emit_signal("choice_made", choice_action)


