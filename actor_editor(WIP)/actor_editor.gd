extends Node2D

onready var uid_edit = $UID/LineEdit
onready var sp = $sprite
onready var sprite_options = $spriteInfo/OptionButton
onready var scalex = $UID/LineEditx
onready var scaley = $UID/LineEdity
var cur_exp_mapping = null
var cur_uid = ""


func _on_Button_pressed():
	self.cur_uid = uid_edit.text
	if cur_uid == "":
		return
	
	var sc = Vector2(1,1)
	var scx = scalex.text
	var scy = scaley.text
	if scx != "" and scx.is_valid_float():
		scx = abs(float(scx))
	else:
		scx = 1
	if scy != "" and scy.is_valid_float():
		scy = abs(float(scy))
		scaley.text = str(scy)
	else:
		scy = 1
		
	sc = Vector2(min(1,scx), min(1,scy))
	scalex.text = str(sc.x)
	scaley.text = str(sc.y)
	
	var c = chara.all_chara[cur_uid]
	cur_exp_mapping = c.expression_mapping
	var keys = cur_exp_mapping.keys()
	sprite_options.clear()
	for i in keys:
		sprite_options.add_item(i)
	
	sp.texture = load(vn.CHARA_DIR + cur_exp_mapping['default'])
	sp.scale = sc
	sprite_options.select(keys.find('default'))


func _on_OptionButton_item_selected(index):
	sp.texture = load(vn.CHARA_DIR + cur_exp_mapping[sprite_options.get_item_text(index)])
