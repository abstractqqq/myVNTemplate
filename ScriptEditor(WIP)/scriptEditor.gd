extends ColorRect


var fname = ""

func _ready():
	OS.set_window_title("Script Editor")
	OS.set_window_size(Vector2(1920,1080))


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
		vn.error('Error when saving script files. (Unknown reason.)')

func save_as_txt():
	var file = File.new()
	if fname == "":
		$AcceptDialog.dialog_text = "Please Enter a Timeline Name."
		$AcceptDialog.popup_centered()
	else:
		var error = file.open(vn.SCRIPT_DIR + fname + '.txt', File.WRITE)
		if error == OK:
			file.store_line($TextEdit.text)
			$AcceptDialog.dialog_text = "Saved as .txt successfully. You can find the text in "+\
			"the VNscript folder."
			$AcceptDialog.popup_centered()
			file.close()
		else:
			vn.error('Error when saving script files. (Unknown reason.)')


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
		vn.error('Unknown error when opening script.')

func _on_tlname_text_changed(new_text):
	fname = new_text

func _on_saveButton_pressed():
	save_as_txt()
