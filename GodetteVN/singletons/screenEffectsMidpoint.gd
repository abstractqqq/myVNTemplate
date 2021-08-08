extends Node

const all_weathers = {
	'rain': "res://GodetteVN/fundamentals/details/weather/rain.tscn",
	'snow': "res://GodetteVN/fundamentals/details/weather/snow.tscn",
	'light': "res://GodetteVN/fundamentals/details/weather/light.tscn",
	'dust': "res://GodetteVN/fundamentals/details/weather/dust.tscn"
}

# This simply serves as a midpoint between calls
# Simple functions will be written here,
# Longer ones will be in the script in the subnodes

# Before calling a lasting screen effect, first do removeLasting()
# Because by default lasting screen effect should be exclusive.

# In case in the future there might be more nodes here, I will
# leave the structure like this for now.

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
	removeLasting()
	get_node("aboveScreen").tint(c,time)
	
func removeLasting():
	get_node("aboveScreen").removeLasting()
	
func tintWave(c: Color, time : float):
	removeLasting()
	get_node("aboveScreen").tintWave(c,time)
	

# -----------------------------------------------------------------

func _ready(): # turn off everything on ready
	removeLasting()
	weather_off()

func weather_off():
	var w = get_node("aboveScreen").get_node("weather")
	for n in w.get_children():
		n.call_deferred('free')
	
func show_weather(w_name:String):
	weather_off() # Weather is exclusive
	var w = get_node("aboveScreen").get_node("weather")
	if all_weathers.has(w_name):
		var weather = load(all_weathers[w_name])
		w.add_child(weather.instance())
	else:
		print('Weather not found. Nothing is done.')
	
# ---------------------------Flashlight-----------------------------

func flashlight(scale : Vector2):
	removeLasting()
	var lasting = get_node("aboveScreen/lasting")
	var fl_scene = (load("res://GodetteVN/sfxScenes/flashLightScreen.tscn")).instance()
	lasting.add_child(fl_scene)
	fl_scene.scale = scale
