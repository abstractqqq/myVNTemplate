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
#----------------------------------------------------------

func _ready():
	add_color_region("#", '', line_comment_color, true)
	add_color_region("::", ";", field_val_color)
	add_color_region("-DIALOG-", "", label_color, true)
	add_color_region("-CONDITIONS-", "", label_color, true)
	add_color_region("-CHOICE-", "", label_color, true)
	add_color_region("-END", "", label_color, true)
	self.text = "-DIALOG-starter\n\n\n-END\n\n\n-CHOICE-\n\n\n-END\n\n\n-CONDITIONS-\n\n\n-END"
	
	cursor_set_line(1)


func _input(event):
	if event.is_action_pressed("script_tab"):
		lineNum = cursor_get_line()
		var t = get_selection_text().lstrip(" ").rstrip(" ")
		var se = t.split(" ")
		var lead = se[0]
		var sub = null
		if se.size() > 1:
			sub = se[1]
		
		match selection_match(lead):
			0:cursor_action()
			1:character_action(sub)
			2:camera_action(sub)
			3:screen_action(sub)
			4:bgm_action(sub)
			5:float_action()
			6:font_action()
			7:then_action()
			-1:return

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
		_: m = -1
		
	return m

func cursor_action():
	insert_text_at_cursor(":: ;")
	cursor_set_column(cursor_get_column() - 1)

func character_action(sub:String):
	set_line(lineNum,"")
	match sub:
		"move": set_line(lineNum, "chara :: uid move ; loc :: ; type :: linear  ; time :: 1 ;")
		"jump": set_line(lineNum, "chara :: uid jump ; amount :: 80 ; time :: 0.25 ; dir :: up ;")
		"join": set_line(lineNum, "chara :: uid join ; loc :: ; expression :: default ;")
		"fadein": set_line(lineNum, "chara :: uid fadein ; loc :: ; expression :: default ; time :: 1 ;")
		"shake": set_line(lineNum, "chara :: uid shake ; amount :: 250 ; time :: 2 ;")
		"fadeout": set_line(lineNum, "chara :: uid fadeout ; time :: 1 ;")
		"spin": set_line(lineNum, "chara :: uid spin ; deg :: 360 ; time :: 1 ; type :: linear ; sdir :: 1 ;")
		"leave": set_line(lineNum, "chara :: uid leave ;")
		"vpunch": set_line(lineNum, "chara :: uid vpunch ;")
		"hpunch": set_line(lineNum, "chara :: uid hpunch ;")
		_: return

func camera_action(sub:String):
	set_line(lineNum,"")
	match sub:
		"shake": set_line(lineNum, "camera :: shake ; amount :: 250 ; time :: 2 ;")
		"zoom": set_line(lineNum, "camera :: zoom ; scale :: ; loc :: 0 0 ; time :: 1, type :: linear ;")
		"move": set_line(lineNum, "camera :: move ; loc :: ; time :: 1 ; type :: linear ;")
		_: return

func screen_action(sub:String):
	set_line(lineNum,"")
	match sub:
		"tint": set_line(lineNum, "screen :: tint ; color ::  ; time :: 1 ;")
		"tintwave": set_line(lineNum, "screen :: tintwave ; color :: ; time :: 1 ;")
		"flashlight": set_line(lineNum, "screen :: flashlight ; scale :: 1 1 ;")

func bgm_action(sub:String):
	set_line(lineNum,"")
	match sub:
		"fadein": set_line(lineNum, "bgm :: ; fadein :: ; vol :: 0 ;")
		"fadeout": set_line(lineNum, "bgm :: off ; fadeout :: ; vol :: 0 ;")

func float_action():
	set_line(lineNum,"")
	set_line(lineNum, "float :: ur_text ; wait :: ; loc :: 400 400 ; fadein :: 1 ; font :: default ;")

func font_action():
	set_line(lineNum,"")
	set_line(lineNum, "font :: normal ; path :: your_font_resource.tres ;")
	
func then_action():
	set_line(lineNum,"")
	set_line(lineNum, "then :: target_block_name ; target id :: -1 ;")

#-------------------------------- Above is Script Editing --------------------------------
#-------------------------------- Below is Text Parsing ----------------------------------

func strip_text(t:String) -> String: 
	# = Python Strip, get rid of left and right empty spaces
	t = (t.lstrip(" ")).rstrip(" ")
	t = t.replace("\t","")
	return t
	
