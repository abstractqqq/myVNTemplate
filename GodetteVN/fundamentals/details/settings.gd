extends Node

func _ready():
	vn.inSetting = true
	

func _on_BackButton_pressed():
	vn.inSetting = false
	fileRelated.write_to_config()
	self.queue_free()
	

func _input(ev):
	if ev.is_action_pressed('ui_cancel') or ev.is_action_pressed('vn_cancel'):
		get_tree().set_input_as_handled()
		_on_BackButton_pressed()
