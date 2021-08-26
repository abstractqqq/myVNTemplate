extends GeneralDialog


# Typically you do not want to use any background change events in a parallax
# so you might as well hide the background node. (The parallax background is a
# complete independent thing. So all events like {bg: ..., fadein} will be pointless
# in a parallax scene. It is designed in this way because a parallax scene is 
# usually a separate scene in you game, so it should be a separate Godot scene
# as well. It makes organization cleaner. There is really no point in mixing
# parallax background and regular staic background in one Godot scene when you
# can easily switch from one to another.)
# 

# Another note: in order for parallax to be compatible with character actions,
# it is important to make your parallax bgs self-moving. This is because we
# do not want to make the camera, nor the character positions.

#---------------------------------- Core Dialog ---------------------------------------
var main_block = [
	
	# start of content
	{"screen":"fade out", 'time':1}, # fade out means out from dark to normal
	{'chara': "gt join", "loc": "1600 650"},
	{"gt": "Here we demonstrate parallax background and show that it is compatible with all character actions."},
	{"gt": "You can look at the top left corner to see the events controlling everything."},
	{"express": "gt crya"},
	{"gt": "This forest is a bit scary, isn't it?"},
	{"chara": "gt shake"},
	{'wait': 2},
	{'gt default': "I see someone!"},
	{"express": "gt wavea"},
	{"chara": "gt jump"},
	{"chara": "gt move", "loc": "1000 650"},
	{'gt': "But someone doesn't see me..."},
	{"gt": "Hey!"},
	{"gt stara": "LOLOLOL"},
	{'gt': "Let me do my signature jump!"},
	{"chara": "gt jump", "amount":800, "time":2},
	{"chara":"gt spin", "sdir": -1, "time":2, "deg": 720, "type":"expo"},
	{"chara":"gt move", "loc": Vector2(200,650), "time":2, 'type': "expo"},
	{"gt":"Thanks a lot to saukgp on itch who provides these parallax backgrounds for free!"},
	{'wait':3},
	{"screen":"fade in", 'time':1}, # fade in means fade into darkness
	{"GDscene": vn.ending_scene_path}
	# end of content
]



#---------------------------------------------------------------------
# Do not change the key word starter. It is necessary.
var conversation_blocks = {'starter' : main_block}

var choice_blocks = {}


#---------------------------------------------------------------------
func _ready():
	game.currentSaveDesc = scene_description
	game.currentNodePath = get_tree().current_scene.filename
	get_tree().set_auto_accept_quit(false)
	start_scene(conversation_blocks, choice_blocks, {}, game.load_instruction)
	
