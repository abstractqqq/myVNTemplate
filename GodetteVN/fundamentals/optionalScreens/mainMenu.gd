extends CanvasLayer

var last_hover : int = -1

# Preload to make this process faster ? Is this really necessary?
var saver = preload("res://GodetteVN/fundamentals/details/saveMainBox.tscn")
var loader = preload("res://GodetteVN/fundamentals/details/loadMainBox.tscn")
var setting = preload("res://GodetteVN/fundamentals/details/settingMainBox.tscn")
var hist = preload("res://GodetteVN/fundamentals/details/historyMainBox.tscn")
var items = [null, saver,loader,setting,hist]

const names = {
	1: "Save",
	2: "Load",
	3: "Setting",
	4: "History"
}

func _ready():
	vn.inSetting = true

func _input(ev):
	if ev.is_action_pressed('ui_cancel') or ev.is_action_pressed('vn_cancel'):
		get_tree().set_input_as_handled()
		vn.inSetting = false
		self.queue_free()

func _on_returnButton_pressed():
	vn.inSetting = false
	self.queue_free()

func _on_quitButton_pressed():
	notif.show("quit")

func _on_mainButton_pressed():
	notif.show("main")


func _on_saveButton_mouse_entered():
	renew_content(1)

	
func _on_loadButton_mouse_entered():
	renew_content(2)


func _on_settingButton_mouse_entered():
	renew_content(3)


func _on_histButton_mouse_entered():
	renew_content(4)


func renew_content(num:int):
	if num != last_hover:
		for n in $content.get_children():
			n.queue_free()
		last_hover = num
		$currentPage.text = names[num]
		var content = items[num].instance()
		$content.add_child(content)

