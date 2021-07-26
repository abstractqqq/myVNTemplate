extends Sprite
class_name character


# Exports
export(String) var display_name = "Character Name"
export(String) var unique_id = "UID"
export(Color) var name_color = null
export(bool) var in_all = true
export(bool) var apply_highlight = true
export(Dictionary) var expression_list = {}
export(Dictionary) var anim_list = {}
export(bool) var fade_on_change = false
export(float, 0.1, 1) var fade_time = 0.5
#

var rng = RandomNumberGenerator.new()
# These variables should not really be here...
var timer = null
var counter = 0
var counter_bound = 0
var shake_amount = 0
var step_size = 0
var dir = null
#
var loc = Vector2()
var in_action = false
const direction = {'up': Vector2.UP, 'down': Vector2.DOWN, 'left': Vector2.LEFT, 'right': Vector2.RIGHT}

var current_expression : String



#-------------------------------------------------------------------------------

func change_expression(e : String) -> bool:
	if e == "": e = 'default'
	
	if expression_list.has(e):
		var prev_exp = current_expression
		self.texture = load(vn.CHARA_DIR + expression_list[e])
		current_expression = e
		if fade_on_change and prev_exp != "":
			var dummy = Sprite.new()
			dummy.name = "_dummy"
			dummy.position = self.position
			dummy.texture = load(vn.CHARA_DIR + expression_list[prev_exp])
			stage.add_child(dummy)
			var tween = Tween.new()
			tween.connect("tween_completed", self, "clear_dummy")
			dummy.add_child(tween)
			var m = self.modulate
			tween.interpolate_property(dummy, "modulate", m, Color(m.r, m.g, m.b, 0), fade_time,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.start()
		
		return true
	else:
		print("Warning: " + e + ' not found for character with uid ' + unique_id)
		print("Nothing is done.")
		return false

# Jump and shake require refactor
func shake(amount: float, time : float):
	if in_action:
		timer.stop()
		timer.queue_free()
		reset()

	in_action = true
	shake_amount = amount
	time = stepify(time,0.1)
	counter_bound = time/0.02
	loc = self.position
	
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.02
	timer.connect('timeout', self, 'on_shake_timer_timeout')
	timer.start()
	
	# Another way to handle to timer is to use yield(,). But I don't
	# want to define too many signals. So it's like this currently.

# Jump and shake require refactor
func on_shake_timer_timeout():
	counter += 1
	if counter >= counter_bound:
		in_action = false
		timer.stop()
		timer.queue_free()
		reset()
	else:
		self.position = loc + 0.02*Vector2(rng.randf_range(-shake_amount, shake_amount),\
		rng.randf_range(-shake_amount, shake_amount))

# Jump and shake require refactor
func jump(direc : String, amount : float, time : float) -> void:
	if in_action:
		timer.stop()
		timer.queue_free()
		reset()
	
	dir = direc.to_lower()
	in_action = true
	time = stepify(time, 0.1)
	counter_bound = time/0.02
	step_size = amount/(counter_bound/2)
	loc = self.position
	
	timer = Timer.new()
	self.add_child(timer)
	timer.wait_time = 0.02
	timer.connect('timeout', self, 'on_jump_timeout')
	timer.start()

# Jump and shake require refactor
func on_jump_timeout():
	counter += 1
	if counter >= counter_bound:
		in_action = false
		timer.stop()
		timer.queue_free()
		reset()
	
	if counter >= counter_bound/2:
		self.position -= step_size * direction[dir]
	else:
		self.position += step_size * direction[dir]

# Reset is done this way because currently shake and jump are
# exclusive to each other
func reset():
	shake_amount = 0
	step_size = 0
	counter = 0
	counter_bound = 0
	self.position = loc

func fadein(time : float):
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "modulate", Color(0.86,0.86,0.86,0), vn.DIM, time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(get_tree().create_timer(time), "timeout")
	tween.queue_free()
	
func fadeout(time : float):
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "modulate", vn.DIM, Color(0.86,0.86,0.86,0), time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(get_tree().create_timer(time), "timeout")
	tween.queue_free()
	self.queue_free()
	
	
func change_pos_2(loca:Vector2, time:float, mode = "linear"):
	self.loc = loca
	var m = fun.movement_type(mode)
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "position", self.position, loca, time,
		m, Tween.EASE_IN_OUT)
	tween.start()
	yield(get_tree().create_timer(time), "timeout")
	tween.queue_free()

func clear_dummy(ob:Object, _k: NodePath):
	ob.call_deferred('free')

