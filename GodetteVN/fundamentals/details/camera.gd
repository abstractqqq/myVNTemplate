extends Camera2D

onready var shakeTimer = $Timer

var shake_amount = 200
var rng = RandomNumberGenerator.new()
var type : int
const default_offset = Vector2(0,0)


func _ready():
	set_process(false)
	
func _process(delta):
	var shake_vec = Vector2()
	if type == 0: # regular
		shake_vec = Vector2(rng.randf_range(-shake_amount, shake_amount),\
		rng.randf_range(-shake_amount, shake_amount))
	elif type == 1: #vpunch
		shake_vec = Vector2(0, rng.randf_range(-shake_amount, shake_amount))
	elif type == 2: # hpunch
		shake_vec = Vector2(rng.randf_range(-shake_amount, shake_amount), 0)
	else: # currently, else means nothing
		shake_vec = Vector2(0,0)
	
	self.offset = shake_vec * delta + default_offset
	
	
func shake(amount, time):
	
	shake_amount = amount
	if time < 0.5:
		shakeTimer.wait_time = 0.5
	else:
		shakeTimer.wait_time = time
		 
	type = 0
	set_process(true)
	shakeTimer.start()
	

func vpunch():
	shake_amount = 600
	shakeTimer.wait_time = 0.9
	type = 1
	set_process(true)
	shakeTimer.start()
	
func hpunch():
	shake_amount = 600
	shakeTimer.wait_time = 0.9
	type = 2
	set_process(true)
	shakeTimer.start()
	

func _on_Timer_timeout():
	shake_amount = 200
	type = 0
	set_process(false)
	self.offset = default_offset
	
func camera_spin(sdir:int, deg:float, t:float, mode = "linear"):
	if sdir > 0:
		sdir = 1
	else:
		sdir = -1
	deg = (sdir*deg)
	var m = fun.movement_type(mode)
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "rotation_degrees", self.rotation_degrees, self.rotation_degrees+deg, t,
		m, Tween.EASE_IN_OUT)
	tween.start()
	yield(get_tree().create_timer(t), "timeout")
	tween.queue_free()
		
	
func camera_move(v:Vector2, t:float, mode = 'linear'):
	if t <= 0.05:
		self.offset = v
	else:
		var m = fun.movement_type(mode)
		var tween = Tween.new()
		add_child(tween)
		tween.interpolate_property(self, "offset", self.offset, v, t,
			m, Tween.EASE_IN_OUT)
		tween.start()
		yield(get_tree().create_timer(t), "timeout")
		tween.queue_free()
		
func zoom_timed(zm:Vector2, t:float, mode:String, off = Vector2(1,1)):
	zm = fun.correct_scale(zm)
	var m = fun.movement_type(mode)
	var tween1 = Tween.new()
	var tween2 = Tween.new()
	add_child(tween1)
	add_child(tween2)
	tween1.interpolate_property(self, "offset", self.offset, off, t,
		m, Tween.EASE_IN_OUT)
	tween2.interpolate_property(self, "zoom", self.zoom, zm, t,
		m, Tween.EASE_IN_OUT)
	tween1.start()
	tween2.start()
	yield(get_tree().create_timer(t), "timeout")
	tween1.queue_free()
	tween2.queue_free()

func zoom(zm:Vector2, off = Vector2(1,1)):
	zm = fun.correct_scale(zm)
	# by default, zoom is instant
	self.offset = off
	self.zoom = zm
	
func reset():
	self.offset = self.default_offset
	self.rotation_degrees = 0
	self.zoom = Vector2(1,1)

func get_camera_data() -> Dictionary:
	return {'offset': self.offset, 'zoom': self.zoom, 'deg':self.rotation_degrees}
	
func set_camera(d: Dictionary):
	zoom(d['zoom'], d['offset'])
	if d.has('deg'):
		rotation_degrees = d['deg']
