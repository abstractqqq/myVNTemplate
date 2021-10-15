tool
extends TextEdit

export(Color) var label_color = Color(0.492188, 0.196501, 0.286593)
export(Color) var field_val_color = Color(0, 0.574219, 0.426178)
export(Color) var line_comment_color = Color(0.445313, 0.445313, 0.445313)


var lineNum : int
#----------------------------------------------------------
# private variables
var _parse_mode = 0
# 0:detecting labels like -DIALOG
# 1:parsing line to event in a conversation
# 2:parsing line to choice
# 3:parsing line to condition
var _dialog_blocks = {}
var _d_name = ""
var _choice_blocks = {}
var _ch_name = ""
var _cond_blocks = {}

# related to parsing
var _has_error = false
var _one_condition_block = false

# related to editing
var _cur_line = ''
var _pause = false

#----------------------------------------------------------

func _ready():
	add_color_region("#", '', line_comment_color, true)
	add_color_region("::", ";", field_val_color)
	add_color_region("-DIALOG-", "", label_color, true)
	add_color_region("-CONDITIONS-", "", label_color, true)
	add_color_region("-CHOICE-", "", label_color, true)
	add_color_region("-END", "", label_color, true)
	# self.text = "-DIALOG-starter\n\n\n-END\n\n\n-CHOICE-\n\n\n-END\n\n\n-CONDITIONS-\n\n\n-END"
	
	cursor_set_line(1)


func _input(_event):
	if Input.is_key_pressed(KEY_TAB) and not _pause:
		_pause = true
		lineNum = cursor_get_line()
		_cur_line = get_line(lineNum).rstrip(' ')
		var t = get_selection_text().lstrip(" ").rstrip(" ")
		var se = t.split(" ")
		var lead = se[0]
		var sub = ''
		if se.size() > 1:
			sub = se[1]
		
		match selection_match(lead):
			0:cursor_action()
			1:character_action(lead, sub)
			2:camera_action(sub)
			3:screen_action(sub)
			4:bgm_action(sub)
			5:float_action()
			6:font_action()
			7:then_action()
			8:fill_time()
			-1:return
			
		yield(get_tree().create_timer(0.2), 'timeout')
		_pause = false
		
func selection_match(lead:String) -> int:
	var m = -1
	match lead:
		"": m = 0
		"chara": m = 1
		"camera": m = 2
		"screen": m = 3
		"bgm": m = 4
		"float": m = 5
		"font": m = 6
		"then": m = 7
		"t": m = 8
		_: m = -1 
		
	return m

func cursor_action():
	set_line(lineNum, _cur_line + ":: ;")
	# insert_text_at_cursor(":: ;")
	cursor_set_column(cursor_get_column() + 2)

func character_action(lead:String, sub:String):
	set_line(lineNum,"")
	if lead == "chara": lead = "uid"
	match sub:
		"move": set_line(lineNum, "chara :: %s move; loc ::*; type :: linear; time :: 1;" % [lead])
		"jump": set_line(lineNum, "chara :: %s jump; amount :: 80; time :: 0.25; dir :: up;" % [lead])
		"join": set_line(lineNum, "chara :: %s join; loc ::*; expression :: default;" % [lead])
		"fadein": set_line(lineNum, "chara :: %s fadein; loc ::*; expression :: default ; time :: 1;" % [lead])
		"shake": set_line(lineNum, "chara :: %s shake; amount :: 250 ; time :: 2;" % [lead])
		"fadeout": set_line(lineNum, "chara :: %s fadeout; time :: 1 ;" % [lead])
		"add": set_line(lineNum, "chara :: %s add; path :: /ur/path/to/ur/scene.tscn; at :: _point;" % [lead])
		"spin": set_line(lineNum, "chara :: %s spin; deg :: 360; time :: 1; type :: linear ; sdir :: 1;" % [lead])
		"leave": set_line(lineNum, "chara :: %s leave;" % [lead])
		"vpunch": set_line(lineNum, "chara :: %s vpunch;" % [lead])
		"hpunch": set_line(lineNum, "chara :: %s hpunch;" % [lead])
		_: return

