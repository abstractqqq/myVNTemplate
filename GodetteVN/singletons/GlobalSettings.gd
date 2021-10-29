extends Node

# Constants
const max_history_size = 300 # Max number of history entries
const max_rollback_steps = 50 # Max steps of rollback to keep
# It is recommended that max_rollback_steps is kept to a small number.
const voice_to_history = true # Should voice be replayable in history?


# Narrator
const narrator_display_name:String = ''
# paths
const title_screen_path:String = "/GodetteVN/titleScreen.tscn"
const start_scene_path:String = '/GodetteVN/typicalVNScene.tscn'
const credit_scene_path:String = "" # if you have one
const ending_scene_path:String = "/GodetteVN/titleScreen.tscn" 
# by default, ending scene = go back to title

# Directories will contain res:/ part, paths above won't, paths below
# will have full paths.

# default directories
const ROOT_DIR:String = "res:/"
const VOICE_DIR:String = "res://voice/"
const BGM_DIR:String = "res://bgm/"
const AUDIO_DIR:String = "res://audio/"
const BG_DIR:String = "res://assets/backgrounds/"
const CHARA_DIR:String = "res://assets/actors/"
const CHARA_SCDIR:String = "res://GodetteVN/Characters/"
const CHARA_ANIM:String = "res://assets/actors/spritesheet/"
const SIDE_IMAGE:String = "res://assets/sideImages/"
const SAVE_DIR:String = "user://save/"
const SCRIPT_DIR:String = "res://VNScript/"
const THUMBNAIL_DIR:String = "user://temp/"
const FONT_DIR:String = "res://fonts/"
# Important screen paths
const SETTING_PATH:String = "res://GodetteVN/fundamentals/settings.tscn"
const LOAD_PATH:String = "res://GodetteVN/fundamentals/loadScreen.tscn"
const SAVE_PATH:String = "res://GodetteVN/fundamentals/saveScreen.tscn"
const HIST_PATH:String = "res://GodetteVN/fundamentals/historyScreen.tscn"
# Important small things
const SAVESLOT:String = "res://GodetteVN/fundamentals/details/saveSlot.tscn"
const DEFAULT_CHOICE:String = "res://GodetteVN/fundamentals/choiceBar.tscn"
const DEFAULT_FLOAT:String = 'res://GodetteVN/fundamentals/details/floatText.tscn'
const DEFAULT_NVL:String = "res://GodetteVN/fundamentals/details/nvlBox.tscn"

# size of thumbnail on save slot. Has to manually adjust the TextureRect's size 
# in textBoxInHistory as well
const THUMBNAIL_WIDTH = 175
const THUMBNAIL_HEIGHT = 110
# If you change these values, then there is a chance that there will be a bug
# when loading saves. In that case, you probably want to look into currentFormat in
# GameProgress.gd. It has somethign to do with the format of the image file that is 
# saved in your game save.

# Encryption password used for saves
const PASSWORD = "nanithefuck"

# Dim color
const DIM = Color(0.86,0.86,0.86,1) # Dimming of non talking characters
const CENTER_DIM = Color(0.7,0.7,0.7,1) # Dimming in center mode
const NVL_DIM = Color(0.2,0.2,0.2,1) # Dimming in NVL mode

#Skip speed, multiple of 0.05
const SKIP_SPEED:int = 3 # means skip is 1 left-click per 2 * 0.05 = 0.1 s

# Transitions
const TRANSITIONS_DIR = "res://GodetteVN/fundamentals/details/transitions_data/"
const TRANSITIONS = ['fade','sweep_left','sweep_right','sweep_up','sweep_down',
	'curtain_left','curtain_right','pixelate','diagonal']
const PHYSICAL_TRANSITIONS = []

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

# DO NOT CHANGE THIS VAR
var cps : int = 50 # either 50 or 25
# cps correspondence = {fast:50, slow:25, instant:0, slower:10}

# ---------------------------- Dvar Varibles ----------------------------
# VERY IMPORTANT
# PLEASE DO NOT NAME A DVAR THE SAME AS THE NAME OF ANY BBCODE!
# Also not "nw". Do not initialize dvar here. Use set_dvar method instead.

var dvar = {}

# ------------------------- Game State Variables--------------------------------

# Special game state variables
var inLoading = false # Is the game being loaded from the save now? (Only used
# in the load system and in the rollback system.)

var inNotif = false # Is there a notification?

var inSetting = false # Is the player in an external menu? Setting/history/save/load
# / your menu

var noMouse = false # Used when your mouse hovers over buttons on quickmenu
# When you click the quickmenu button, because noMouse is turned on, the same
# click will not register as 'continue dialog'.
# This is important when you do scenes like an investigation where players will
# click different objects.

var skipping = false # Is the player skipping right now?

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

#Deprecated
func error(message, ev = {}):
	if message == "p" or message == "path":
		message = "Path invalid."
	if message == 'dvar':
		message = "Dvar not found."
	
	if ev.size() != 0:
		message += "\n Possible error at event: " + str(ev)
			
	push_error(message)
	get_tree().quit() # If I can get rid of this function, then I do not need to extend 
	# from node.

#------------------------------------------------------------------------------------
# Private
#------------------------------------------------------------------------------------
