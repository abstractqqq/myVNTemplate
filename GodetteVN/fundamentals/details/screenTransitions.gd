extends CanvasLayer


func fadeout(time:float):
	var rect = load("res://GodetteVN/fundamentals/details/transitionRect.tscn")
	var r = rect.instance()
	self.add_child(r)
	r.fadeout(time)
	

func fadein(time:float):
	var rect = load("res://GodetteVN/fundamentals/details/transitionRect.tscn")
	var r = rect.instance()
	self.add_child(r)
	r.fadein(time)
	

func tint(c: Color, time: float):
	var tintRect = load("res://GodetteVN/fundamentals/details/tintRect.tscn")
	var tint = tintRect.instance()
	get_node('lasting').add_child(tint)
	tint.set_tint(c, time)

	
func removeLasting():
	var lasting = get_node('lasting')
	for n in lasting.get_children():
		n.call_deferred('free')

	
func tintWave(c:Color,time:float):
	var tintRect = load("res://GodetteVN/fundamentals/details/tintRect.tscn")
	var tint = tintRect.instance()
	get_node('lasting').add_child(tint)
	tint.set_tintwave(c, time)


func pixelate_out(t:float):
	var rect = load("res://GodetteVN/fundamentals/details/transitionRect.tscn")
	var r = rect.instance()
	self.add_child(r)
	r.pixelate_out(t)

func pixelate_in(t:float):
	var rect = load("res://GodetteVN/fundamentals/details/transitionRect.tscn")
	var r = rect.instance()
	self.add_child(r)
	r.pixelate_in(t)


