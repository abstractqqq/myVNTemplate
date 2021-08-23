extends Node

# A collection of functions that are used globally as convenient methods.



#-------------------------------------------------------------------------
# Premade event sections:
# What are premade events? If you have an event like
# {chara : j fadein, loc : 1600 900, time : 3}
# which you know you will be using many times, then you can make it 
# into an premade event putting it here with a unique key so that you
# can retrieve it anytime without typing all the commands. All you need 
# to type is that {premade: your_key_name_for_the_event }
var premade_events = {
	"EXAMPLE" : {"" : "Hello World!"},
	"EXPRCHG" : {"express": "female surprised"}
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



#----------------------------------------------------------------

func break_line(line:String , s:String):
	# breaks the line according to the letter s
	# For instance, if line = 'x = (a+b)^2', s = '=', it returns [x, (a+b)^2] 
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
	
#----------------------------------------------------------------------
# Make a save.

func create_thumbnail(width = vn.THUMBNAIL_WIDTH, height = vn.THUMBNAIL_HEIGHT):
	var thumbnail = get_viewport().get_texture().get_data()
	thumbnail.flip_y()
	thumbnail.resize(width, height, Image.INTERPOLATE_LANCZOS)
	game.currentFormat = thumbnail.get_format()
	
	var dir = Directory.new()
	if !dir.dir_exists(vn.THUMBNAIL_DIR):
		dir.make_dir_recursive(vn.THUMBNAIL_DIR)
		
	var file = File.new()
	var save_path = vn.THUMBNAIL_DIR + 'thumbnail.dat'
	var error = file.open(save_path, File.WRITE)
	if error == OK:
		# store raw image data
		file.store_var(thumbnail.get_data())
		file.close()

func make_a_save(msg = "[Quick Save] " , delay:float = 0.0, offset_by:int = 0):
	if delay > 0:
		yield(get_tree().create_timer(delay), 'timeout')
		
	create_thumbnail()
	var slot = load(vn.SAVESLOT)
	var sl = slot.instance()
	var temp = game.currentSaveDesc
	var curId = game.currentIndex
	game.currentIndex = game.currentIndex - offset_by
	game.currentSaveDesc = msg + temp
	sl.make_save(sl.path)
	sl.queue_free()
	game.currentSaveDesc = temp
	game.currentIndex = curId


#------------------------------------------------------------------------
# Given any sentence with a [dvar] in it, 
# This will prase any dvar into their values and insert back
# to the sentence. But it doesn't process things like [nw]. Only dvar.
func dvarMarkup(words:String):
	var leng = words.length()
	var output = ''
	var i = 0
	while i < leng:
		var c = words[i]
		var inner = ""
		if c == '[':
			i += 1
			while words[i] != ']':
				inner += words[i]
				i += 1
				if i >= leng:
					vn.error("Please do not use square brackets " +\
					"unless for bbcode or display dvar purposes.")
					
			if vn.dvar.has(inner):
				output += str(vn.dvar[inner])
			else:
				output += '[' + inner + ']'
						
		else:
			output += c
			
		i += 1
	
	return output

#---------------------------------------------------------------------
# Used if you only want your scale/zoom parameters to be between 0 and 1.
# Notice sometimes for scale, you want to allow bigger scale. (This is not
# recommended however, because this might destroy the image)
func correct_scale(v:Vector2) -> Vector2:
	return Vector2(min(1,abs(v.x)), min(1,abs(v.y)))

#---------------------------------------------------------------------
# String parsing functions
