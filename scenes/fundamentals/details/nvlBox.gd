extends RichTextLabel

onready var timer = $Timer
onready var autoTimer = $autoTimer

# center = nvl in disguise
const default_size = Vector2(1100,800)
const default_pos = Vector2(410,50)
const center_size = Vector2(1100,300)
const center_pos = Vector2(410,400)
var skipCounter = 0
var autoCounter = 0
var last_uid = ''
var adding = false
var new_dialog = ''
var nw = false
var bblength = 0 # Only used in timer to make the condition checking faster
signal load_next

func _ready():
	autoTimer.stop()
	timer.stop()

func set_dialog(uid : String, words : String, cps = vn.cps):
	if (uid != last_uid):
		last_uid = uid
		if uid == "":
			if self.text != '':
				self.bbcode_text += "\n\n"
		else:
			var color = chara.all_chara[uid].default_color
			var n = chara.all_chara[uid].display_name
			color = color.to_html(false)
			if self.text == '':
				self.bbcode_text += "[color=#" + color + "]" + n + ":[/color]\n"
			else:
				self.bbcode_text += "\n\n[color=#" + color + "]" + n + ":[/color]\n"
			
	else:
		self.bbcode_text += " "
	
	self.visible_characters = self.text.length()
	self.new_dialog = words
	self.bbcode_text += words
	bblength = self.text.length() # latest bbcode_text.length()
	
	match cps:
		25: timer.wait_time = 0.04
		0:
			self.visible_characters = bblength
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
		self.visible_characters = bblength
		adding = false
		timer.stop()
		if nw:
			nw = false
			if not vn.skipping:
				emit_signal("load_next")

func _on_Timer_timeout():
	self.visible_characters += 1
	if self.visible_characters >= bblength:
		adding = false
		timer.stop()
		if nw:
			nw = false
			emit_signal("load_next")



# Call this after set_dialog, to get newly parsed words. (Pvars will be parsed
# into text.)
func get_text():
	return self.new_dialog

func center_mode():
	self.rect_position = center_pos
	self.rect_size = center_size
	self.grow_horizontal = Control.GROW_DIRECTION_BOTH
	self.grow_vertical = Control.GROW_DIRECTION_BOTH
	self.bbcode_text = "[center]"


func clear():
	self.bbcode_text = ""
	game.nvl_text = ""
	last_uid = ''
	bblength = 0
	self.rect_position = default_pos
	self.rect_size = default_size
	self.grow_horizontal = Control.GROW_DIRECTION_END
	self.grow_vertical = Control.GROW_DIRECTION_END
	autoCounter = 0


func _on_autoTimer_timeout():
	if vn.skipping:
		force_finish()
		skipCounter = (skipCounter + 1)%2
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
