extends generalDialog


#---------------------------------- Choices ---------------------------------------
var food_choices = [
	{'Sushi': {'dvar': "mo = mo-10"}},
	{'Ramen': {'then' : 'block2'}}
]

#---------------------------------- Core Dialog ---------------------------------------
var main_block = [
	
	# start of content
	{"bg": "condo.jpg"},
	{"fadein": 2},
	{'chara': "female join", "loc": "1600 600", "expression":""},
	{"female": "When you're switching scenes, many things disappear, and need to be reset. Music persists."},
	{'female smile1': 'Let me show you a cool new feature.'},
	{'female': "Suppose I am very confused now."},
	{'chara':'female add', 'path':'/GodetteVN/sfxScenes/questionMark.tscn','at':'head'},
	{'female':"If you look at the code, it says the special effect question mark should show up "+\
	"at 'head'."},
	{'female':'That means you can define points on your character and show special '+\
	"effects at those points."},
	{"female":"Currently, there is no way to save these effects, so the special effect should be "+\
	"temporary, like question marks, or blood bleeding, or other short flashy stuff."},
	{'female':'The special uid "all" can also be used here provided that all characters have the '+\
	"point defined."},
	{'female': "To see how this point 'head' is defined, you can go to female.tscn and see."},
	{'female': 'The idea is to create Node2D as subnodes, and rename them beginning with a _ .'},
	{'female': 'I believe that will add a lot room for customization, if you know how to make these '+\
	"special effects in Godot. (And don't forget to queuefree them.)"},
	{"female": "What should I eat today?", 'choice' : 'food', 'id':0},
	{"female": "When your game ends, do the following."},
	{"female": "Use a GDscene change to go back to your designated ending scene. In this demo, the ending "+\
	"scene will be the title screen. But don't forget to change it to your actual ending if you "+\
	"have one!"},
	{'side':'female_smile.png'},
	{"female": "Thank you so much for bearing with me!"},
	{"fadeout":2},
	{'bgm': ''},
	{"GDscene": vn.ending_scene_path}
	
	# end of content
]

var block2 = [
	{"female" : 'This is how you do a branching depending on choices.'},
	{"female" : 'And this is how you go back to the block before.'},
	{"female": "Please check the code for sample2."},
	{'then' : 'starter', 'target id' : 0}
]


#---------------------------------------------------------------------
# If you change the key word 'starter', you will have to go to generalDialog.gd
# and find start_scene, under if == 'new_game', change to blocks['starter'].
# Other key word you can change at will as long as you're refering to them correctly.
var conversation_blocks = {'starter' : main_block, 'block2' : block2}

var choice_blocks = {'food': food_choices}


#---------------------------------------------------------------------
func _ready():
	game.currentSaveDesc = scene_description
	game.currentNodePath = get_tree().current_scene.filename
	get_tree().set_auto_accept_quit(false)
	start_scene(conversation_blocks, choice_blocks, {}, game.load_instruction)
	
	
