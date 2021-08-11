extends Node2D
class_name fakeWalker


var pos : Vector2

func _ready():
	pos = position

func get_disp()->Vector2:
	var diff : Vector2 = position - pos
	pos = position
	return diff
