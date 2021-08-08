extends generalDialog
#---------------------------------- Conditions ---------------------------------------
var conditions = {
	"money1": "mo > 50",
	"money2": "mo < 1000",
	"money3": "mo > 2000"
}

#---------------------------------- Choices ---------------------------------------
# This is called a choice block
var c1 = [
	{"Yes": {'then': 'b_leave'} },
	{"No": {'dvar': "le=0"}}
]


#---------------------------------- Core Dialog ---------------------------------------
# This is called a dialog block/conversation block
# Read the documentation to understand how the new condition field works.
var main_block = [
	{'bg': 'busstop.jpg', 'pixelate': 2},
	{'dvar': 'mo = (mo+50)*2'},
	{'chara': "female join", "loc": "1600 600"},
	{'female': "EEEEE", 'condition':[['money1', 'money2'], 'tt']},
	{'female': 'Hello there. Let me introduce you to the system.', 'voice': '001.wav'},
	{"chara": "female jump", "amount":800, "time":2},
	{"chara":"female spin", "sdir": -1, "time":2, "deg": 720, "type":"expo"},
	{"chara":"female move", "loc": Vector2(200,600), "time":2, 'type': "expo"},
	{'female smile1': 'To make this video smaller in size, there will be no music.'},
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
	{"female": "Wanna see something spooky?"},
	{"screen": "flashlight", 'scale': Vector2(1.5,1.5)},
	{"female": "Cool?"},
	{"female": "You can turn this off just like how you turn off tint."},
	{"screen": "off"},
	{'female': 'This is how you play your custom Godot special effect scenes.'},
	{'sfx': '/GodetteVN/sfxScenes/flash.tscn'},
	{"chara": "female jump", 'dir': 'up', 'time': 0.3, 'amount': 80},
	{'female': "That scared me."},
	{'chara' : 'test2 fadein', 'time':2, 'loc': Vector2(200,600)},
	{'test2' : "Hey."},
	{'female': 'Let us try out the NVL mode.'},
	{"test2 annoyed1" : "Can you let me say something?"},
	{"female": "Let's see NVL mode."},
	{'nvl': true},
	{'female': "I just said something."},
	{'female': "More more more more."},
	{"test2 angry": "This gal is not letting me speak..."},
	{'': 'This is the narrator speaking.'},
	{'': 'More more more more.'},
	{'': 'I know you have [mo] much money.'},
	{'nvl': false},
	{'female': 'Ok, enough of that nvl nonsense.'},
	{"test2 smile1" : "But NVL is good for long narration or setting the mood imo."},
	{'center': 'Hello?'},
	{'female': 'This is how you show centered text.'},
	{"test2" : "Let's shake."},
	{"chara": "all shake", "amount": 200, "time" : 1},
	{'female': "Let's make a choice. Should B leave?", 'choice': "choice_1", 'id':0},
	{'female': "You chose Yes right? (You're seeing this because you chose A.)", 'condition': 'le==1'},
	{'female': "You chose No right? (You're seeing this because you chose No.)", 'condition': 'le==0'},
	{'female smile2': "Now let's try switching (Godot) scenes."},
	{'female': "This is how you switch to another Godot scene."},
	{'GDscene' : '/GodetteVN/sampleScene2.tscn'}
]

var test_block = [
	{'bg': 'busstop.jpg', 'pixelate': 2},
	{'dvar': 'mo = 50'},
	{'chara': 'female join', 'loc': "1600 600", 'expression':''},
	{"female": "Hello World."}
]

var b_leave = [
	{'dvar': 'le=1'},
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
	start_scene(conversation_blocks, choice_blocks, conditions, game.load_instruction)
	
