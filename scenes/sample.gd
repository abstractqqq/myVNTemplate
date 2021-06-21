extends generalDialog


#---------------------------------- Choices ---------------------------------------
var food_choice = []


#---------------------------------- Core Dialog ---------------------------------------
var main_block = fileRelated.load_json("test.json")


#---------------------------------------------------------------------
# If you change the key word 'starter', you will have to go to generalDialog.gd
# and find start_scene, under if == 'new_game', change to blocks['starter'].
# Other key word you can change at will as long as you're refering to them correctly.
var conversation_blocks = {'starter' : main_block}

var choice_blocks = {}


#---------------------------------------------------------------------
func _ready():
	print(main_block)
	game.currentNodePath = get_tree().current_scene.filename
	get_tree().set_auto_accept_quit(false)
	start_scene(conversation_blocks, choice_blocks, game.load_instruction)
	