func camera_action(sub:String):
	set_line(lineNum,"")
	match sub:
		"shake": set_line(lineNum, "camera :: shake; amount :: 250; time :: 2;")
		"zoom": set_line(lineNum, "camera :: zoom; scale ::*; loc :: 0 0; time :: 1; type :: linear;")
		"move": set_line(lineNum, "camera :: move; loc ::*; time :: 1; type :: linear;")
		"spin": set_line(lineNum, "camera :: spin; deg ::*; sdir:1; time :: 1; type :: linear;")
		_: return

func screen_action(sub:String):
	set_line(lineNum,"")
	match sub:
		"tint": set_line(lineNum, "screen :: tint; color ::*; time :: 1;")
		"tintwave": set_line(lineNum, "screen :: tintwave; color ::*; time :: 1;")
		"flashlight": set_line(lineNum, "screen :: flashlight; scale :: 1 1;")

func bgm_action(sub:String):
	set_line(lineNum,"")
	match sub:
		"fadein": set_line(lineNum, "bgm ::*; fadein ::*; vol :: 0;")
		"fadeout": set_line(lineNum, "bgm :: off; fadeout ::*; vol :: 0;")

func float_action():
	set_line(lineNum,"")
	set_line(lineNum, "float :: ur_text; wait ::*; loc :: 400 400; fadein :: 1;")

func font_action():
	set_line(lineNum,"")
	set_line(lineNum, "font :: normal; path :: your_font_resource.tres;")
	
func then_action():
	set_line(lineNum,"")
	set_line(lineNum, "then :: target_block_name; target id :: your_id;")
	
func fill_time():
	set_line(lineNum,"")
	set_line(lineNum, "time :: *;")
	

#-------------------------------- Above is Script Editing --------------------------------
#-------------------------------- Below is Text Parsing ----------------------------------

func strip_text(t:String) -> String:
	# Potentially this is faster than strip_edges? 
	# = Python Strip, get rid of left and right empty spaces
	t = (t.lstrip(" ")).rstrip(" ")
	t = t.replace("\t","")
	return t
	
func line_to_choice(line:String, num:int) -> Dictionary:
	var ev : Dictionary = {}
	
	var sm_split = line.split(";")
	var l = sm_split.size()
	l -= 1
	if sm_split[l] == "":
		sm_split.remove(l)
	else:
		print("Error when parsing at line: " + line)
		push_error("Missing ; at the end of line %s" % [num])
		_has_error = true
		
	if l <= 2:
		for term in sm_split:
			var t = term.split("::")
			var left = strip_text(t[0])
			var right = strip_text(t[1])
			if left == "condition":
				right = _cond_to_array(right)
				ev[left] = right
			else:
				var temp = JSON.parse(right).result
				if typeof(temp) == TYPE_DICTIONARY:
					match temp: # pass = pass the check
						{"dvar"}: pass
						{}: pass
						{"then"}: pass
						{"then", "target id"}: pass
						_:
							push_error("Invalid choice event. Choice event can only be "+\
							"a dvar event, or a then event, or empty.")
							push_error("Choice format error at line number " + str(num))
							_has_error = true
							
					if _has_error == false:
						ev[left] = temp
				else:
					push_error("You must put a dictionary as your choice event.")
					push_error("Choice format error at line number " + str(num))
					_has_error = true

	else:
		push_error("Too many fields in the choice event: %s." %[line])
		push_error("Choice format error at line number " + str(num))
		_has_error = true
		
	return ev
	
func line_to_cond(line:String, num:int):
	# A condition line should be like: name_of_cond :: cond ;
	var sm_split = line.split(";")
	if sm_split[sm_split.size()-1] == "":
		sm_split.remove(sm_split.size()-1)
	else:
		print("Error when parsing at line: " + line)
		push_error("Missing ';' at end of line " + str(num))
		_has_error = true
		
	if sm_split.size() == 1:
		var term = (sm_split[0]).split("::")
		var left = strip_text(term[0])
		var right = strip_text(term[1])
		right = _cond_to_array(right)
		_cond_blocks[left] = right
	else:
		push_error("Expecting one condition per line. Error at line " + str(num))
		_has_error = true
	
