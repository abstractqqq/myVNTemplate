extends AnimatedSprite
class_name character


# Exports
# Character metadata
export(String) var display_name = "Character Name"
export(String) var unique_id = "UID"
export(Color) var name_color = null
export(bool) var in_all = true
export(bool) var apply_highlight = true
export(bool) var fade_on_change = false
export(float, 0.1, 1) var fade_time = 0.5
export(bool) var use_character_font = false
export(String, FILE, '*.tres') var normal_font = ''
export(String, FILE, '*.tres') var bold_font = ''
export(String, FILE, '*.tres') var italics_font = ''
export(String, FILE, '*.tres') var bold_italics_font = ''
#

var rng = RandomNumberGenerator.new()

#-----------------------------------------------------
# Character attributes
var loc = Vector2()
var current_expression : String

#-------------------------------------------------------------------------------

func change_expression(e : String) -> bool:
	if e == "": e = 'default'
	var expFrames = self.get_sprite_frames()
	if expFrames.has_animation(e):
		var prev_exp = current_expression
		play(e)
		current_expression = e
		if fade_on_change and prev_exp != "":
			var dummy = Sprite.new()
			dummy.name = "_dummy"
			dummy.position = self.position
			dummy.texture = expFrames.get_frame(prev_exp,0)
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

func shake(amount: float, time : float, mode = 0):
	# 0 : regular shake
	# 1 : vpunch
	# 2 : hpunch
	var _objTimer = objectTimer.new(self,time,0.02,"_shake_action", [mode,amount])
	add_child(_objTimer)
	
func _shake_action(params):
	rng.randomize()
	# params[0] = mode, params[1] = amount
	match params[0]:
		0:self.position = loc + 0.02*Vector2(rng.randf_range(-params[1], params[1]), rng.randf_range(-params[1], params[1]))
		1:self.position = loc + 0.02*Vector2(loc.x, rng.randf_range(-params[1], params[1]))
		2:self.position = loc + 0.02*Vector2(rng.randf_range(-params[1], params[1]), loc.y)
		
func jump(direc:Vector2, amount:float, time:float):
	var step : float = amount/(time/0.04)
	var _objTimer = objectTimer.new(self,time,0.02,"_jump_action", [direc,step], true)
	add_child(_objTimer)

func _jump_action(params):
	# params[0] = jump_dir, params[1] = step_size, params[-1] = total_counts, params[-2] = counter
	var size = params.size()
	if params[size-2] >= params[size-1]/2:
		self.position -= params[1] * params[0]
	else:
		self.position += params[1] * params[0]


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
	
func spin(sdir:int,degrees:float,time:float,type:String="linear"):
	if sdir > 0:
		sdir = 1
	else:
		sdir = -1
	var m = fun.movement_type(type)
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self,'rotation_degrees',0,sdir*degrees,time,m,Tween.EASE_IN_OUT)
	tween.start()
	yield(get_tree().create_timer(time), "timeout")
	tween.queue_free()
	rotation_degrees = 0

#----------------------------------------------------------------------------
# Explanation on this somewhat awkward character movement code
#
# Q: Why are you using a dummy? You can directly use a tween to change your position.
# A: Of course, that is a solution. However, that's imperfect for the following reason:
# Suppose you want to jump your character and move along x-axis at the same time,
# then if you do move first, then jump, then jump will not happen. Why?
# tween.interpolate_property(self,"position",position,loca,time,m,Tween.EASE_IN_OUT)
# Will move the character from position to loca, but what happens if during the tween,
# the character's position get changed by another method? 
# You should test it out. The answer is one of the method will be nullified somehow.
# So to make jump and move compatible, I cannot use just a tween here.
#
# Q: Well, you can use your objectTimer to move the character, and update displacement
# when timer times out. That's easy, right?
# A: But then how are you going to implement a movement type? Movement is used so commonly
# that we should expect the user to be creative and use different movement types than
# linear. By following this fakeWalker, we can create a fake quadratic movement type
# if type = quad. 
#
# Extra comment: jump, on the other hand, is not often used, and when used, often
# involves a small amount of jump, like being shocked. So I think it's ok to not
# implement a movement type for jump.

func change_pos_2(loca:Vector2, time:float, type = "linear"):
	self.loc = loca
	var m = fun.movement_type(type)
	var fake = fakeWalker.new()
	fake.name = "_dummy"
	fake.position = position
	stage.add_child(fake)
	var fake_tween = Tween.new()
	fake.add_child(fake_tween)
	fake_tween.interpolate_property(fake,"position",position,loca,time,m,Tween.EASE_IN_OUT)
	var _objTimer = objectTimer.new(self,time,0.01,"_follow_fake",[fake])
	add_child(_objTimer)
	fake_tween.start()
	fake_tween.connect("tween_completed", self, "clear_dummy")

func _follow_fake(params):
	var fake = params[0]
	if is_instance_valid(fake):
		position += fake.get_disp()
#----------------------------------------------------------------------------

func clear_dummy(ob:Object, _k: NodePath):
	# This ob will be the dummy created by some method above
	ob.call_deferred('free')

