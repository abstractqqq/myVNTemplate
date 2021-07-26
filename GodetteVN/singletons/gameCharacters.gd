extends Node

var all_chara = {}

func _ready():
	# Define all your game characters here.
	
	# Characters have two classes
	# 1. Spriteless characters: characters who doesn't really have a
	# sprite, and will only do some talking. The narrator in every
	# VN is an example of a spriteless character.
	# 2. Stage characters: characters who have sprites, and players
	# will see their sprites. For stage characters, you need to use
	# {chara: uid join , loc : ..., expression: } 
	# before they can be shown on stage.
	
	# To define a spriteless character, you do:
	spriteless_character("", "")
	# Format: (display_name, unique_id, Color (optional))
	# Color should be declared as color in Godot, for instance
	# Color(0,1,0) = Green
	
	
	# Here you define character with sprites, they must have a 
	# Godot scene in the folder GodetteVN/Characters with the name
	# uid.tscn 
	stage_character("female")
	stage_character("test2")
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
#----------------------------------------------------------------------------

# Keep a record of the path to the scene of the stage character
func stage_character(uid:String) -> void:
	all_chara[uid] = vn.CHARA_SCDIR+uid+".tscn"

func spriteless_character(dname:String, uid:String, color=Color(0,0,0,1))->void:
	all_chara[uid] = {"uid":uid, "display_name":dname, "name_color":color}
