extends TextureRect

const image_exts = ['png', 'jpg', 'jpeg']

onready var uid_edit = $editOptions/main/LineEdit
onready var display_edit = $editOptions/displayName/displayName
onready var sprite_options = $editOptions/spriteInfo/spriteOptions
onready var anim_options = $editOptions/animInfo/animOptions
onready var bg_options = $editOptions/bgInfo/bgOptions
onready var xscale = $editOptions/main/xLabel/xScale
onready var yscale = $editOptions/main/yLabel/yScale

var cur_uid = ""
var dname = ""
var temp_dict = {}
var anim_dict = {}
var sc = Vector2(1,1)
var found = false
var _ready_to_generate = false

var counter = 0
var speed = 30
var displacement = Vector2()
var sp = null

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
		var pos = $sprite.position + displacement
		$sprite.position = pos
		$msg.text = "Current Position:" + str(pos)

func _input(_ev):
	if Input.is_action_pressed("script_tab"):
		counter = (counter+1)%2
		if (counter == 1):
			get_node('editOptions').visible = false
		else:
			get_node('editOptions').visible = true

func _ready():
	bg_options.remove_item(0)
	bg_options.add_item("No BG")
	var bg_lists = _get_backgrounds()
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
	var index = 0
	var exp_list = _get_chara_sprites(cur_uid)
	for i in range(exp_list.size()):
		var temp = exp_list[i].split(".")[0]
		temp = temp.split("_")
		temp_dict[temp[1]] = exp_list[i]
		sprite_options.add_item(temp[1])
		if temp[1] == "default":
			index = i
			$sprite.texture = load(vn.CHARA_DIR + exp_list[i])
	
	$sprite.position = Vector2(1200,600)
	sprite_options.select(index)
	
	var anim_lists = _get_chara_sprites(cur_uid, "anim")
	for e in anim_lists:
		var temp = e.split(".")[0]
		temp = temp.split("_")
		anim_dict[temp[1]] = e
		anim_options.add_item(temp[1])
		
	uid_edit.release_focus()
	if temp_dict.size() > 0 or anim_lists.size() > 0:
		found = true
		xscale.get_parent().text = "x scale: 1"
		yscale.get_parent().text = "y scale: 1"
	else:
		# Will be replaced by a popup eventually
		vn.error("Cannot find any character sprite/anim for this this uid.")


func _on_spriteOptions_item_selected(index):
	$sprite.texture = load(vn.CHARA_DIR + temp_dict[sprite_options.get_item_text(index)])

func _on_xScale_value_changed(value):
	if found:
		$sprite.scale.x = value
		xscale.get_parent().text = "x scale: " + str(value)
		xscale.release_focus()

func _on_yScale_value_changed(value):
	if found:
		$sprite.scale.y = value
		yscale.get_parent().text = "y scale: " + str(value)
		yscale.release_focus()


func _on_bgOptions_item_selected(index):
	if index == 0:
		self.texture = null
	else:
		self.texture = load(vn.BG_DIR + bg_options.get_item_text(index))


func _on_generateButton_pressed():
	if found == false:
		return
	
	dname = display_edit.text
	if dname == "":
		_ready_to_generate = false
		$charaGenPopup.dialog_text = "You must give an non-empty display name."
		$charaGenPopup.popup_centered()
	else:
		_ready_to_generate = true
		$charaGenPopup.dialog_text = ("You are about to generate a character scene with uid: {0}" +\
		" display name: {1}, which will have the path: {2}.").format({0:cur_uid,1:dname,2:(vn.CHARA_SCDIR+cur_uid+".tscn")})
		$charaGenPopup.dialog_text += "\n You can pick a name color for the character in the generated scene."
		$charaGenPopup.dialog_text += "\n Currently you cannot edit character animation in the editor " +\
		"and you will have to go to the character scene to add your animations."
		$charaGenPopup.popup_centered()


func _on_charaGenPopup_confirmed():
	if _ready_to_generate == false:
		return
	else:
		var packed_scene = PackedScene.new()
		var ch = (load("res://GodetteVN/Characters/CharacterTemplate.tscn")).instance()
		var expSheet = SpriteFrames.new()
		for ex in temp_dict.keys():
			var t = load(vn.CHARA_DIR + temp_dict[ex])
			if expSheet.has_animation(ex):
				expSheet.remove_animation(ex)
			expSheet.add_animation(ex)
			expSheet.add_frame(ex, t)
			expSheet.set_animation_loop(ex, false)
			
		for an in anim_dict.keys():
			if expSheet.has_animation(an):
				expSheet.remove_animation(an)
			expSheet.add_animation(an)
			expSheet.set_animation_loop(an, false)
		
		var sheetName = vn.CHARA_SCDIR+cur_uid+"_expressionSheet.tres"
		var error = ResourceSaver.save(sheetName, expSheet)
		if error == OK:
			print("Character expression sheet saved.")
		else:
			print("Some error occurred when trying to save spriteSheet.")
		
		ch.name = cur_uid
		ch.set_sprite_frames(load(sheetName))
		ch.unique_id = cur_uid
		ch.display_name = dname
		ch.scale = Vector2(xscale.value, yscale.value)
		packed_scene.pack(ch)
		error = ResourceSaver.save(vn.CHARA_SCDIR+cur_uid+".tscn", packed_scene)
		if error == OK:
			print("Character successfully saved to scene.")
		else:
			print("Some error occurred when trying to save as scene.")
		
		_ready_to_generate = false


# -------------------------------------------------------------------------
func _get_backgrounds():
	# This method should only be used in development phase.
	# The exported project won't work with dir calls depending on
	# what kind of paths are passed.
	var bgs = []
	var dir = Directory.new()
	if !dir.dir_exists(vn.BG_DIR):
		dir.make_dir_recursive(vn.BG_DIR)
	
	dir.open(vn.BG_DIR)
	dir.list_dir_begin()
	
	while true:
		var pic = dir.get_next()
		if pic == "":
			break
		elif not pic.begins_with("."):
			var temp = pic.split(".")
			var ext = temp[temp.size()-1]
			if ext in image_exts:
				bgs.append(pic)
				
	dir.list_dir_end()
	return bgs
	
func _get_chara_sprites(uid, which = "sprite"):
	# This method should only be used in development phase.
	# The exported project won't work with dir calls depending on
	# what kind of paths are passed.
	var sprites = []
	var dir = Directory.new()
	if which == "anim" or which == "animation" or which == "spritesheet":
		which = vn.CHARA_ANIM
	elif which == "side" or which == "side_image" or which == "side image":
		which = vn.CHARA_SIDE
	else:
		which = vn.CHARA_DIR
		
	if !dir.dir_exists(which):
		dir.make_dir_recursive(which)
	
	dir.open(which)
	dir.list_dir_begin()
	
	while true:
		var pic = dir.get_next()
		if pic == "":
			break
		elif not pic.begins_with("."):
			var temp = pic.split(".")
			var ext = temp[temp.size()-1]
			if ext in image_exts:
				var pic_id = (temp[0].split("_"))[0]
				if pic_id == uid:
					sprites.append(pic)
				
	dir.list_dir_end()
	return sprites
