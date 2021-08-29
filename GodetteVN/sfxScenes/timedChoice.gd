extends Node2D

# You can use the OG Godot timer. The object timer will save you a few 
# lines of code though, but it is harder to understand. 
# It is a helper class I made to assist me with some other stuff.
# It turns out we can use it here too

# If your interested, you can go to character.gd to see more usage of the 
# objectTimer



# I know that params is going to be an integer which is time
var params = 0


# This scene should be put immediately before a choice (*)
var initialInd = 0
var initialBname = ""

func _ready():
	initialInd = game.currentIndex
	initialBname = game.currentBlock
	$Label.text = str(params)
	var obj_timer = ObjectTimer.new(self,params,1,"_do")
	add_child(obj_timer)

func _process(_delta):
	# if the player made a choice in time, then are two cases
	# 1. The choice leads to another dialog block (branching)
	# 2. The choice leads to the next event in your current block
	# which means |currentInd - game.currentIndex | > 1
	
	if initialBname != game.currentBlock:
		# player has reached another block, the choice must have been made
		
		# this line is necessary if u do not want your choice to be rolled back
		# Note: if it is rolled back, the choice will no longer be timed
		# game.rollback_records = []
		
		# always needed 
		self.queue_free()
	else:
		# in the same block, but index difference is > 1, that means the player
		# must have made a choice and proceeded down the same block. This
		# explains why I need (*)
		if abs(initialInd - game.currentIndex) > 1:
			
			# this line is necessary if u do not want your choice to be rolled back
			# Note: if it is rolled back, the choice will no longer be timed
			# game.rollback_records = []
			
			# always needed
			self.queue_free()


# This function will be called by obj_timer, and that means
# 1 sec has been passed. The argument will not be used. (It's an argument
# passed in by objectTimer.)
func _do(_params):
	params -= 1
	$Label.text = str(params)
	if params <= 0:
		# I know that this scene will be a direct subnode of the root node
		# in my VN scene
		var par = get_parent()
		
		
		# false is needed if you do not want your choice to be rolled back
		# Note: if it is rolled back, the choice will no longer be timed
		par.on_choice_made({'then':'out_of_time'} , true)
		# If you want to go to another scene, like YOU FAILED SCENE, you can use directly
		# get_tree().change_scene_to() here
		
		
		# Don't forget to clear itself
		self.queue_free()
