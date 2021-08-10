extends CanvasLayer

#------------------------------------------------------------------------------
func _ready():
	# no need to read quit message to quit the game in main menu
	get_tree().set_auto_accept_quit(true)
	OS.set_window_maximized(true)
	
func _on_exitButton_pressed():
	get_tree().quit()

func _on_settingsButton_pressed():
	var setting = load(vn.SETTING_PATH)
	self.add_child(setting.instance())

func _on_newGameButton_pressed():
	game.load_instruction = "new_game"
	var error = get_tree().change_scene(vn.ROOT_DIR + vn.start_scene_path)
	if error == OK:
		self.queue_free()

func _on_loadButton_pressed():
	var loading = load(vn.LOAD_PATH)
	self.add_child(loading.instance())

