extends TextEdit

var loading = false

func _ready():

	add_color_region('"', '"', Color(0.0726, 0.367188, 0.0726))
	add_color_region("'", "'", Color(0.0726, 0.367188, 0.0726))
	add_keyword_color("true", Color(0.675781, 0.202991, 0.202991))
	add_keyword_color("false", Color(0.675781, 0.202991, 0.202991))
	add_color_region('#', '', Color(0.472656, 0.472656, 0.472656))
	text = ":"
	cursor_set_line(1)


func strip_text(t:String) -> String: 
	# Strip text of left space/quotation marks and right space/quotation marks
	t = (t.lstrip(" ")).rstrip(" ")
	t = (t.lstrip("\"")).rstrip("\"")
	t = (t.lstrip("'")).rstrip("'")
	return t

func detail_to_event(arr: Array, not_parse = true) -> Dictionary:
	var ev = {}
	for term in arr:
		if not ":" in term:
			vn.error("Script Editor: One colon is expected.")
			
		
		var temp = term.split(":")
		var left = strip_text(temp[0])
		var right = null
		match temp.size():
			1:right = ""
			2:right = strip_text(temp[1])
			_: vn.error("Script Editor: Only one colon is expected, but got more.")
		
		# Do not parse
		if not_parse:
			ev[left] = right
			continue

	return ev
	
	
func get_events():
	var all_events = []
	var ev_list = text.split("\n")
	for i in ev_list.size():
		var line = (ev_list[i]).lstrip(' ') 
		if line == "": continue
		if line[0] == "#": continue
		# A typical line looks like 
		# chara: a join, loc: Vector2(100,500), expression: happy
		var detail = line.split(",")
		# detail = [chara:a join, loc:Vector2(100,500), expression:happy]
		all_events.append(detail_to_event(detail))
		
	return all_events
	


func _on_TextEdit_text_changed():
	if loading:
		return
	
	if self.text == "":
		self.text = ":"
		cursor_set_line(1)
		return 
		
	var a = self.text[self.text.length()-1]
	if a == "\n":
		self.text += ":"
		cursor_set_line(get_line_count())
