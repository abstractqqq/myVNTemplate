extends GeneralDialog
# Notice for any scene to be a VN scene, you must extend
# generalDialog. (In the future, more options will be given.)

#---------------------------------------------------------------------
# To start using a json, do this
func _ready():
	# game.currentSaveDesc = scene_description
	# game.currentNodePath = get_tree().current_scene.filename
	# This is is to make sure that a quit notification is popped up before quit
	get_tree().set_auto_accept_quit(false)
	if auto_start():
		# The following is optional. 
		
		# When you're in development mode, it's a good idea to be able to skip around without constraint.
		# Adding this will make all dialogs in this json file to be spoiler proof.
		# Which means that skip cannot skip to what the player hasn't read yet.
		# For instance, the current implementation is that if you have one save that finished
		# chapter one, then all your other save files will be able to skip chapter 1.
		# This line should be included when you're ready to deploy. (Also test it before release)
		fileRelated.make_spoilerproof(game.currentNodePath, get_all_dialog_blocks())
		# Once you call the function fileRelated.make_spoilerproof once
		# Then even if you delete this line, this dialog will still be spoiler proof.
		# To revert this, call reset_spoilerproof(scene_path:String)
		# in fileRelate.gd. Run it once and then comment it out.
	else:
		print("Start scene failed due to problems with dialog json file.")
