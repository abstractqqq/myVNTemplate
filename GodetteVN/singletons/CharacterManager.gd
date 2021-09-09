extends Node

# name for this singleton in script is chara

var all_chara = {}

func _ready():
	# Define all your game characters here.
	
	# Characters have two classes
	# 1. Spriteless characters: characters who doesn't really have a
	# sprite, and will only do some talking. The narrator in every
	# VN is an example of a spriteless character.
	# 2. Stage characters: characters who have sprites, and players
	# will see their sprites. For stage characters, you need to use
	# {chara : uid join , loc : 1600 600}
	# before they can be shown on stage.
	
	
	# To define a spriteless character, you do:
	spriteless_character("", "") 
	# This is the narrator. Do not delete this line.
	# Format: (display_name, unique_id, Color (optional))
	# Color should be declared as color in Godot, for instance
	# Color(0,1,0) = Green
	
	spriteless_character("", "vo")
	
	# Here you define character with sprites, they must have a 
	# Godot scene in the folder GodetteVN/Characters with the name
	# uid.tscn 
	stage_character("female")
	stage_character("test2")
	stage_character("gt") # register your character so that the system knows
	# which uid to look for
	
	# You may initialize your variables here
	#'mo':50, 'le':0, 'tt': true
	set_dvar("mo", 50)
	set_dvar("le",0)
	set_dvar("tt", true)
	set_dvar("parallax_speed", -25)
	
	# Suppose for vo, we do not want name box at all 
	# (no name display + no namebox texture)
	set_noname("vo")
	
	# Used in clickable test
	set_dvar('obj1', false)
	set_dvar('obj2', false)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
#----------------------------------------------------------------------------

# Keep a record of the path to the scene of the stage character
func stage_character(uid:String) -> void:
	if uid in vn.BAD_UIDS:
		if uid == "":
			vn.error("The empty string uid is preserved for the narrator." % [uid])
		else:
			vn.error("The uid %s is not allowed." % [uid])
	
	var path = vn.CHARA_SCDIR+uid+".tscn"
	var ch_scene = load(path)
	if ch_scene == null:
		vn.error("The character scene cannot be found.")
	var c = ch_scene.instance()
	var info = {"uid":c.unique_id,"display_name":c.display_name,"name_color":c.name_color,"path":path}
	if c.use_character_font:
		info['font'] = true
		info['normal_font'] = c.normal_font
		info['italics_font'] = c.italics_font
		info['bold_font'] = c.bold_font
		info['bold_italics_font'] = c.bold_italics_font
	else:
		info['font'] = false
	
	all_chara[uid] = info
	c.call_deferred('free')

# Difference is that stage character also has a path field.

func spriteless_character(dname:String, uid:String, color=Color(0,0,0,1))->void:
	if uid in vn.BAD_UIDS:
		if uid != "":
			vn.error("The uid %s is not allowed." % [uid])
		else:
			if all_chara.has(""):
				vn.error("The empty string uid is preserved for the narrator." % [uid])
		
	all_chara[uid] = {"uid":uid, "display_name":dname, "name_color":color, 'font':false}

func get_character_info(uid:String):
	if all_chara.has(uid):
		return all_chara[uid]
	else:
		vn.error("No character with this uid %s is found" % uid )

func set_dvar(v:String, value):
	if not v.is_valid_identifier():
		push_error("A valid dvar name should only contain letters, digits, and underscores and the "+\
		"first character should not be a digit.")
	
	for bad in vn.BAD_NAMES:
		if bad == v:
			push_error("The name %s cannot be used as a dvar name." % [bad])
	
	if "%" in v:
		push_error("The percentage sign % is not allowed in the name of your dvar.")
		
	vn.dvar[v] = value
	print("Successfully set %s to value %s." % [v, value])
	
func set_noname(uid:String):
	if all_chara.has(uid):
		all_chara[uid]['no_nb'] = true
	else:
		push_error("The uid %s has not been regiestered when this line is executed. Might also be a typo." % [uid])
