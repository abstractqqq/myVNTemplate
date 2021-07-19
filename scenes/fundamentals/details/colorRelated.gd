extends CanvasLayer


var rect = preload("res://scenes/fundamentals/details/transitionRect.tscn")
var tintRect = preload("res://scenes/fundamentals/details/tintRect.tscn")
var tintOn = false


func fadeout(time:float):
	var r = rect.instance()
	self.add_child(r)
	r.fadeout(time)
	

func fadein(time:float):
	var r = rect.instance()
	self.add_child(r)
	r.fadein(time)
	

func tint(c: Color, time: float):
	
	if tintOn: # if tint is already on, overwrite old tint
		removeLasting()
	var tint = tintRect.instance()
	get_node('lasting').add_child(tint)
	tint.set_tint(c, time)
	tintOn = true
	
	
func removeLasting():
	var lasting = get_node('lasting')
	for n in lasting.get_children():
		n.queue_free()

	
func tintWave(c:Color,time:float):
	
	if tintOn: # overwrite old tint
		removeLasting()
	
	var tint = tintRect.instance()
	get_node('lasting').add_child(tint)
	tint.set_tintwave(c, time)
	tintOn = true


func pixelate_out(t:float):
	var r = rect.instance()
	self.add_child(r)
	r.pixelate_out(t)

# Pixellate is only used during a screen transition. So if pixellate out
# is called, then color rect already has loaded the material
func pixelate_in(t:float):
	var r = rect.instance()
	self.add_child(r)
	r.pixelate_in(t)


