extends Node2D

var hiding = false


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		notif.clear()
		#notif.show("quit")
		reset_auto()
		reset_skip()

func _on_SettingButton_pressed():
	reset_auto()
	reset_skip()
	var setting = load(vn.SETTING_PATH)
	get_parent().add_child(setting.instance())


func _on_saveButton_mouse_entered():
	vn.noMouse = true
	

func _on_saveButton_mouse_exited():
	vn.noMouse = false


func _on_SettingButton_mouse_entered():
	vn.noMouse = true


func _on_SettingButton_mouse_exited():
	vn.noMouse = false


func _on_quitButton_mouse_entered():
	vn.noMouse = true


func _on_quitButton_mouse_exited():
	vn.noMouse = false


func _on_historyButton_mouse_entered():
	vn.noMouse = true

func _on_historyButton_mouse_exited():
	vn.noMouse = false

func _on_mainButton_mouse_entered():
	vn.noMouse = true

func _on_mainButton_mouse_exited():
	vn.noMouse = false

func _on_historyButton_pressed():
	reset_auto()
	reset_skip()
	var hist = load(vn.HIST_PATH)
	get_parent().add_child(hist.instance())


func _on_saveButton_pressed():
	reset_auto()
	reset_skip()
	fun.create_thumbnail()
	var save = load(vn.SAVE_PATH)
	get_parent().add_child(save.instance())


func _on_quitButton_pressed():
	notif.clear()
	notif.show("quit")
	reset_auto()
	reset_skip()
	
func _on_mainButton_pressed():
	notif.clear()
	notif.show("main")
	reset_auto()
	reset_skip()


func _on_autoButton_pressed():
	reset_skip()
	var auto = get_node('autoButton')
	vn.auto_on = not vn.auto_on
	if vn.auto_on:
		auto.modulate = Color(1,0,0,1)
	else:
		auto.modulate = Color(1,1,1,1)
		

func _on_autoButton_mouse_entered():
	vn.noMouse = true


func _on_autoButton_mouse_exited():
	vn.noMouse = false


func reset_auto():
	var auto = get_node('autoButton')
	auto.modulate = Color(1,1,1,1)
	vn.auto_on = false


func _on_skipButton_mouse_entered():
	vn.noMouse = true

func _on_skipButton_mouse_exited():
	vn.noMouse = false

func _on_skipButton_pressed():
	reset_auto()
	var sk = get_node('skipButton')
	vn.skipping = not vn.skipping
	if vn.skipping:
		sk.modulate = Color(1,0,0,1)
	else:
		sk.modulate = Color(1,1,1,1)

func reset_skip():
	var sk = get_node('skipButton')
	sk.modulate = Color(1,1,1,1)
	vn.skipping = false

func _on_loadButton_mouse_entered():
	vn.noMouse = true

func _on_loadButton_mouse_exited():
	vn.noMouse = false

func _on_loadButton_pressed():
	reset_auto()
	reset_skip()
	var loading = load(vn.LOAD_PATH)
	get_parent().add_child(loading.instance())


func disable_skip_auto():
	reset_auto()
	reset_skip()
	get_node("autoButton").disabled = true
	get_node("skipButton").disabled = true
	
func enable_skip_auto():
	get_node("autoButton").disabled = false
	get_node("skipButton").disabled = false


func _on_QsaveButton_mouse_entered():
	vn.noMouse = true

func _on_QsaveButton_mouse_exited():
	vn.noMouse = false

func _on_QsaveButton_pressed():
	fun.make_a_save("[Quick Save] ")

