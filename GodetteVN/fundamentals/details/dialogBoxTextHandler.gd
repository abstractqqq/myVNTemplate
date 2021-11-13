extends RichTextLabel

# Not implemented yet because I cannot find any resource
export(bool) var noise_on = false
export(String) var noise_file_path = ''

onready var autoTimer = $autoTimer
var autoCounter = 0
var skipCounter = 0
var adding = false
var nw = false

var _target_leng = 0

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

func set_dialog(words : String, cps = vn.cps, extend = false,mode="linear"):
	# words will be already preprocessed
	if extend:
		visible_characters = self.text.length()
		bbcode_text += " " +words
	else:
		visible_characters = 0
		bbcode_text = words
		
	_target_leng = self.text.length()
	
	if cps <= 0:
		visible_characters = _target_leng
		adding = false
		if nw:
			nw = false
			emit_signal("load_next")
		return
	
	adding = true
	$Tween.interpolate_property(self, "visible_characters", visible_characters,_target_leng,\
		float(_target_leng-visible_characters)/float(cps),fun.movement_type(mode),Tween.EASE_IN_OUT)
	$Tween.start()

	
func force_finish():
	if adding:
		visible_characters = _target_leng
		adding = false
		$Tween.stop_all()
		if nw:
			nw = false
			if not vn.skipping:
				emit_signal("load_next")


# Will be moved.
func _on_autoTimer_timeout():
	if vn.skipping:
		# skipping
		force_finish()
		skipCounter = (skipCounter + 1)%(vn.SKIP_SPEED)
		if skipCounter == 1:
			emit_signal("load_next")
	else:
		# Auto forwarding
		if not adding and vn.auto_on: 
			autoCounter += 1
			if autoCounter >= vn.auto_bound:
				autoCounter = 0
				if not nw:
					emit_signal("load_next")
	
		else:
			autoCounter = 0
			
		skipCounter = 0


func _on_Tween_tween_completed(_object, _key):
	adding = false
	if nw:
		nw = false
		emit_signal("load_next")
	
