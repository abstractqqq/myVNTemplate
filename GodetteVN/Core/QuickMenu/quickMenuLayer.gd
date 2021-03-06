extends Node2D

var hiding = false

func _on_SettingButton_pressed():
	reset_auto_skip()
	vn.Scene.add_child(load(vn.SETTING_PATH).instance())

func on_historyButton_pressed():
	reset_auto_skip()
	vn.Scene.add_child(load(vn.HIST_PATH).instance())


func _on_saveButton_pressed():
	reset_auto_skip()
	vn.Utils.create_thumbnail()
	vn.Scene.add_child(load(vn.SAVE_PATH).instance())


func _on_quitButton_pressed():
	vn.Notifs.show("quit")
	reset_auto_skip()
	
func _on_mainButton_pressed():
	vn.Notifs.show("main")
	reset_auto_skip()


func _on_autoButton_pressed():
	reset_skip()
	var auto = get_node('autoButton')
	vn.auto_on = not vn.auto_on
	if vn.auto_on:
		auto.modulate = Color(1,0,0,1)
	else:
		auto.modulate = Color(1,1,1,1)

func reset_auto():
	var auto = get_node('autoButton')
	auto.disabled = false
	auto.modulate = Color(1,1,1,1)
	vn.auto_on = false


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
	sk.disabled = false
	sk.modulate = Color(1,1,1,1)
	vn.skipping = false
	
func _on_loadButton_pressed():
	reset_auto_skip()
	var loading = load(vn.LOAD_PATH)
	get_parent().add_child(loading.instance())

func reset_auto_skip():
	reset_auto()
	reset_skip()

func disable_skip_auto():
	reset_auto_skip()
	get_node("autoButton").disabled = true
	get_node("skipButton").disabled = true
	
func enable_skip_auto():
	get_node("autoButton").disabled = false
	get_node("skipButton").disabled = false


func _on_QsaveButton_pressed():
	var flt = load(vn.DEFAULT_FLOAT).instance()
	screen.add_child(flt)
	flt.display("Quick save made.", 2, 0.5, Vector2(60,60), 'res://fonts/ARegular.tres')
	vn.Utils.make_a_save("[Quick Save] ")
