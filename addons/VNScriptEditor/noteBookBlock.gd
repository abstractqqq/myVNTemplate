tool
extends Panel

var last_y_size = self.rect_size.y
var text_visible = true

func _on_delete_pressed():
	self.queue_free()

func _on_up_pressed():
	var organizer = get_parent()
	var idx = get_index()
	if idx > 0:
		var siblings = organizer.get_children()
		var prev = idx - 1
		organizer.move_child(self,prev)
		
		
func _on_down_pressed():
	var organizer = get_parent()
	var idx = get_index()
	var siblings = organizer.get_children()
	if idx < siblings.size() - 1:
		var next = idx + 1
		organizer.move_child(self,next)

func get_name()->String:
	return get_node("HBoxContainer/header/blockName").text.replace(" ", "_")

func set_content(t:String):
	get_node("HBoxContainer/MarginContainer/TextEdit").text = t

func get_type()->String:
	var temp = get_node("HBoxContainer/header/whatBlock").text.replace(":",'')
	return temp.to_upper()
	
func get_plain_text()->String:
	return get_node("HBoxContainer/MarginContainer/TextEdit").text

func set_block_name(n:String):
	get_node("HBoxContainer/header/blockName").text = n
	
func disable_name_edit():
	get_node("HBoxContainer/header/blockName").editable = false

func _on_visible_pressed():
	text_visible = !text_visible
	get_node("HBoxContainer/MarginContainer/TextEdit").visible = text_visible
	if text_visible:
		get_node("HBoxContainer/header/list/visible").texture_normal = load("res://addons/EditorGUI/GuiVisibilityVisible.png")
		self.rect_min_size.y = self.last_y_size
		self.rect_size.y = self.last_y_size
	else:
		get_node("HBoxContainer/header/list/visible").texture_normal = load("res://addons/EditorGUI/GuiVisibilityHidden.png")
		self.rect_min_size.y = self.rect_min_size.y
		self.rect_size.y = self.rect_min_size.y
	