func line_to_event(line:String, num:int)->Dictionary:
	var ev : Dictionary = {}
	var sm_split = line.split(";")
	if sm_split[sm_split.size()-1] == "":
		sm_split.remove(sm_split.size()-1)
	else:
		print("Error when parsing at line: " + line)
		push_error("Missing ';' at end of line " + str(num))
		_has_error = true
	
	for term in sm_split:
		var temp = term.split("::")
		if temp.size() == 2:
			var key = strip_text(temp[0])
			var val = strip_text(temp[1])
			if val.is_valid_float():
				val = float(val)
			elif key == "condition":
				val = _cond_to_array(val)
			elif key == "params":
				val = _parse_params(val)
			ev[key] = val
		else:
			print("Incorrect format: " + term + " at line " + str(num))
			print("Expecting to see a key value pair separated by :: and ended with a ;")
			push_error("Incorrect format at line" + str(num))
			_has_error = true
	
	return ev

func check_label(line:String):
	var temp = line.split("-")
	var title = temp[1]
	match title:
		"DIALOG":
			if temp.size() == 3:
				_d_name = temp[2]
				_dialog_blocks[_d_name] = []
				_parse_mode = 1
			else:
				print(line)
				push_error("Should have format '-DIALOG-dialog_name'")
				_has_error = true
		"CHOICE":
			if temp.size() == 3:
				_ch_name = temp[2]
				_choice_blocks[_ch_name] = []
				_parse_mode = 2
			else:
				print(line)
				push_error("Should have format '-CHOICE-choice_name'")
				_has_error = true
		"CONDITIONS":
			_parse_mode = 3
		"END": _parse_mode = 0
		_: _parse_mode = 0

func _parse_timeline():
	_parse_mode = 0
	_one_condition_block = false
	var ev_list = text.split("\n")
	for i in range(ev_list.size()):
		var line = ev_list[i]
		line = line.strip_edges()
		if line == "": continue
		if line[0] == "#": continue
		if line[0] == "-": 
			check_label(line)
			continue
		match _parse_mode:
			1: _dialog_blocks[_d_name].push_back(line_to_event(line,i+1))
			2: _choice_blocks[_ch_name].push_back(line_to_choice(line,i+1))
			3: 
				if _one_condition_block == false:
					_one_condition_block = true
					line_to_cond(line,i+1)
				else: # if this is true, then there is already one condition block
					push_error("In one timeline, only one condition block is allowed.")
					push_error("Additional condition block at line number " + str(i+1))

func _cond_to_array(cond:String):
	cond = cond.strip_edges()
	if "," in cond and cond[0]=='[' and cond[cond.length()-1] == "]":
		cond = cond.replace(" ", '')
		cond = cond.replace("[", "[\"")
		cond = cond.replace("]", "\"]")
		cond = cond.replace(",", "\",\"")
		var new_str : String = ""
		for i in cond.length():
			var letter = cond[i]
			if letter == "\"":
				if cond[i+1] != "[" and (cond[i+1] != "]" or cond[i-1] != "]")\
				and (cond[i+1] != "," or cond[i-1] != "]"):
					new_str += letter
			else:
				new_str += letter
		# print(new_str)
		return JSON.parse(new_str).result
	else:
		print("Condition %s is being treated as a literal string." % cond)
		return cond
		
func _parse_params(pa : String):
	if pa.is_valid_float():
		return float(pa)
	if pa == "true" or pa == "True":
		return true
	if pa == "false" or pa == "False":
		return false
	
	var test = JSON.parse(pa).result
	if test == null:
		push_error("The param field %s cannot be parsed." % [pa])
		_has_error = true
	else:
		return test

func get_timeline(): # reset these dictionaries when a new get_timeline call is triggered
	_has_error = false
	_dialog_blocks = {}
	_d_name = ""
	_choice_blocks = {}
	_ch_name = ""
	_cond_blocks = {}
	_parse_timeline()
	if _has_error:
		return null
	else:
		return {"Dialogs":_dialog_blocks,"Choices": _choice_blocks, "Conditions": _cond_blocks}
