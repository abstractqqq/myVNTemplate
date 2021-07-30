extends generalDialog


#---------------------------------- Choices ---------------------------------------

#---------------------------------- Core Dialog ---------------------------------------
var main_block = [
	
	# start of content
	{"fadein": 1},
	{'chara': "gt join", "loc": "1600 650", "expression":""},
	{"gt": "Here we demonstrate how to do animations (spritesheet)."},
	{"gt": "You can look at the top left corner to see the events controlling everything."},
	{"express": "gt crya"},
	{"gt": "This baka is making me cry... ..."},
	{'gt': "Yes, animation is compatible with all other character actions likes shake and move."},
	{"chara": "gt shake"},
	{'wait': 2},
	{'gt default': "I see someone!"},
	{"express": "gt wavea"},
	{"chara": "gt jump"},
	{"chara": "gt move", "loc": "400 650"},
	{'gt': "So you see that some animations are repeating and some are not. This can be set in "+\
	"the scene of this character (In my case gt.tscn)."},
	{"gt": "Hey!"},
	{"gt stara": "Ahha isn't that... ..."},
	{'gt': "My favorite... ..."},
	{'fadeout':1},
	{"GDscene": vn.ending_scene_path}
	
	# end of content
]



#---------------------------------------------------------------------
# If you change the key word 'starter', you will have to go to generalDialog.gd
# and find start_scene, under if == 'new_game', change to blocks['starter'].
# Other key word you can change at will as long as you're refering to them correctly.
var conversation_blocks = {'starter' : main_block}

var choice_blocks = {}


#---------------------------------------------------------------------
func _ready():
	game.currentSaveDesc = "Animation Test"
	game.currentNodePath = get_tree().current_scene.filename
	get_tree().set_auto_accept_quit(false)
	start_scene(conversation_blocks, choice_blocks, game.load_instruction)
	