func line_to_choice(line:String, num:int) -> Dictionary:
	var ev : Dictionary = {}
	
	var sm_split = line.split(";")
	var l = sm_split.size()
	if sm_split[l-1] == "":
		sm_split.remove(l-1)
		l -= 1
	else:
		print("Error when parsing at line: " + line)
		vn.error("Missing ';' at end of line " + str(num))
		
	if l == 2:
		var valid = false
		var ctext : String = ""
		var cev = {}
		# find choice_text field first,
		for term in sm_split:
			if "c_text" in term:
				valid = true
				var pair = term.split("::")
				ctext = strip_text(pair[1])
			else:
				var t = term.split("::")
				var left = strip_text(t[0])
				var right = strip_text(t[1])
				if left == "then" or left == "dvar":
					cev[left] = right
				else:
					print("Currently only 3 choices events are allowed: nothing, then event, or dvar event.")
					vn.error("Choice format error at line number " + str(num))
		if valid:
			ev[ctext] = cev
		else:
			print("A choice line must have one 'c_text' field.")
			vn.error("Choice format error at line number " + str(num))
	elif l == 1:
		if "c_text" in sm_split[0]:
			var pair = sm_split[0].split("::")
			var right = strip_text(pair[1])
			ev[right] = {}
		else:
			print("A choice line must have one 'c_text' field.")
			vn.error("Choice format error at line number " + str(num))
	else:
		print("Error when parsing at line: " + line)
		print("A choice line should have one 'c_text' field and only one other optional choice event.")
		print("Currently only 3 choices events are allowed: empty dict, then event, or dvar event.")
		vn.error("Choice format error at line number " + str(num))
		
	return ev
	
func line_to_cond(line:String, num:int):
	# A condition line should be like: name_of_cond :: cond ;
	var sm_split = line.split(";")
	if sm_split[sm_split.size()-1] == "":
		sm_split.remove(sm_split.size()-1)
	else:
		print("Error when parsing at line: " + line)
		vn.error("Missing ';' at end of line " + str(num))
		
	if sm_split.size() == 1:
		var term = (sm_split[0]).split("::")
		var left = strip_text(term[0])
		var right = strip_text(term[1])
		if "," in right:
			var temp = right.split(',')
			right = []
			for t in temp:
				right.push_back(t)
		
		_cond_blocks[left] = right
	else:
		vn.error("Expecting one condition per line. Error at line " + str(num))
	
func line_to_event(line:String, num:int)->Dictionary:
	var ev : Dictionary = {}

	var sm_split = line.split(";")
	if sm_split[sm_split.size()-1] == "":
		sm_split.remove(sm_split.size()-1)
	else:
		print("Error when parsing at line: " + line)
		vn.error("Missing ';' at end of line " + str(num))
	
	for term in sm_split:
		var temp = term.split("::")
		if temp.size() == 2:
			var key = strip_text(temp[0])
			var val = strip_text(temp[1])
			if val.is_valid_float():
				val = float(val)
			ev[key] = val
		else:
			print("Incorrect format: " + term + " at line " + str(num))
			print("Expecting to see a key value pair separated by :: and ended with a ;")
			vn.error("Incorrect format at line " + str(num))
	
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
				vn.error("Should have format '-DIALOG-dialog_name'")
		"CHOICE":
			if temp.size() == 3:
				_ch_name = temp[2]
				_choice_blocks[_ch_name] = []
				_parse_mode = 2
			else:
				print(line)
				vn.error("Should have format '-CHOICE-choice_name'")
		"CONDITIONS":
			_parse_mode = 3
		"END": _parse_mode = 0
		_: _parse_mode = 0

func _parse_timeline():
	_parse_mode = 0
	var ev_list = text.split("\n")
	for i in range(ev_list.size()):
		var line = ev_list[i]
		line = line.lstrip(' ') 
		if line == "": continue
		if line[0] == "#": continue
		if line[0] == "-": 
			check_label(line)
			continue
		match _parse_mode:
			1: _dialog_blocks[_d_name].push_back(line_to_event(line,i+1))
			2: _choice_blocks[_ch_name].push_back(line_to_choice(line,i+1))
			3: line_to_cond(line,i+1)
		
func get_timeline():
	_parse_timeline()
	return {"Dialogs":_dialog_blocks,"Choices": _choice_blocks, "Conditions": _cond_blocks}
