tool
extends MarginContainer

var file_name = ''

var dialog_block = preload("res://addons/VNScriptEditor/dialogBlock.tscn")
var choice_block = preload("res://addons/VNScriptEditor/choiceBlock.tscn")
var comment_block = preload("res://addons/VNScriptEditor/commentBlock.tscn")
var condition_block = preload("res://addons/VNScriptEditor/conditionBlock.tscn")

onready var organizer = $HBoxContainer/VBoxContainer/notebook/notebookOrganizer

func _ready():
	# notebook organizer
	_new_notebook()
	
func _new_notebook():
	_clear()
	_new_dialog_block("starter", "THIS ADDON IS STILL BUGGY. DO NOT USE.")
	_new_condition_block()
	
func _new_condition_block(content:String = ""):
	var cond = condition_block.instance()
	organizer.add_child(cond)
	cond.set_content(content)
	cond.disable_delete_button()

func _on_newDialogButton_pressed():
	var d = dialog_block.instance()
	organizer.add_child(d)
	return d
	
func _new_dialog_block(dname:String, content:String):
	var d = _on_newDialogButton_pressed()
	d.set_block_name(dname)
	d.set_content(content)
	if dname == "starter":
		d.disable_name_edit()
		d.disable_delete_button()

func _on_newChoiceButton_pressed():
	var c = choice_block.instance()
	organizer.add_child(c)
	return c
	
func _new_choice_block(cname:String, content:String):
	var c = _on_newChoiceButton_pressed()
	c.set_block_name(cname)
	c.set_content(content)

func _fname_standardize(t:String)->String:
	t = t.replace('.', '_')
	t = t.replace(' ', '_')
	return t

func _on_saveButton_pressed():
	file_name = $HBoxContainer/VBoxContainer/headLayers/head/tlname.text
	file_name = _fname_standardize(file_name)
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
				bname = bname.strip_edges()
				if bname == "": bname = "???"
				var btype = block.get_type()
				# print(btype)
				if btype == "DIALOG" or btype == "CHOICE":
					var s = "$--%s--%s" % [btype, bname]
					file.store_line(s)
				elif btype == "CONDITIONS":
					var s = "$--%s" % [btype]
					file.store_line(s)
				elif btype == "COMMENTS":
					var s = "$--COMMENT"
					file.store_line(s)
					
				var bcontent = block.get_plain_text()
				file.store_line(bcontent)
				file.store_line("$--END")
			
			
			$AcceptDialog.dialog_text = "Saved as .txt successfully. You can find " + file_name + ".txt in "+\
			"the VNscript folder."
			$AcceptDialog.popup_centered()
			file.close()
		else:
			push_error('Error when saving: %s' %error)

func _on_loadButton_pressed():
	$FileDialog.popup_centered()

func _on_tlname_text_changed(new_text):
	file_name = new_text

func _on_newNBButton_pressed():
	# ask to save before creating new
	_new_notebook()

func _on_newCommentButton_pressed():
	var d = comment_block.instance()
	organizer.add_child(d)
	return d
	
func _new_comment_block(content:String):
	var d = _on_newCommentButton_pressed()
	d.set_content(content)
	
func _clear():
	for c in organizer.get_children():
		c.queue_free()
	
func _load_new_text(path):
	var has_starter = false
	var has_cond = false
	var textFile = File.new()
	var err = textFile.open(path, File.READ)
	if err == OK:
		var blocks = textFile.get_as_text().split("$--END")
		for content in blocks:
			if content == "": continue
			var temp = content.split("\n", true, 2)
			var t = temp[0].strip_edges()
			if "$--DIALOG" in temp[0]:
				var dname = t.split("--")[2]
				if dname == "starter":
					has_starter = true
				_new_dialog_block(dname, temp[1].strip_edges())
			
			elif "$--COMMENT" in t:
				_new_comment_block(temp[1].strip_edges())
			elif "$--CONDITIONS" in t:
				has_cond = true
				_new_condition_block(temp[1].strip_edges())
			elif "$--CHOICE" in t:
				var cname = t.split("--")[2]
				_new_choice_block(cname, temp[1].strip_edges())
				
		if has_starter == false:
			_new_dialog_block("starter", "")
		if has_cond == false:
			_new_condition_block()
			
		print("Finished Loading.")
	else:
		push_error("Failed to load text file.")

func _on_FileDialog_file_selected(path):
	var temp = path.split('/')
	var fname = temp[temp.size()-1].split('.')[0]
	$HBoxContainer/VBoxContainer/headLayers/head/tlname.text = fname
	file_name = fname
	_clear()
	_load_new_text(path)
