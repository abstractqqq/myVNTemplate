extends generalDialog


#---------------------------------- Choices ---------------------------------------
var food_choice = []


#---------------------------------- Core Dialog ---------------------------------------
var main_block = [
	{'bg': 'busstop.jpg'},
	{'dvar': 'money = 50'},
	{'chara': 'female join', 'loc': "1600 600", 'expression':''},
	{'female': 'Hello there. Let me introduce you to the system.'},
	{'female': 'This is how you show basic float text.'},
	{'float': 'Hello World', 'wait': 1, 'time': 4, 'loc': '600 300'},
	{'float': 'Hello World2', 'wait': 1, 'time': 4, 'loc': '600 400'},
	{'female': 'Let me zoom the camera'},
	{'camera': 'zoom', 'time':1, 'loc': "100 200", 'scale': '0.5 0.5'},
	{'female': 'Let me move the camera'},
	{'camera': 'move', 'time':1, 'loc': "1200 200", 'type': 'quad'},
	{'female': 'Now reset.'},
	{'camera': 'reset'},
	{'female': "Let's get moving!"},
	{'chara': "female move", "type": "cubic", "loc": "600 600", "time": 1},
	{'female': 'Let it rain.'},
	{'weather': 'rain'},
	{'chara' : 'test2 fadein', 'time':2, 'loc': '300 600', 'expression':''},
	{'test2' : "Hey."},
	{'female': 'Let us try out the NVL mode.'},
	{'nvl': 'true'},
	{'female': "I just said something."},
	{'female': "More more more more."},
	{'': 'This is the narrator speaking.'},
	{'': 'More more more more.'},
	{'': 'I know you have [money] much money.'},
	{'nvl': 'false'},
	{'female': 'Ok, enough of that nvl nonsense.'},
	{'center': 'Hello?'},
	{'female': 'This is how you show centered text.'},
	{'history': 'push', '': 'THIS IS SUPPOSED TO BE SECRET!'},
	{'female': 'This is how you add secret text to history.'},
	{'history': 'pop'},
	{'female': "This is how you remove the last entry in history."},
	{'bgm':'myuu-angels.mp3'},
	{'female': 'This is how you play music.'},
	{'female': "This is how you switch to another Godot scene."},
	{'GDscene' : '/scenes/sampleScene2.tscn'}
	
]


#---------------------------------------------------------------------
# If you change the key word 'starter', you will have to go to generalDialog.gd
# and find start_scene, under if == 'new_game', change to blocks['starter'].
# Other key word you can change at will as long as you're refering to them correctly.
var conversation_blocks = {'starter' : main_block}

var choice_blocks = {}


#---------------------------------------------------------------------
func _ready():
	game.currentNodePath = get_tree().current_scene.filename
	get_tree().set_auto_accept_quit(false)
	start_scene(conversation_blocks, choice_blocks, game.load_instruction)
	
