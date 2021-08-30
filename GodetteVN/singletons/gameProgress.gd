extends Node

#----------------------------------Important------------------------------------
# 
#-------------------------------------------------------------------------------
#
# 
var currentNodePath = null

# Current time line 
var currentBlock = null

# Current index in the block
var currentIndex = null

# Current save description, if there is one
var currentSaveDesc = ""


#---------------------------------Important-------------------------------------

# Playback/lasting events are defined as events that should be remembered when loading
# back from a save. 

# If player saves in the middle of nvl mode,
# then when loading back, we need to restore all the nvl text.
var nvl_text = ''


var playback_events = {'bg':{'bg':''}, 'bgm':{'bgm':''}, 'charas':[], 'nvl': '','speech':''}

func get_latest_onstage():
	playback_events['charas'] = stage.all_on_stage()

func get_latest_nvl():
	playback_events['nvl'] = nvl_text


#-------------------------------------------------------------------------------
# "new_game" = start from new
# "load_game" = start from time line and index
var load_instruction = "new_game"
#-------------------------------------------------------------------------------


# Do not touch unless you will change the current save and load system, 
# This is only used in the process of save and load and 
# has something to do with the thumbnail.
var currentFormat = null # save current format. Used for thumbnail creation


#-------------Important--------------------------------
# I am still debating whether to remove the max dialog variable
#------------------------------------------------------
var history = []


#-------------Rollback Helper---------------------------
# Unused now.
var rollback_records = []

#------------------------------------------------------
# Utility functions

# Textbox is an array [unique id, text, voice(optional)]
func updateHistory(textbox):
	if (history.size() > vn.max_dialog_display):
		history.pop_front()
		# will be slow if this array gets too long
		
	textbox[1] = textbox[1].strip_edges()
	history.push_back(textbox)
	
func updateRollback():
	get_latest_nvl() # get current nvl text.
	get_latest_onstage() # get current on stage characters.
	if rollback_records.size() > vn.max_rollback_steps:
		rollback_records.remove(0)
	
	var cur_playback = playback_events.duplicate(true)
	var rollback_data = {'currentBlock': currentBlock, 'currentIndex': currentIndex, \
	'currentSaveDesc': currentSaveDesc, 'playback': cur_playback, 'dvar':vn.dvar.duplicate()}
	rollback_records.push_back(rollback_data)
	

func checkSkippable()->bool:
	if fileRelated.system_data.has(game.currentNodePath):
		if game.currentIndex > fileRelated.system_data[game.currentNodePath][game.currentBlock]:
			return false
		else:
			return true
	else:
		return true

func makeSnapshot():
	updateRollback()
	if checkSkippable() == false:
		fileRelated.system_data[game.currentNodePath][game.currentBlock] = game.currentIndex
		
