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
	{"female": "What should I eat today?", 'choice' : 'food', 'id':0},
	{"female": "When your game ends, do the following."},
	{"female": "Use a GDscene change to go back to your designated ending scene. In this demo, the ending "+\
	"scene will be the mainMenu scene. But don't forget to change it to your actual ending if you "+\
	"have one!"},
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
	game.currentSaveDesc = "Introduction to System 2"
	game.currentNodePath = get_tree().current_scene.filename
	get_tree().set_auto_accept_quit(false)
	start_scene(conversation_blocks, choice_blocks, {}, game.load_instruction)
	
