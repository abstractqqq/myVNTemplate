tool
extends TextureRect

const image_exts = ['png', 'jpg', 'jpeg']
const bg_dir = "res://assets/backgrounds/"
const chara_dir = "res://assets/actors/"
const chara_scdir = "res://GodetteVN/Characters/"

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

#func get_input():
#	displacement = Vector2()
#	if Input.is_action_pressed("ui_right"):
#		displacement.x += 1
#	if Input.is_action_pressed("ui_left"):
#		displacement.x -= 1
#	if Input.is_action_pressed("ui_down"):
#		displacement.y += 1
#	if Input.is_action_pressed("ui_up"):
#		displacement.y -= 1
#	displacement = displacement.normalized() * speed

#func _process(_delta):
#	if found:
#		get_input()
#		var pos = $sprite.position + displacement
#		$sprite.position = pos
#		$msg.text = "Current Position:" + str(pos)

#func _input(_ev):
#	if Input.is_action_pressed("script_tab"):
#		counter = (counter+1)%2
#		if (counter == 1):
#			get_node('editOptions').visible = false
#		else:
#			get_node('editOptions').visible = true

func _ready():
	$editOptions/bgInfo/bgOptions.remove_item(0)
	$editOptions/bgInfo/bgOptions.add_item("No BG")
	var bg_lists = _get_backgrounds()
	for b in bg_lists:
		$editOptions/bgInfo/bgOptions.add_item(b)

func _on_Button_pressed():
	cur_uid = $editOptions/main/LineEdit.text
	if cur_uid == "":
		found = false
		return
	
	$editOptions/main/xLabel/xScale.value = 1
	$editOptions/main/xLabel/xScale.value = 1
	temp_dict = {}
	anim_dict = {}
	# Expression data
	var index = 0
	var exp_list = _get_chara_sprites(cur_uid)
	for i in range(exp_list.size()):
		var temp = exp_list[i].split(".")[0]
		temp = temp.split("_")
		temp_dict[temp[1]] = exp_list[i]
		$editOptions/spriteInfo/spriteOptions.add_item(temp[1])
		if temp[1] == "default":
			index = i
			$sprite.texture = load(chara_dir + exp_list[i])
	
	$sprite.position = Vector2(1200,600)
	$editOptions/spriteInfo/spriteOptions.select(index)
	
	var anim_lists = _get_chara_sprites(cur_uid, "anim")
	for e in anim_lists:
		var temp = e.split(".")[0]
		temp = temp.split("_")
		anim_dict[temp[1]] = e
		$editOptions/animInfo/animOptions.add_item(temp[1])
		
	$editOptions/main/LineEdit.release_focus()
	if temp_dict.size() > 0 or anim_lists.size() > 0:
		found = true
		$editOptions/main/xLabel/xScale.get_parent().text = "x scale: 1"
		$editOptions/main/yLabel/yScale.get_parent().text = "y scale: 1"
	else:
		# error message
		pass


func _on_spriteOptions_item_selected(index):
	$sprite.texture = load(chara_dir + temp_dict[$editOptions/spriteInfo/spriteOptions.get_item_text(index)])

func _on_xScale_value_changed(value):
	if found:
		$sprite.scale.x = value
		$editOptions/main/xLabel.text = "x scale: " + str(value)
		$editOptions/main/xLabel/xScale.release_focus()

func _on_yScale_value_changed(value):
	if found:
		$sprite.scale.y = value
		$editOptions/main/yLabel.get_parent().text = "y scale: " + str(value)
		$editOptions/main/yLabel/yScale.release_focus()


func _on_bgOptions_item_selected(index):
	if index == 0:
		self.texture = null
	else:
		self.texture = load(bg_dir + $editOptions/bgInfo/bgOptions.get_item_text(index))


func _on_generateButton_pressed():
	return
	
	if found == false:
		return
	
	dname = $editOptions/displayName/displayName.text
	if dname == "":
		_ready_to_generate = false
		$charaGenPopup.dialog_text = "You must give an non-empty display name."
		$charaGenPopup.popup_centered()
	else:
		_ready_to_generate = true
		$charaGenPopup.dialog_text = ("You are about to generate a character scene with uid: {0}" +\
		" display name: {1}, which will have the path: {2}.").format({0:cur_uid,1:dname,2:(chara_scdir+cur_uid+".tscn")})
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
			var t = load(chara_dir + temp_dict[ex])
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
		
		var sheetName = chara_scdir+cur_uid+"_expressionSheet.tres"
		var error = ResourceSaver.save(sheetName, expSheet)
		if error == OK:
			print("Character expression sheet saved.")
		else:
			print("Some error occurred when trying to save spriteSheet.")
		
		ch.name = cur_uid
		ch.set_sprite_frames(load(sheetName))
		ch.unique_id = cur_uid
		ch.display_name = dname
		ch.scale = Vector2($editOptions/main/xLabel/xScale.value, $editOptions/main/yLabel/yScale.value)
		packed_scene.pack(ch)
		error = ResourceSaver.save(chara_scdir+cur_uid+".tscn", packed_scene)
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
	if !dir.dir_exists(bg_dir):
		dir.make_dir_recursive(bg_dir)
	
	dir.open(bg_dir)
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
		which = "res://assets/actors/spritesheet/"
	else:
		which = chara_dir
		
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
