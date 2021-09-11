tool
extends MarginContainer

var file_name = ''

var dialog_block = preload("res://addons/VNScriptEditor/dialogBlock.tscn")
var choice_block = preload("res://addons/VNScriptEditor/choiceBlock.tscn")

onready var organizer = $HBoxContainer/VBoxContainer/notebook/notebookOrganizer

func _ready():
	# notebook organizer
	var d = dialog_block.instance()
	d.set_block_name("starter")
	d.disable_name_edit()
	d.set_content("THIS ADDON IS STILL BUGGY. DO NOT USE.")
	organizer.add_child(d)
	var cond = load("res://addons/VNScriptEditor/conditionBlock.tscn").instance()
	organizer.add_child(cond)

func _on_newDialogButton_pressed():
	var d = dialog_block.instance()
	organizer.add_child(d)

func _on_newChoiceButton_pressed():
	var c = choice_block.instance()
	organizer.add_child(c)


func _on_saveButton_pressed():
	if file_name == '':
		$AcceptDialog.dialog_text = "Please Enter a Timeline Name."
		$AcceptDialog.popup_centered()
	else:
		var file = File.new()
		var error = file.open("res://VNScript/" + file_name + '.txt', File.WRITE)
		if error == OK:
			var all_blocks = organizer.get_children()
			for block in all_blocks:
				var bname = block.get_name()
				var btype = block.get_type()
				print(btype)
				if btype == "DIALOG" or btype == "CHOICE":
					var s = "--%s--%s" % [btype, bname]
					print(s)
					file.store_line(s)
				elif btype == "CONDITIONS":
					var s = "--%s" % [btype]
					file.store_line(s)
					
				var bcontent = block.get_plain_text()
				file.store_line(bcontent)
				file.store_line("--END")
			
			
			$AcceptDialog.dialog_text = "Saved as .txt successfully. You can find " + file_name + ".txt in "+\
			"the VNscript folder."
			$AcceptDialog.popup_centered()
			file.close()
		else:
			push_error('Error when saving: %s' %error)

func _on_loadButton_pressed():
	pass # Replace with function body.

func _on_tlname_text_changed(new_text):
	file_name = new_text
