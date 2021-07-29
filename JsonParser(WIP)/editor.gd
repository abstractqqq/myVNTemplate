extends TextEdit

var lineNum : int

func _ready():
	add_color_region("#", '', Color(0.445313, 0.445313, 0.445313), true)
	add_color_region("::", ";", Color(0, 0.574219, 0.426178))
	cursor_set_line(1)


func strip_text(t:String) -> String: 
	# Strip text of left space/quotation marks and right space/quotation marks
	t = (t.lstrip(" ")).rstrip(" ")
	return t

func detail_to_event(arr: Array) -> Dictionary:
	var ev = {}
	if arr[arr.size()-1] == "":
		arr.pop_back()
	for term in arr:
		if not "::" in term:
			vn.error("Expecting to find one double colon in: " + term)
			
		
		var temp = term.split("::")
		var left = strip_text(temp[0])
		var right = strip_text(temp[1])
		if right.is_valid_float():
			right = float(right)
			
		if temp.size() > 2:
			print(term)
			vn.error("Expecting a key value pair. But got more than 2 values.")
		

		ev[left] = right
		

	return ev
	
	
func get_events():
	var all_events = []
	var ev_list = text.split("\n")
	for line in ev_list:
		line = line.lstrip(' ') 
		if line == "": continue
		if line[0] == "#": continue
		# A typical line looks like 
		# chara: a join, loc: Vector2(100,500), expression: happy
		var detail = line.split(';')
		detail.pop_back() 
		# detail = [chara:a join, loc:Vector2(100,500), expression:happy]
		all_events.append(detail_to_event(detail))
		
	return all_events
	

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

	match sub:
		"move": set_line(lineNum, "chara :: uid move ; loc :: ; type :: linear  ; time :: 1")
		"jump": set_line(lineNum, "chara :: uid jump ; amount :: 80 ; time :: 0.25 ; dir :: up")
		"join": set_line(lineNum, "chara :: uid join ; loc :: ; expression :: default")
		"fadein": set_line(lineNum, "chara :: uid fadein ; loc :: ; expression :: default ; time :: 1")
		"shake": set_line(lineNum, "chara :: uid shake ; amount :: 250 ; time :: 2")
		"fadeout": set_line(lineNum, "chara :: uid fadeout ; time :: 1")
		"leave": set_line(lineNum, "chara :: uid leave")
		_: return

func camera_action(sub:String):
	
	match sub:
		"shake": set_line(lineNum, "camera :: shake ; amount :: 250 ; time :: 2")
		"zoom": set_line(lineNum, "camera :: zoom ; scale :: ; loc :: 0 0 ; time :: 1, type :: linear")
		"move": set_line(lineNum, "camera :: move ; loc :: ; time :: 1 ; type :: linear")
		_: return

func screen_action(sub:String):
	
	match sub:
		"tint": set_line(lineNum, "screen :: tint ; color ::  ; time :: 1")
		"tintwave": set_line(lineNum, "screen :: tintwave ; color :: ; time :: 1")
		"flashlight": set_line(lineNum, "screen :: flashlight ; scale :: 1 1")

func bgm_action(sub:String):
	
	match sub:
		"fadein": set_line(lineNum, "bgm :: ; fadein :: ; vol :: 0")
		"fadeout": set_line(lineNum, "bgm :: off ; fadeout :: ; vol :: 0")

func float_action():
	set_line(lineNum, "float :: placeholder_text ; wait :: ; loc :: 400 400 ; fadein :: 1 ; font :: default")

func font_action():
	set_line(lineNum, "font :: normal ; path :: your_font_resource.tres")
	
func then_action():
	set_line(lineNum, "then :: target_block_name ; target id :: -1")

