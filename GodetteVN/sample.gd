extends generalDialog
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

#-----------------------------------------------------------------

# How to implement Parallax background?

# (You need to know how to do parallax bg in Godot first)

# First, make sure that your parallax background scene is a separate
# Godot scene. You can use the builtin GDscene:scene_path function
# to transition from one VN scene to this scene.

# Now, replace the background node with the following nodes,
# parallaxBackground/parallaxLayer/background
# Now in the ready function below, call 
# set_bg_path('parallaxBackground/parallaxLayer/background')
# Now the var bg in generalDialog will be set to the correct node

# In your parallaxLayer, you need to make your parallax self moving.
# This is important because you don't want the position of characters
# and the camera to change to achieve the parallax effect. 
# That would mess up with character ations.

# Next if you're using the same background node here as the background
# in your parallax, then you're good to go. But if you're using a 
# custom background node, whether it's a texture rect or sprite,
# you need to make sure that it has a bg_change function that does
# the same thing as the one for this background node. 

# How do you switch back to a static background scene?
# Just use GDscene again to go to another scene.

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
		
		# Theoretically, given the structure of dialogs being used here, it is possible
		# to start the dialog from any point in the dialog file.
		# However, that is not ideal because if you do that, you might run into bugs
		# like calling character action with character hasn't joined the stage or like
		# bg not initialized. That defeats the purpose of testing.
		# So I think it's always a good idea to start from the start. 
		
		# Once you call the function fileRelated.spoiler_proof_dialog(..,..) once
		# Then even if you erase this function, this dialog will still be spoiler proof.
		# So to revert this, (to make all dialogs in this scene freely skippable again), 
		# you will need to go to GodetteVN/config.json and manually delete the 
		# dictionary which has key == this scene path.
