extends generalDialog


#---------------------------------- Choices ---------------------------------------
var food_choices = [
	{'Sushi': {'dvar': "mo = mo-10"}},
	{'Fried Rice': {'then' : 'block2'}}
]

#---------------------------------- Core Dialog ---------------------------------------
var main_block = [
	
	# start of content
	{"bg": "condo.jpg"},
	{"fadein": 2},
	{'chara': "female join", "loc": "1600 600", "expression":""},
	{"female": "Let me show you how to do a timed choice in this example."},
	
	# optional, useful when you want to turn off quickmenu
	{"sys":"auto_save"}, # make an auto_save, this should be used immediately after
	# a dialog only!!!
	
	# optional
	{"sys":"QM off"}, # hide quick menu to prevent player from saving during a timed choice
	
	# passing a Godot variable like this only works when your sfx scene has a variable 
	# called params
	{'sfx':"/GodetteVN/sfxScenes/timedChoice.tscn",'params':5},
	{"female": "What should I eat today?", 'choice' : 'food', 'id':0},
	{'sys':'QM on'}, # if sushi is chosen, QM is still on, so turn this on
	# if out of time, then QM is turned on in out_of_time block, same with fried rice.
	 
	{"female": "It's quite easy, right?"},
	{"female": "There are some technical details you need to consider, like whether you should disable save or hide quick menu."},
	{"female":"But otherwise, it is pretty straight forward."},
	{"female":"Thank you."},
	{"fadeout":2},
	{'bgm': ''},
	{"GDscene": vn.ending_scene_path}
	
	# end of content
]

var block2 = [
	{'sys':'QM on'},
	{"female" : 'This is how you do a branching depending on choices.'},
	{"female" : 'And this is how you go back to the block before.'},
	{"female": "Please check the code for details."},
	{'then' : 'starter', 'target id' : 0}
]

# out of time
var block3 = [
	{'sys':'QM on'},
	{"female" : "It's taking me too much time to decide."},
	{"female" : 'Whatever... ... I will just cook ramen at home.'},
	{'then' : 'starter', 'target id' : 0}
]


#---------------------------------------------------------------------
# If you change the key word 'starter', you will have to go to generalDialog.gd
# and find start_scene, under if == 'new_game', change to blocks['starter'].
# Other key word you can change at will as long as you're refering to them correctly.
var conversation_blocks = {'starter' : main_block, 'block2' : block2, 'out_of_time':block3}

var choice_blocks = {'food': food_choices}


#---------------------------------------------------------------------
func _ready():
	game.currentSaveDesc = scene_description
	game.currentNodePath = get_tree().current_scene.filename
	get_tree().set_auto_accept_quit(false)
	start_scene(conversation_blocks, choice_blocks, {}, game.load_instruction)
	
	
