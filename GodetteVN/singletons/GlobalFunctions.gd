extends Node

# A collection of functions that are used globally as convenient methods.



#-------------------------------------------------------------------------
# Premade event sections:
# What are premade events? If you have an event like
# {chara : j fadein, loc : '1600 900', time : 1}
# which you know you will be using many times, then you can make it 
# into an premade event putting it here with a unique key so that you
# can retrieve it anytime without typing all the commands. All you need 
# to type is that {premade: your_name_for_the_event }
var premade_events = {
	"EXAMPLE" : {"" : "Hello World!"},
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
func random_vec(x:Vector2, y:Vector2):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var rndv = Vector2(rng.randf_range(x.x, x.y),rng.randf_range(y.x, y.y))
	rng.call_deferred('free')
	return rndv
	
func calculate(what:String):
	# what means what to calculate, should be an algebraic expression
	# only dvars are allowed
	var calculator = StringCalculator.new()
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
		
	dir.call_deferred('free')
		
	var file = File.new()
	var save_path = vn.THUMBNAIL_DIR + 'thumbnail.dat'
	var error = file.open(save_path, File.WRITE)
	if error == OK:
		# store raw image data
		file.store_var(thumbnail.get_data())
		file.close()
		

# sl.make_save only works for standard VN saves. That means if you're 
# adding extra info, you will have to modify sl.make_save first.
func make_a_save(msg = "[Quick Save] " , delay:float = 0.0, offset_by:int = 0):
	delay = abs(delay)
	if delay > 0:
		yield(get_tree().create_timer(delay), 'timeout')
		
	create_thumbnail() # delay is mostly used to control the timing of the thumbnail
	var slot = load(vn.SAVESLOT)
	var sl = slot.instance() # bad. See below
	var temp = game.currentSaveDesc
	var curId = game.currentIndex
	game.currentIndex = game.currentIndex - offset_by
	game.currentSaveDesc = msg + temp
	sl.make_save(sl.path)# Because in reality we do not need to instance a save slot object. Only the data
	sl.queue_free()
	game.currentSaveDesc = temp
	game.currentIndex = curId


#------------------------------------------------------------------------
# Given any sentence with a [dvar] in it, 
# This will prase any dvar into their values and insert back
# to the sentence. Same with special tokens. It doesn't handle nw, and so is different
# from that in GeneralDialog.
func MarkUp(words:String):
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
				match inner:
					"sm": output += ";"
					"dc": output += "::"
					"nl": output += "\n"
					"lb": output += "["
					"rb": output += "]"
					_: output += '[' + inner + ']'
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
