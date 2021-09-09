tool
extends MarginContainer


func _ready():
	# notebook organizer
	var nbo = get_node("HBoxContainer/HSplitContainer/VBoxContainer/notebook/notebookOrganizer")
	var d = load("res://addons/VNScriptEditor/dialogBlock.tscn").instance()
	nbo.add_child(d)
	
	var c = load("res://addons/VNScriptEditor/choiceBlock.tscn").instance()
	nbo.add_child(c)

