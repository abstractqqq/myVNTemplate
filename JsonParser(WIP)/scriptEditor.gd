extends ColorRect
onready var t = $TextEdit
onready var na = $dialogName

func _ready():
	OS.set_window_title("Script Editor")
	OS.set_window_size(Vector2(1280,720))


func script_to_json():
	var all_events = t.get_events()
	var file = File.new()
	if na.text == "":
		vn.error('Please enter a dialog name.')
	else:
		var error = file.open(vn.SCRIPT_DIR + na.text + '.json', File.WRITE)
		if error == OK:
			print("TO JSON SUCCESS.")
			file.store_line(JSON.print(all_events, '\t'))
			$AcceptDialog.popup_centered()
			file.close()
		else:
			vn.error('Error when saving script files. (Unknown reason.)')

func to_txt():
	var file = File.new()
	if na.text == "":
		# should give user a warning instead of assigning a random name
		# but this is ok for test purpose
		na.text = "temp"
	
	var error = file.open(vn.SCRIPT_DIR + na.text + '.txt', File.WRITE)
	if error == OK:
		file.store_line(t.text)
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
		t.text = f.get_as_text()
		path = path.split('/')
		var fname = path[path.size()-1]
		na.text = fname.split('.')[0]
		f.close()
	else:
		vn.error('Unknown error when opening script.')


