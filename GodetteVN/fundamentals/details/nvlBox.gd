extends RichTextLabel

# I could have let NVL extend from dialog.gd, but I am afraid that
# in the future some functionality will be drastically different
# for nvl mode and regular (avl) mode.

# Right now, all functions in nvl are slightly different than those
# in dialog.gd

# Same as dialog box
onready var autoTimer = $autoTimer
var skipCounter = 0
var autoCounter = 0
var adding = false
var nw = false


# center = nvl in disguise
const default_size = Vector2(1100,800)
const default_pos = Vector2(410,50)
const CENTER_SIZE = Vector2(1100,300)
const CENTER_POS = Vector2(410,400)
var last_uid = ''
var new_dialog = ''

var _target_leng = 0
signal load_next

func _ready():
	autoTimer.stop()

func set_dialog(uid : String, words : String, cps = vn.cps, suppress_name = false, mode="linear"):
	if suppress_name: # if name should not be shown, as in the center case treat it as if it is the narrator
		uid = ""
		
	if (uid != last_uid):
		last_uid = uid
		if uid == "":
			if self.text != '':
				self.bbcode_text += "\n\n"
		else:
			var ch_info = chara.all_chara[uid]
			var color = ch_info["name_color"]
			if color == null:
				color = Color(255,255,255)
			var n = ch_info["display_name"]
			color = color.to_html(false)
			if self.text == '':
				self.bbcode_text += "[color=#" + color + "]" + n + ":[/color]\n"
			else:
				self.bbcode_text += "\n\n[color=#" + color + "]" + n + ":[/color]\n"
			
	else:
		self.bbcode_text += " "
	
	visible_characters = self.text.length()
	new_dialog = words
	bbcode_text += words
	_target_leng = self.text.length() #
	
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
		self.visible_characters = _target_leng
		adding = false
		$Tween.stop_all()
		if nw:
			nw = false
			if not vn.skipping:
				emit_signal("load_next")


func get_text():
	return self.new_dialog

func center_mode():
	self.rect_position = CENTER_POS
	self.rect_size = CENTER_SIZE
	self.grow_horizontal = Control.GROW_DIRECTION_BOTH
	self.grow_vertical = Control.GROW_DIRECTION_BOTH
	self.bbcode_text = "[center]"

func clear():
	game.nvl_text = ""
	self.queue_free()


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

func _on_Tween_tween_completed(_object, _key):
	adding = false
	if nw:
		nw = false
		emit_signal("load_next")
