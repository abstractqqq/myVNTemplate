tool
extends MarginContainer

var fname = ""
onready var edit = $HBoxContainer/HSplitContainer/VBoxContainer/TextEdit

func _input(_event):
	if Input.is_key_pressed(KEY_F9):
		save_as_txt(true)

func script_to_json():
	var success = save_as_txt()
	if success:
		var timeline = edit.get_timeline()
		var file = File.new()
	
		var error = file.open("res://VNScript/" + fname + '.json', File.WRITE)
		if error == OK:
			print("TO JSON SUCCESS.")
			file.store_line(JSON.print(timeline,'\t'))
			$AcceptDialog.dialog_text = "To Json success! You can find " + fname + ".json in the VNScript folder."
			$AcceptDialog.popup_centered()
			file.close()
		else:
			push_error('Error when loading: %s' %error)
	else:
		push_error('Error when saving. Maybe there is no name for this timeline.')

func save_as_txt(shortCut=false):
	var file = File.new()
	if fname == "":
		$AcceptDialog.dialog_text = "Please Enter a Timeline Name."
		$AcceptDialog.popup_centered()
		return false
	else:
		var error = file.open("res://VNScript/" + fname + '.txt', File.WRITE)
		if error == OK:
			var new_text = edit.text
			file.store_line(new_text)
			# If short cut is used... F9 to save
			$AcceptDialog.dialog_text = "Saved as .txt successfully. You can find " + fname + ".txt in "+\
			"the VNscript folder."
			$AcceptDialog.popup_centered()
			file.close()
			return true
		else:
			push_error('Error when saving: %s' %error)
			return false


func _on_loadButton_pressed():
	$FileDialog.popup_centered()
	$FileDialog.deselect_items()


func _on_jsonButton_pressed():
	script_to_json()


func _on_FileDialog_file_selected(path):
	var f = File.new()
	var error = f.open(path, File.READ)
	if error == OK:
		edit.text = f.get_as_text()
		path = path.split('/')
		var fname2 = path[path.size()-1]
		fname = fname2.split(".")[0]
		$HBoxContainer/HSplitContainer/VBoxContainer/head/tlname.text = fname
		f.close()
	else:
		vn.error('Error when opening: %s' % error)

func _on_tlname_text_changed(new_text):
	fname = new_text

func _on_saveButton_pressed():
	save_as_txt()

func _on_newButton_pressed():
	edit.text = "-DIALOG-starter\n\n\n-END\n\n\n-CHOICE-\n\n\n-END\n\n\n-CONDITIONS-\n\n\n-END"
