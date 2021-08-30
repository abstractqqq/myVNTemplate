extends Node

# Constants

# History and rollback
const max_dialog_display:int = 200 # only display 200 history entries
const max_rollback_steps:int = 100 # allow users to rollback at most this num of steps

# Narrator
const narrator_display_name:String = ''
# paths
const title_screen_path:String = "/GodetteVN/titleScreen.tscn"
const start_scene_path:String = '/GodetteVN/typicalVNScene.tscn'
const credit_scene_path:String = "" # if you have one
const ending_scene_path:String = "/GodetteVN/titleScreen.tscn" # by default, ending scene = go back to main
#

# default directories
const ROOT_DIR:String = "res:/"
const VOICE_DIR:String = "res://voice/"
const BGM_DIR:String = "res://bgm/"
const AUDIO_DIR:String = "res://audio/"
const BG_DIR:String = "res://assets/background/"
const CHARA_DIR:String = "res://assets/actors/"
const CHARA_SCDIR:String = "res://GodetteVN/Characters/"
const CHARA_ANIM:String = "res://assets/actors/spritesheet/"
const SIDE_IMAGE:String = "res://assets/sideImage/"
const SAVE_DIR:String = "user://save/"
const SCRIPT_DIR:String = "res://VNScript/"
const THUMBNAIL_DIR:String = "user://temp/"
const FONT_DIR:String = "res://fonts/"
# Important screen paths
const SETTING_PATH:String = "res://GodetteVN/fundamentals/settings.tscn"
const LOAD_PATH:String = "res://GodetteVN/fundamentals/loadScreen.tscn"
const SAVE_PATH:String = "res://GodetteVN/fundamentals/saveScreen.tscn"
const SAVESLOT:String = "res://GodetteVN/fundamentals/details/saveSlot.tscn"
const HIST_PATH:String = "res://GodetteVN/fundamentals/historyScreen.tscn"
# Important small things
const DEFAULT_CHOICE:String = "res://GodetteVN/fundamentals/choiceBar.tscn"
const DEFAULT_FLOAT:String = 'res://GodetteVN/fundamentals/details/floatText.tscn'
const DEFAULT_NVL:String = "res://GodetteVN/fundamentals/details/nvlBox.tscn"
# size of thumbnail on save slot. Has to manually adjust the TextureRect's size 
# in textBoxInHistory as well
const THUMBNAIL_WIDTH = 175
const THUMBNAIL_HEIGHT = 110
# Encryption password used for saves
const PASSWORD = "nanithefuck"


# Dim color
const DIM = Color(0.86,0.86,0.86,1)
const CENTER_DIM = Color(0.7,0.7,0.7,1)
const NVL_DIM = Color(0.2,0.2,0.2,1)

#Skip speed, multiple of 0.05
const SKIP_SPEED:int = 2 # means skip is 1 left-click per 0.1s

# Transitions
const TRANSITIONS_DIR = "res://GodetteVN/fundamentals/details/transitions_data/"
const TRANSITIONS = ['fade','sweep_left','sweep_right','sweep_up','sweep_down',
	'curtain_left','curtain_right','circular_close','circular_open','pixelate']

# Other constants used throughout the engine
const DIRECTION = {'up': Vector2.UP, 'down': Vector2.DOWN, 'left': Vector2.LEFT, 'right': Vector2.RIGHT}
# Bad names for dvar
const BAD_NAMES = ["nw", "nl", "sm", 'dc','color']
# Bad uids for characters
const BAD_UIDS = ['all', '']

# Preloaded Scenes (must be used often)
var MAIN_MENU = preload("res://GodetteVN/fundamentals/mainMenu.tscn")


# --------------------------- Game Experience Variables ------------------------

var auto_on:bool = false # Auto forward or not
var auto_bound = -1 # Initialize to -1. Will get changed in fileRelated.
# how many 0.05s do we need to wait if auto is on
# Formula ((-1)*auto_speed + 3.25)*20

var cps : int = 50 # either 50 or 25
# cps correspondence = {fast:50, slow:25, instant:0, slower:10}

# ---------------------------- Dvar Varibles ----------------------------
# VERY IMPORTANT
# PLEASE DO NOT NAME A DVAR THE SAME AS THE NAME OF ANY BBCODE!
# Also not "nw". Do not initialize dvar here. Use set_dvar method instead.

var dvar = {}

# ------------------------- Game State Variables--------------------------------

# Special game state variables, don't need to save.
var inLoading = false
var inNotif = false
var inSetting = false
var noMouse = false
var skipping = false

func reset_states():
	inLoading = false
	inNotif = false
	inSetting = false
	noMouse = false
	skipping = false
	auto_on = false
	
#--------------------------------------------------------------------------------
func set_dvar(v:String, value):
	if not v.is_valid_identifier():
		vn.error("A valid dvar name should only contain letters, digits, and underscores and the "+\
		"first character should not be a digit.")
	
	for bad in vn.BAD_NAMES:
		if bad == v:
			vn.error("The name %s cannot be used as a dvar name." % [bad])
		
	vn.dvar[v] = value
	print("Successfully set %s to value %s." % [v, value])


func error(message, ev = {}):
	if message == "p" or message == "path":
		message = "Path invalid."
	if message == 'dvar':
		message = "Dvar not found."
	
	if ev.size() != 0:
		message += "\n Possible error at event: " + str(ev)
			
	push_error(message)
	get_tree().quit()
