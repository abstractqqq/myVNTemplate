extends Button
class_name VNTextButton

func _ready():
	self.connect("mouse_entered", self, "_mouse_entered")
	self.connect("mouse_exited", self, "_mouse_exited")

func _mouse_entered():
	vn.noMouse = true

func _mouse_exited():
	vn.noMouse = false
