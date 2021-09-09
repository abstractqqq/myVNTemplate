tool
extends Panel

func _on_delete_pressed():
	self.queue_free()


func _on_up_pressed():
	print("Up")
	var organizer = get_parent()
	var idx = get_index()
	if idx > 0:
		var siblings = organizer.get_children()
		var prev = idx - 1
		organizer.move_child(self,prev)
		
		
func _on_down_pressed():
	print("down")
	var organizer = get_parent()
	var idx = get_index()
	var siblings = organizer.get_children()
	if idx < siblings.size() - 1:
		var next = idx + 1
		organizer.move_child(self,next)
