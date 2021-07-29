extends ScrollContainer

var slot = preload("res://GodetteVN/fundamentals/details/saveSlot.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	var saves = fileRelated.get_save_files()
	for i in range(saves.size()):
		var saveSlot = slot.instance()
		var file = File.new()
		var error = file.open_encrypted_with_pass(vn.SAVE_DIR + saves[i], File.READ, "nanithefuck")
		if error == OK:
			var data = file.get_var()
			saveSlot.set_description(data['currentSaveDesc'])
			saveSlot.set_datetime(data['datetime'])
			saveSlot.path = vn.SAVE_DIR + saves[i]
			# thumbnail
			var thumbnail = saveSlot.get_node("Button/HBoxContainer/saveThumbnail")
			thumbnail.texture = fileRelated.data2Thumbnail(data['thumbnail'], data['format'])
			$allSaves.add_child(saveSlot)
			file.close()
	

	for i in 3: # always provide some empty slots
		make_empty_save()


func make_empty_save():
	var newSlot = slot.instance()
	newSlot.connect("save_made", self, "make_empty_save")
	$allSaves.add_child(newSlot)
