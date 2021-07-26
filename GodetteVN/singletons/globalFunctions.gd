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

# Working

# Used in rollback
# Classifying events and what types of actions should be followed
# for what kind of events during rollback
# Ignore and auto-rollback one more: chara,
# Playback: speech, 
# Revert to previous:
# Undo: history manipulation, system 

func event_match(ev:Dictionary) -> int:
	var m = 0
	match ev:
		{"condition", "then", "else",..}: m = 0
		{"condition",..}: m = 0
		{"fadein"}: m = 0
		{"fadeout"}: m = 0
		{"screen",..}: m = 0
		{"bg",..}: m = 0
		{"chara",..}: m = 0
		{"weather"}: m = 0
		{"camera", ..}: m = 0
		{"express"}: m = 0
		{"bgm",..}: m = 0
		{'audio',..}: m = 0
		{'dvar'}: m = 0
		{'font', 'path'}: m = 0
		{'sfx',..}: m = 0
		{'then',..}: m = 0
		{'premade'}: m = 0
		{"system"}: m = 0
		{'choice',..}: m = 0
		{'wait'}: m = 0
		{'nvl'}: m = 0
		{'GDscene'}: m = 0
		{'history', ..}: m = 0
		{'float', 'wait',..}: m = 0
		{'center'}: m = 0
		_: m = -1 # This signifies speech event
		
	return m

#----------------------------------------------------------------

func break_line(line:String , s:String):
	# breaks the line according to the letter s
	# For instance, if line = 'x = (a+b)^2', it returns [x, (a+b)^2] 

	if s in line:
		return line.split(s)
	else:
		vn.error("Cannot break {0} by {1}".format({0:line,1:s}))
		

func calculate(what:String):
	# what means what to calculate, should be an algebraic expression
	var calculator = stringCalculator.new()
	var result =  calculator.calculate(what)
	calculator.call_deferred('free')
	return result
	
