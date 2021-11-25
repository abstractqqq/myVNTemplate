extends GeneralDialog
#---------------------------------- Choices ---------------------------------------
var food_choices = [
	{'Sushi': {'then':'b1'}},
	{'Ramen': {'then':'b2'}}
]

#---------------------------------- Dialogs ---------------------------------------
var main_block = [
	{"": "This is the narrator speaking."},
	{"": "What should I eat today?"},
	{'choice':'food', 'id':0},
	{"":'Thank you for trying out the system!'},
	{'GDscene': vn.ending_scene_path}
]

var b1_block = [
	{"":"I like sushi."},
	{'then':'starter', 'target id':0}
]

var b2_block = [
	{"":"I like Ramen."},
	{'then':'starter', 'target id':0}
]


#--------------------- Create Dialog, Choice, Condition blocks -----------------------------
var dialog_blocks = {'starter' : main_block, 'b1':b1_block,'b2':b2_block}

var choice_blocks = {'food': food_choices}

var cond_blocks = {
	
}

#---------------------------------------------------------------------
func _ready():
	start_scene(dialog_blocks, choice_blocks, cond_blocks)
