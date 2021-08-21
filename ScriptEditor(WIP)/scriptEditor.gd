extends ColorRect

var floatText = preload("res://GodetteVN/fundamentals/details/floatText.tscn")
var fname = ""

func _ready():
	OS.set_window_title("Script Editor")
	OS.set_window_size(Vector2(1600,900))

func _input(event):
	if event.is_action_pressed("script_save"):
		save_as_txt(true)

func script_to_json():
	var timeline = $TextEdit.get_timeline()
	var file = File.new()
	
	var error = file.open(vn.SCRIPT_DIR + fname + '.json', File.WRITE)
	if error == OK:
		print("TO JSON SUCCESS.")
		file.store_line(JSON.print(timeline,'\t'))
		$AcceptDialog.dialog_text = "To Json success! You can find it in the VNScript folder."
		$AcceptDialog.popup_centered()
		file.close()
	else:
		vn.error('Error when loading: %s' %error)

func save_as_txt(ctrlS=false):
	var file = File.new()
	if fname == "":
		$AcceptDialog.dialog_text = "Please Enter a Timeline Name."
		$AcceptDialog.popup_centered()
	else:
		var error = file.open(vn.SCRIPT_DIR + fname + '.txt', File.WRITE)
		if error == OK:
			file.store_line($TextEdit.text)
			if ctrlS:
				var ft = floatText.instance()
				ft.display("[color=#ff0000]Saved[/color].", 1,1,Vector2(1000,200))
				add_child(ft)
			else:
				$AcceptDialog.dialog_text = "Saved as .txt successfully. You can find the text in "+\
				"the VNscript folder."
				$AcceptDialog.popup_centered()
			file.close()
		else:
			vn.error('Error when saving: %s' %error)


func _on_loadButton_pressed():
	$FileDialog.popup_centered()
	$FileDialog.deselect_items()


func _on_jsonButton_pressed():
	script_to_json()


func _on_FileDialog_file_selected(path):
	var f = File.new()
	var error = f.open(path, File.READ)
	if error == OK:
		$TextEdit.text = f.get_as_text()
		path = path.split('/')
		var fname2 = path[path.size()-1]
		fname = fname2.split(".")[0]
		$tlname.text = fname
		f.close()
	else:
		vn.error('Error when opening: %s' % error)

func _on_tlname_text_changed(new_text):
	fname = new_text

func _on_saveButton_pressed():
	save_as_txt()

func _on_dvarButton_pressed():
	var keys = vn.dvar.keys()
	var output = "Currently defined dvars are: \n"
	for k in keys:
		output += "Dvar: [color=#000000]%s[/color] --- Initial Value: %s \n" % [k, vn.dvar[k]]
	
	output += "\n[color=#787878]If you define a dvar later, you may restart the editor to see it.[/color]"
	$helperPopup/richText.bbcode_text = output
	$helperPopup.popup_centered()
	
