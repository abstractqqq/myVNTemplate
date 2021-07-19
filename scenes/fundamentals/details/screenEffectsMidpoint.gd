extends Node2D

# This simply serves as a midpoint between calls
# Simple functions will be written here,
# Longer ones will be in the script in the subnodes

func helloWorld():
	print("Hello World")

func pixel_in(time):
	get_node("aboveScreen").pixelate_in(time)

func pixel_out(time):
	get_node("aboveScreen").pixelate_out(time)

func fadein(time):
	get_node("aboveScreen").fadein(time)
	
func fadeout(time):
	get_node("aboveScreen").fadeout(time)
	
func tint(c: Color,time : float):
	get_node("aboveScreen").tint(c,time)
	
func removeLasting():
	get_node("aboveScreen").removeLasting()
	
func tintWave(c: Color, time : float):
	get_node("aboveScreen").tintWave(c,time)
	
func shake(shake_amount, shake_timer):
	get_node("camera").shake(shake_amount,shake_timer)
	
func vpunch():
	get_node("camera").vpunch()
	
func hpunch():
	get_node("camera").hpunch()

# --------------Could have moved all these methods into camera's script
# But I am being lazy... 
func correct_zm(v:Vector2) -> Vector2:
	return Vector2(min(1,abs(v.x)), min(1,abs(v.y)))

func camera_move(v:Vector2, t:float, mode = 'linear'):
	var camera = get_node('camera')
	if t <= 0.05:
		camera.offset = v
	else:
		var m = fun.movement_type(mode)
		var tween = Tween.new()
		add_child(tween)
		tween.interpolate_property(camera, "offset", camera.offset, v, t,
			m, Tween.EASE_IN_OUT)
		tween.start()
		yield(get_tree().create_timer(t), "timeout")
		tween.queue_free()

func zoom_timed(zm:Vector2, t:float, mode:String, off = Vector2(1,1)):
	zm = correct_zm(zm)
	var camera = get_node('camera')
	var m = fun.movement_type(mode)
	var tween1 = Tween.new()
	var tween2 = Tween.new()
	add_child(tween1)
	add_child(tween2)
	tween1.interpolate_property(camera, "offset", camera.offset, off, t,
		m, Tween.EASE_IN_OUT)
	tween2.interpolate_property(camera, "zoom", camera.zoom, zm, t,
		m, Tween.EASE_IN_OUT)
	tween1.start()
	tween2.start()
	yield(get_tree().create_timer(t), "timeout")
	tween1.queue_free()
	tween2.queue_free()

func zoom(zm:Vector2, off = Vector2(1,1)):
	zm = correct_zm(zm)
	# by default, zoom is instant
	var camera = get_node('camera')
	camera.offset = off
	camera.zoom = zm
	
func reset_zoom():
	var camera = get_node('camera')
	camera.offset = camera.default_offset
	camera.zoom = Vector2(1,1)

func get_camera_data() -> Dictionary:
	var camera = get_node('camera')
	return {'offset': camera.offset, 'zoom': camera.zoom}
	
func set_camera(d: Dictionary):
	zoom(d['zoom'], d['offset'])

# -----------------------------------------------------------------

func _ready(): # turn off all weather on ready
	var w = get_node("aboveScreen").get_node("weather")
	for n in w.get_children():
		n.visible = false

func weather_off():
	var w = get_node("aboveScreen").get_node("weather")
	for n in w.get_children():
		n.visible = false
	
func show_weather(w_name:String):
	var w = get_node("aboveScreen").get_node("weather")
	for n in w.get_children():
		if n.name == w_name:
			n.visible = true
		else:
			n.visible = false
