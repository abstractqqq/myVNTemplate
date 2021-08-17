extends clickableObject



func _on_object2_mouse_entered():
	vn.noMouse = true # This is unnecessary if you use GDscene:idle to pause the 
	# game.
	self.material = load("res://GodetteVN/shaders/sprite_outline.tres")

func _on_object2_mouse_exited():
	vn.noMouse = false
	self.material = null
