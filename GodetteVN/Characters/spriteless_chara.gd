extends Node
class_name spriteless_chara

var unique_id = ""
var display_name = ""
var name_color = Color()

func _init(dname:String, uid:String, c = Color(0,0,0,1)):
	unique_id = uid
	display_name = dname
	name_color = c
	chara.all_chara[uid] = "spriteless"
