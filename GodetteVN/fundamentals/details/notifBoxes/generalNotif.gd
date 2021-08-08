extends TextureRect

var type : String

var following = false
var dragging_start_pos = Vector2()

# Used if type = override
signal decision(yes)

func _on_back2MainBox_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			following = !following
			dragging_start_pos = get_local_mouse_position()


func _process(_delta):
	if following:
		self.rect_position = (get_global_mouse_position() - dragging_start_pos)

func set_text(which:String):
	self.type = which
	var tbox = self.get_node("notifText")
	match type:
		"quit":
			tbox.bbcode_text = "Do you want to quit the game?"
		"main":
			tbox.bbcode_text = "Do you want to go back to main menu?"
		"override":
			tbox.bbcode_text = "Do you want to override the save?"
		"rollback":
			tbox.bbcode_text = "You cannot rollback anymore."
			get_node("okButton").visible = true
			get_node("noButton").visible = false
			get_node("yesButton").visible = false
		_:
			notif.hide()


func _on_noButton_pressed():
	notif.hide()

func _on_yesButton_pressed():
	match type:
		"main":
			screenEffects.removeLasting()
			screenEffects.weather_off()
			music.stop_bgm()
			stage.remove_chara('absolute_all')
			#----------------------------------------
			var error = get_tree().change_scene(vn.ROOT_DIR + vn.main_menu_path)
			if error == OK:
				vn.reset_states()
		"override":
			emit_signal("decision", true)
			
		"quit":
			get_tree().quit()
	
	notif.hide()

func _on_okButton_pressed():
	notif.hide()
