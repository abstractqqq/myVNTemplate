extends Node2D

onready var uid_edit = $editOptions/main/LineEdit
onready var display_edit = $editOptions/displayName/displayName
onready var charaPopup = $charaGenPopup
onready var bg = $bg
onready var sp = $sprite
onready var sprite_options = $editOptions/spriteInfo/spriteOptions
onready var anim_options = $editOptions/animInfo/animOptions
onready var bg_options = $editOptions/bgInfo/bgOptions
onready var msg = $msg
onready var xscale = $editOptions/main/xLabel/xScale
onready var yscale = $editOptions/main/yLabel/yScale


var cur_uid = ""
var dname = ""
var temp_dict = {}
var anim_dict = {}
var sc = Vector2(1,1)
var found = false
var ready_to_generate = false

var counter = 0
var speed = 30
var displacement = Vector2()

func get_input():
	displacement = Vector2()
	if Input.is_action_pressed("ui_right"):
		displacement.x += 1
	if Input.is_action_pressed("ui_left"):
		displacement.x -= 1
	if Input.is_action_pressed("ui_down"):
		displacement.y += 1
	if Input.is_action_pressed("ui_up"):
		displacement.y -= 1
	displacement = displacement.normalized() * speed

func _process(_delta):
	if found:
		get_input()
		sp.position += displacement
		msg.text = "Current Position:" + str(sp.position)

func _input(_ev):
	if Input.is_key_pressed(KEY_G):
		counter = (counter+1)%2
		if (counter == 1):
			get_node('editOptions').visible = false
		else:
			get_node('editOptions').visible = true

func _ready():
	bg_options.add_item("No BG")
	var bg_lists = fileRelated.get_backgrounds()
	for b in bg_lists:
		bg_options.add_item(b)

func _on_Button_pressed():
	cur_uid = uid_edit.text
	if cur_uid == "":
		found = false
		return
	
	xscale.value = 1
	yscale.value = 1
	temp_dict = {}
	anim_dict = {}
	# Expression data
	var exp_lists = fileRelated.get_chara_sprites(cur_uid)
	for e in exp_lists:
		var temp = e.split(".")[0]
		temp = temp.split("_")
		temp_dict[temp[1]] = e
		sprite_options.add_item(temp[1])
		if temp[1] == "default":
			sp.texture = load(vn.CHARA_DIR + e)
		
	sp.position = Vector2(1200,600)
	
	var anim_lists = fileRelated.get_chara_sprites(cur_uid, "anim")
	for e in anim_lists:
		var temp = e.split(".")[0]
		temp = temp.split("_")
		anim_dict[temp[1]] = e
		anim_options.add_item(temp[1])
		
	
	uid_edit.release_focus()
	if temp_dict.size() > 0:
		found = true
		xscale.get_parent().text = "x scale: 1"
		yscale.get_parent().text = "y scale: 1"
	else:
		# Will be replaced by a popup eventually
		vn.error("Cannot find any basic character sprite this this uid. Nothing is done.")


func _on_spriteOptions_item_selected(index):
	sp.texture = load(vn.CHARA_DIR + temp_dict[sprite_options.get_item_text(index)])


func _on_xScale_value_changed(value):
	if found:
		sp.scale.x = value
		xscale.get_parent().text = "x scale: " + str(value)
		xscale.release_focus()

func _on_yScale_value_changed(value):
	if found:
		sp.scale.y = value
		yscale.get_parent().text = "y scale: " + str(value)
		yscale.release_focus()


func _on_bgOptions_item_selected(index):
	if index == 0:
		bg.texture = null
	else:
		bg.texture = load(vn.BG_DIR + bg_options.get_item_text(index))


func _on_generateButton_pressed():
	if found == false:
		return
	
	dname = display_edit.text
	if dname == "":
		ready_to_generate = false
		charaPopup.dialog_text = "You must give an non-empty display name."
		charaPopup.popup_centered()
	else:
		ready_to_generate = true
		charaPopup.dialog_text = ("You are about to generate a character scene with uid: {0}" +\
		" display name: {1}, which will have the path: {2}.").format({0:cur_uid,1:dname,2:(vn.CHARA_SCDIR+cur_uid+".tscn")})
		charaPopup.dialog_text += "\n You can pick a name color for the character in the scene."
		charaPopup.popup_centered()


func _on_charaGenPopup_confirmed():
	if ready_to_generate == false:
		return
	else:
		var packed_scene = PackedScene.new()
		var ch = (load("res://GodetteVN/Characters/characterTemplate.tscn")).instance()
		ch.unique_id = cur_uid
		ch.display_name = dname
		ch.expression_list = temp_dict
		ch.anim_list = anim_dict
		ch.scale = Vector2(xscale.value, yscale.value)
		ch.texture = load(vn.CHARA_DIR + temp_dict['default'])
		packed_scene.pack(ch)
		var error = ResourceSaver.save(vn.CHARA_SCDIR+cur_uid+".tscn", packed_scene)
		if error == OK:
			print("Character successfully saved to scene.")
		else:
			print("Some error occurred when trying to save as scene.")
		
		ready_to_generate = false
