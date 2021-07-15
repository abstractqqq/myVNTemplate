extends Node

# A collection of functions that are used globally as convenient methods.

# Declare other variables here, if you have any

#-------------------------------------------------------------------------
# Premade event sections:
# What are premade events? If you have an event like
# {chara : j fadein, loc : 1600 900, time : 3}
# which you know you will be using many times, then you can make it 
# into an premade event putting it here with a unique key so that you
# can retrieve it anytime without typing all the commands. All you need 
# to type is that {premade: your_key_name_for_the_event }
var premade_events = {
	"EXAMPLE" : {"" : "Hello World!"}
}



func call_premade_events(key:String) -> Dictionary:
	if premade_events.has(key):
		return premade_events[key]
	else:
		vn.error("Premade event cannot be found. Check spelling.")
		return {}

# End of premade events section
#-------------------------------------------------------------------------
# Other functions that might be used globally

func movement_type(type:String)-> int:
	var m = 0
	match type:
		"linear": m = 0
		"sine": m = 1
		"quint": m = 2
		"quart": m = 3
		"quad": m = 4
		"expo": m = 5
		"elastic": m = 6
		"cubic": m = 7
		"circ": m = 8
		"bounce": m = 9
		"back" : m = 10
		_: m = 0
		
	return m
