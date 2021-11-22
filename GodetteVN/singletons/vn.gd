extends Node

#-----------------

# Maybe these variables should be inside Project Settings in Godot?

# Constants
const max_history_size = 300 # Max number of history entries
const max_rollback_steps = 50 # Max steps of rollback to keep
# It is recommended that max_rollback_steps is kept to a small number.
const voice_to_history = true # Should voice be replayable in history?

# Do you want to use a different color for chosen choices? Only works
# if the scene is made spoilerproof.
const show_chosen_choices = true

# paths
const title_screen_path:String = "/GodetteVN/titleScreen.tscn"
const start_scene_path:String = '/GodetteVN/typicalVNScene.tscn'
const credit_scene_path:String = "" # if you have one
const ending_scene_path:String = "/GodetteVN/titleScreen.tscn" 
# by default, ending scene = go back to title



#-----------------

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
const SETTING_PATH:String = "res://GodetteVN/Core/SettingsScreen/settings.tscn"
const LOAD_PATH:String = "res://GodetteVN/Core/SNL/loadScreen.tscn"
const SAVE_PATH:String = "res://GodetteVN/Core/SNL/saveScreen.tscn"
const HIST_PATH:String = "res://GodetteVN/Core/HistoryScreen/historyScreen.tscn"
# Important small things
const DEFAULT_CHOICE:String = "res://GodetteVN/Core/choiceBar.tscn"
const DEFAULT_FLOAT:String = 'res://GodetteVN/Core/_Details/floatText.tscn'
const DEFAULT_NVL:String = "res://GodetteVN/Core/_Details/nvlBox.tscn"

# size of thumbnail on save slot. Has to manually adjust the TextureRect's size 
# in textBoxInHistory as well
const THUMBNAIL_WIDTH = 175
const THUMBNAIL_HEIGHT = 110
const ThumbnailFormat = Image.FORMAT_RGB8

# Encryption password used for saves
const PASSWORD = "nanithefuck"

# Dim color
const DIM = Color(0.86,0.86,0.86,1) # Dimming of non talking characters
const CENTER_DIM = Color(0.7,0.7,0.7,1) # Dimming in center mode
const NVL_DIM = Color(0.2,0.2,0.2,1) # Dimming in NVL mode

#Skip speed, multiple of 0.05
const SKIP_SPEED:int = 3 # 3 means 1 left-click per 3 * 0.05 = 0.15 s

# Transitions
const TRANSITIONS_DIR = "res://GodetteVN/Core/_Details/Transition_Data/"
const TRANSITIONS = ['fade','sweep_left','sweep_right','sweep_up','sweep_down',
	'curtain_left','curtain_right','pixelate','diagonal']
const PHYSICAL_TRANSITIONS = []

# Other constants used throughout the engine
const DIRECTION = {'up': Vector2.UP, 'down': Vector2.DOWN, 'left': Vector2.LEFT, 'right': Vector2.RIGHT}
# Bad names for dvar
const BAD_NAMES = ["nw", "nl", "sm", 'dc','color']
# Bad uids for characters
const BAD_UIDS = ['all', '']


# --------------------------- Game Experience Variables ------------------------

var auto_on:bool = false # Auto forward or not
var auto_bound = -1 # Initialize to -1. Will get changed in fileRelated.
# how many 0.05s do we need to wait if auto is on
# Formula ((-1)*auto_speed + 3.25)*20

# Default CPS
var cps : float = 50.0 # either 50 or 25
var cps_map = {'fast':50, 'slow':25, 'instant':0, 'slower':10}

# ---------------------------- Dvar Varibles ----------------------------
# VERY IMPORTANT
# PLEASE DO NOT NAME A DVAR THE SAME AS THE NAME OF ANY BBCODE!
# Also not "nw". Do not initialize dvar here. Use set_dvar method instead.

var dvar = {}
onready var Chs = get_node_or_null("Charas")
onready var Notifs = get_node_or_null("Notifs/Notification")
onready var Files = get_node_or_null("Files")
onready var Utils = get_node_or_null("Utils")
onready var Pgs = get_node_or_null("Progress")
onready var Pre = get_node_or_null("Preloaded")
var Scene = null


# ------------------------- Game State Variables--------------------------------
# Maybe I should move these variables to somewhere else?


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


#Deprecated
func error(message, ev = {}):
	if message == "p" or message == "path":
		message = "Path invalid."
	if message == 'dvar':
		message = "Dvar not found."
	
	if ev.size() != 0:
		message += "\n Possible error at event: " + str(ev)
			
	push_error(message)
	get_tree().quit()
	
func dvar_initialization():
	$Dvars.dvar_initialization()

func _ready():
	dvar_initialization()

