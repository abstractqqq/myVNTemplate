extends ParallaxBackground

var moon_speed = -15
var uniform_speed = -25
# Everything but moonLayer will have speed -25

# If you want, you can choose a different self-moving speed for all your layers
# in your parallax. Here every layer is moving at the same speed.

func _process(delta)->void:
	for p in get_children():
		if p.name == "moonLayer":
			p.motion_offset.x += moon_speed * delta
		else:
			p.motion_offset.x += uniform_speed * delta
