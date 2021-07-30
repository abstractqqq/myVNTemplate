extends generalDialog


#---------------------------------- Choices ---------------------------------------
# This is called a choice block
var c1 = [
	{"Yes": {'then': 'b_leave'} },
	{"No": {'dvar': "leave=0"}}
]


#---------------------------------- Core Dialog ---------------------------------------
# This is called a dialog block/conversation block
var main_block = [
	{'bg': 'busstop.jpg', 'pixelate': 2},
	{'dvar': 'money = (money+50)*2'},
	{'chara': "female join", "loc": "1600 600"},
	{'female': 'Hello there. Let me introduce you to the system.', 'voice': '001.wav'},
	{'bgm':'myuu-angels.mp3', 'fadein': 3},
	{'female smile1': 'Music start'},
	{'female': "Let me hide the quick menu for a second"},
	{'system': 'quick_menu off'},
	{'female': 'It is gone. Now let me make it visible again.'},
	{'system': 'quick_menu on'},
	{'female': 'This is how you show basic floating text.'},
	{'float': '[color=#ff0000]Hello World1[/color]', 'wait': 1, 'time': 4, 'loc': '600 300', 'fadein': 0.5,\
	"font": "res://fonts/ARegular.tres"},
	{'float': '[color=#ff0000]Hello World2[/color]', 'wait': 1, 'time': 4, 'loc': '600 400', 'fadein': 1},
	{'female': "Let me tint the screen."},
	{'screen': 'tint', 'color': Color(0,1,0,0.5), 'time':2},
	{'female': "Cool?"},
	{'female': "You can turn screen tint off like this."},
	{'screen': ''},
	{'female': 'Let me zoom the camera'},
	{'camera': 'zoom', 'time':1, 'loc': Vector2(100,200), 'scale': '0.5 0.5'},
	{'female': 'Let me move the camera'},
	{'camera': 'move', 'time':1, 'loc': Vector2(800,200), 'type': 'quad'},
	{'female': 'Now reset.'},
	{'camera': 'reset'},
	{'female': "Let's get moving!"},
	{'chara': "female move", "type": "cubic", "loc": Vector2(600,600), "time": 1},
	{'female': 'Let it rain.'},
	{'weather': 'rain'},
	{"female": "If you want you can disable save and load and this is how."},
	{"system": "save_load off"},
	{"female": "I guess sometimes for special occasions you don't want the player to save, "+\
	"but you still need the quickmenu."},
	{"female": "Ok to enable save and load again simply replace off by on."},
	{"system": "save_load on"},
	{"female": "Wanna see something spooky?"},
	{"screen": "flashlight", 'scale': Vector2(1.5,1.5)},
	{"female": "Cool?"},
	{"female": "You can turn this off just like how you turn off tint."},
	{"screen": "off"},
	{'female': 'This is how you play your custom Godot special effect scenes.'},
	{'sfx': '/GodetteVN/sfxScenes/flash.tscn'},
	{"chara": "female jump", 'dir': 'up', 'time': 0.3, 'amount': 80},
	{'female': "That scared me."},
	{'chara' : 'test2 fadein', 'time':2, 'loc': Vector2(200,600), 'expression':''},
	{'test2' : "Hey."},
	{'female': 'Let us try out the NVL mode.'},
	{"test2 annoyed1" : "Can you let me say something?"},
	{"female": "Let's see NVL mode."},
	{'nvl': true},
	{'female': "I just said something."},
	{'female': "More more more more."},
	{"test2 annoyed2": "This gal is not letting me speak..."},
	{'': 'This is the narrator speaking.'},
	{'': 'More more more more.'},
	{'': 'I know you have [money] much money.'},
	{'nvl': false},
	{'female': 'Ok, enough of that nvl nonsense.'},
	{"test2 smile1" : "But NVL is good for long narration or setting the mood imo."},
	{'center': 'Hello?'},
	{'female': 'This is how you show centered text.'},
	{'history': 'push', '': 'THIS IS SUPPOSED TO BE SECRET!'},
	{'female': 'This is how you add secret text to history.'},
	{'history': 'pop'},
	{'female': "This is how you remove the last entry in history."},
	{"test2" : "Let's shake."},
	{"chara": "all shake", "amount": 200, "time" : 1},
	{'female': "Let's make a choice. Should B leave?", 'choice': "choice_1", 'id':0},
	{'female': "You chose Yes right? (You're seeing this because you chose A.)", 'condition': "leave=1"},
	{'female': "You chose No right? (You're seeing this because you chose No.)", 'condition': "leave=0"},
	{'female smile2': "Now let's try switching (Godot) scenes."},
	{'female': "This is how you switch to another Godot scene."},
	{'GDscene' : '/GodetteVN/sampleScene2.tscn'}
]

var test_block = [
	{'bg': 'busstop.jpg', 'pixelate': 2},
	{'dvar': 'money = 50'},
	{'chara': 'female join', 'loc': "1600 600", 'expression':''},
	{"female": "Hello World."}
]

var b_leave = [
	{'dvar': 'leave=1'},
	{'test2': "Fine, I will leave."},
	{"chara": "test2 fadeout", 'time':2},
	{'then': "starter", 'target id': 0}
]

#---------------------------------------------------------------------
# If you change the key word 'starter', you will have to go to generalDialog.gd
# and find start_scene, under if == 'new_game', change to blocks['starter'].
# Other key word you can change at will as long as you're refering to them correctly.
var conversation_blocks = {'starter' : main_block, 'b_leave': b_leave}

var choice_blocks = {'choice_1' : c1}


#---------------------------------------------------------------------
func _ready():
	game.currentSaveDesc = "Introduction to System 1"
	game.currentNodePath = get_tree().current_scene.filename
	get_tree().set_auto_accept_quit(false)
	start_scene(conversation_blocks, choice_blocks, game.load_instruction)
	
