extends Node

# name for this singleton in script is chara

var all_chara = {
	# Narrator
	"":{"uid":'', "display_name":"","name_color":Color(0,0,0,1),'font':false}
}


var chara_pointer = {}
var chara_name_patch = {}
#--------------------------------------------------------------------



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
	# spriteless_character("", "") 
	# This is the narrator. Notice the narrator is already defined in
	# all_chara dictionary. So there is no need to do so again.
	# Characters like the narrator are called 'pre-existing' characters
	# because you do not need to declare them. Currently there is no
	# difference between pre-existing and declared characters.
	# If you know what are the necessary fields for a character,
	# then you're welcomed to do whatever you want.
	
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
#BREAK
# Do not delete this break line
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


# Use case of point_uid_to
# Suppose you have prepared a male ver and female ver of your protagonist's
# character. The character scenes are named a.tscn and b.tscn, and male
# has uid a, and female has uid b.
# In your dialog script, you want to only use a.  
# Before the first VN scenes starts, you ask the player to choose
# male or female. Once the choice is given, in that script, you can call
# chara.point_uid_to("a", "b")
# From this point on, if you have a line like 
# a happy: "Hello!"
# It will be interpreted as b happy: "Hello!"
# This works with save system, and will be different depending on the player's
# choice in each save.
func point_uid_to(uid:String, to:String):
	chara_pointer[uid] = to
	
func forward_uid(uid:String):
	if chara_pointer.has(uid):
		return chara_pointer[uid]
	else:
		return uid
#------------------------------------------------------------------------

# Hide the name box when the character is speaking. 
func set_noname(uid:String):
	if all_chara.has(uid):
		all_chara[uid]['no_nb'] = true
	else:
		push_error("The uid %s has not been regiestered when this line is executed. Might also be a typo." % [uid])

# set a new display name for a character
# Warning: there is no problem if this change happens before the very
# first dialog. However, if chara a with display name a says something 
# in a dialog, and a's display name is changed to aa later by code, 
# then in history, ALL a in the name slot will be replaced by aa.

# There are some workarounds for this issue. If you want one character
# with two names, you can simply use a different uid to refer to 
# the other version of the same character with a duplicated character 
# scene and change their display name and uids there.

func set_new_display_name(uid:String, new_dname:String):
	if all_chara.has(uid):
		all_chara[uid]['display_name'] = new_dname
		chara_name_patch[uid] = new_dname
	else:
		push_error("The uid %s has not been regiestered when this line is executed. Might also be a typo." % [uid])
		
func patch_display_names():
	# after loading a save, if chara_name_patch is non empty, then this
	# will be run
	if chara_name_patch.size()>0:
		for uid in chara_name_patch.keys():
			set_new_display_name(uid,chara_name_patch[uid])
