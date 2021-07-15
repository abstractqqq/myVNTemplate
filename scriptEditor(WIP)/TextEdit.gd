extends TextEdit

func _ready():

	add_keyword_color("true", Color(0.675781, 0.202991, 0.202991))
	add_keyword_color("false", Color(0.675781, 0.202991, 0.202991))
	add_color_region('#', '', Color(0.472656, 0.472656, 0.472656))
	
	
	cursor_set_line(1)


func strip_text(t:String) -> String: 
	# Strip text of left space/quotation marks and right space/quotation marks
	t = (t.lstrip(" ")).rstrip(" ")
	t = (t.lstrip("\"")).rstrip("\"")
	t = (t.lstrip("'")).rstrip("'")
	return t

func detail_to_event(arr: Array) -> Dictionary:
	var ev = {}
	for term in arr:
		if not "::" in term:
			print(term)
			vn.error("Script Editor: One double-colon is expected.")
			
		
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
		# detail = [chara:a join, loc:Vector2(100,500), expression:happy]
		all_events.append(detail_to_event(detail))
		
	return all_events
	


