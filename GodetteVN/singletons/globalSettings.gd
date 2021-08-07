extends Node

# Constants

# dialog
const max_dialog = 500 # might remove this constant later.
var max_dialog_display = 300 # only display 300. 
# If I allow user to change
# the max number to display, change this number, and max_dialog will be the 
# absolute max.

# Narrator
const narrator_display_name = ''
# paths
const main_menu_path = "/GodetteVN/mainMenu.tscn"
const start_scene_path = "/GodetteVN/sampleScene.tscn"
const credit_scene_path = "" # if you have one
const ending_scene_path = "/GodetteVN/mainMenu.tscn" # by default, ending scene = go back to main
# 

# default directories
const ROOT_DIR = "res:/"
const VOICE_DIR = "res://voice/"
const BGM_DIR = "res://bgm/"
const AUDIO_DIR = "res://audio/"
const BG_DIR = "res://assets/background/"
const CHARA_DIR = "res://assets/actors/"
const CHARA_SCDIR = "res://GodetteVN/Characters/"
const CHARA_ANIM = "res://assets/actors/spritesheet/"
const CHARA_SIDE = "res://assets/actors/sideImage/"
const SAVE_DIR = "user://save/"
const SCRIPT_DIR = "res://VNScript/"
const THUMBNAIL_DIR = "user://temp/"
const FONT_DIR = "res://fonts/"
# Import screen paths
const SETTING_PATH = "res://GodetteVN/fundamentals/settings.tscn"
const LOAD_PATH = "res://GodetteVN/fundamentals/loadScreen.tscn"
const SAVE_PATH = "res://GodetteVN/fundamentals/saveScreen.tscn"
const SAVESLOT = "res://GodetteVN/fundamentals/details/saveSlot.tscn"
const HIST_PATH = "res://GodetteVN/fundamentals/historyScreen.tscn"


# size of thumbnail on save slot. Has to manually adjust the TextureRect's size as well
const THUMBNAIL_WIDTH = 175
const THUMBNAIL_HEIGHT = 110
# Encryption password used for saves
const PASSWORD = "nanithefuck"

# Should float text be recorded in history?
const FLOAT_HIS = false

# Dim color
const DIM = Color(0.86,0.86,0.86,1)
const CENTER_DIM = Color(0.7,0.7,0.7,1)
const NVL_DIM = Color(0.2,0.2,0.2,1)

# Other constants used throught the engine
const DIRECTION = {'up': Vector2.UP, 'down': Vector2.DOWN, 'left': Vector2.LEFT, 'right': Vector2.RIGHT}

# Preloaded Scenes (must be used often)
# var ALL_IN_ONE = preload("res://GodetteVN/fundamentals/optionalScreens/allInOneScreen.tscn")


# --------------------------- Game Experience Variables ------------------------
# can be changed in game
var music_volume : float = 0 # the default initial value on the BGM audio bus
var effect_volume : float = 0 # for sound effect
var voice_volume: float = 0 # for voice acting
var auto_on = false # Auto forward or not
var auto_speed: int = 1 # Auto forward speed
# 0 = slow: after all text is shown on screen, forward to next in 6s
# 1 = Normal: after all text is shown on screen, forward to next in 4s
# 2 = fast: after all text is shown on screen, forward to next in 2s
var auto_bound = ((-1)*auto_speed + 3.25)*20 # how many 0.05s do we need to wait if auto is on
# Formula ((-1)*auto_speed + 3.25)*20

var cps : int = 50 # either 50 or 25
# cps correspondence = {fast:50, slow:25, instant:0, slower:10}

# ---------------------------- Dvar Varibles ----------------------------
# VERY IMPORTANT
# PLEASE DO NOT NAME A DVAR THE SAME AS THE NAME OF ANY BBCODE!
# Also not "nw"

var dvar = {'mo':50, 'le':0, 'tt': true}

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
		
func error(message, ev = {}):
	if message == "p" or message == "path":
		message = "Path invalid."
	if message == 'dvar':
		message = "Dvar not found."
	
	if ev.size() != 0:
		message += "\n Possible error at event: " + str(ev)
			

	push_error(message)
	get_tree().quit()
