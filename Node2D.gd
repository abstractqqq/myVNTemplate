extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var a = [1, 0]
	var b = [1, 0]
	print("a == b  %s" % (a == b))
	var c = {}
	c[a] = 0
	print("c   %s" % [c])
	c[b] = 1
	print("c   %s" % [c])
	b.push_front(null)
	c[b] = 2
	print("c   %s" % [c])
	b.pop_front()
	print("c   %s" % [c])
	c[b] = 3
	print("c   %s" % [c])
	var d = c.duplicate()
	print("d   %s" % [d])
