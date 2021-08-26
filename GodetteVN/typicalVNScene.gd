extends GeneralDialog
# Notice for any scene to be a VN scene, you must extend
# generalDialog. (In the future, more options will be given.)

# Moreover, background, VNUI, and CAMERA are three
# instanced scenes that should be subnodes in your scene.

# If you start from an empty 2D scene, these are the steps you
# should follow:
# 1. make root node a Node2D, attach a script.
# 2. Instance child scenes. Find in the folder
# /GodetteVN/fundamentals/details background.tscn and instance
# it as a subnode
# 3. Find in /GodetteVN/fundamentals VNUI.tscn and instance it
# as a subnode
# 4. Find in /GodetteVN/fundamentals/details camera.tscn and 
# instance it as a subnode.

# 5. Have a ready function like below if you're using json, and
# if your're using GDscript, see the example in sample2.

# This process is only suitable for VNs. For other purposes,
# I need to do some further work.


#---------------------------------------------------------------------
# To start using a json, do this
func _ready():
	game.currentSaveDesc = scene_description
	game.currentNodePath = get_tree().current_scene.filename
	# This is is to make sure that a quit notification is popped up before quit
	get_tree().set_auto_accept_quit(false)
	if self.dialog_json != "":
		var dialog_data = fileRelated.load_json(dialog_json)
		start_scene(dialog_data['Dialogs'],dialog_data['Choices'],dialog_data['Conditions'], game.load_instruction)
		
		# Adding this will make all dialogs in this json file to be spoiler proof.
		# Which means that skip cannot skip to what the player hasn't read yet.
		# This line should be included when you're ready to deploy. (Also test it before release)
		fileRelated.make_spoilerproof(game.currentNodePath, dialog_data['Dialogs'])
		
		# When you're in development mode, it's a good idea to be able to skip around without constraint.
		

		# Once you call the function fileRelated.make_spoilerproof once
		# Then even if you erase this function, this dialog will still be spoiler proof.
		# So to revert this, call reset_spoilerproof(scene_path:String)
		# in fileRelate.gd
