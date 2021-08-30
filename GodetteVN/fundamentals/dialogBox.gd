extends RichTextLabel

onready var timer = $Timer
onready var autoTimer = $autoTimer
var autoCounter = 0
var skipCounter = 0
var adding = false
var nw = false

var leng = 0

var FONTS = {}
const ft = ['normal', 'bold', 'italics', 'bold_italics']

signal load_next

func _ready():
	for f in ft:
		FONTS[f] = get('custom_fonts/%s_font'%f)
	autoTimer.start()

func reset_fonts():
	for f in ft:
		add_font_override('%s_font'%f, FONTS[f])


func set_chara_fonts(ev:Dictionary):
	for key in ev.keys():
		ev[key] = ev[key].strip_edges()
		if ev[key] != '':
			add_font_override(key, load(ev[key]))

func set_dialog(words : String, cps = vn.cps, extend = false):
	# words will be already preprocessed
	if extend:
		visible_characters = self.text.length()
		bbcode_text += " " +words
	else:
		visible_characters = 0
		bbcode_text = words
		
	leng = self.text.length()
	
	match cps:
		25: timer.wait_time = 0.04
		0:
			self.visible_characters = -1
			adding = false
			if nw:
				nw = false
				emit_signal("load_next")
			return
		10: timer.wait_time = 0.1
		_: timer.wait_time = 0.02
		
	adding = true
	timer.start()
	
func force_finish():
	if adding:
		self.visible_characters = leng
		adding = false
		timer.stop()
		if nw:
			nw = false
			if not vn.skipping:
				emit_signal("load_next")

func _on_Timer_timeout():
	self.visible_characters += 1
	if self.visible_characters >= leng:
		adding = false
		timer.stop()
		if nw:
			nw = false
			emit_signal("load_next")



# Call this after set_dialog, to get parsed words. (Pvars will be parsed
# into text.)
func get_text():
	return self.bbcode_text


func _on_autoTimer_timeout():
	if vn.skipping:
		force_finish()
		skipCounter = (skipCounter + 1)%(vn.SKIP_SPEED)
		if skipCounter == 1:
			emit_signal("load_next")
	else:
		if not adding and vn.auto_on: 
			autoCounter += 1
			if autoCounter >= vn.auto_bound:
				autoCounter = 0
				if not nw:
					emit_signal("load_next")
	
		else:
			autoCounter = 0
			
		skipCounter = 0
