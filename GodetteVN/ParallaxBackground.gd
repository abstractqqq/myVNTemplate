extends ParallaxBackground

var moon_speed = -15
var uniform_speed = -25
# Everything but moonLayer will have speed -25

# If you want, you can choose a different self-moving speed for all your layers
# in your parallax. Here every layer is moving at the same speed except moon.

# If you want to use signals
# 1. You need to create a subnode called signals.
# 2. Make your signal there.
# 3. Write your own code for signal connection, and effects.
# 4. Think about whether or not the consequence of the signal should be saved.
# 5. There is no formula for this, you do need to be very careful in general.

func _ready():
	var communicator = null
	for n in get_parent().get_children():
		if n.name == "signals":
			communicator = n
			break
			
	var _error = communicator.connect('speed_change', self, "receive_signal")


func _process(delta)->void:
	for p in get_children():
		if p.name == "moonLayer":
			p.motion_offset.x += moon_speed * delta
		else:
			p.motion_offset.x += uniform_speed * delta


func receive_signal(params):
	# In this case I know that params is going to be a size 2 array
	uniform_speed = params[0]
	moon_speed = params[1]
