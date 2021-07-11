extends CanvasLayer

# Only put actors as children of this singleton.

# In defense of this seemingly redundant design:
# This singleton might seem useless, because in reality you can put these
# functions in general dialog, instead of using stage.some_function()...
# (Since gameCharacter.gd is again a singleton...)

# However, that will make code in generalDialog.gd unncesaarily long.
# Here, we can offload some commands, like character actions with "all".
# Another point is that I need a stage singleton to control all 
# characters on stage (conveniently!). So I might as well use it as a 
# "midway" point where I can call from anywhere.


func is_on_stage(uid : String) -> bool:
	var c = chara.all_chara[uid]
	return c.on_stage

# Is there a way to combine these functions into one? 

func shake_chara(uid : String, amount: float, time: float):
	if uid == 'all':
		for n in get_children():
			if n.in_all:
				n.shake(amount, time)
	else:
		var c = chara.all_chara[uid]
		if c.on_stage:
			c.shake(amount, time)
		else:
			vn.error(c.unique_id + " is not on stage.")

func jump(uid : String, direc: String, amount: float, time : float):
	if uid == 'all':
		for n in get_children():
			if n.in_all:
				n.jump(direc, amount, time)
	else:
		var c = chara.all_chara[uid]
		if c.on_stage:
			c.jump(direc, amount, time)
		else:
			vn.error(c.unique_id + " is not on stage.")

func change_pos(uid:String, loca:Vector2): # instant position change.
	var c = chara.all_chara[uid]
	if c.on_stage:
		c.position = loca
		c.loc = loca
	else:
		print("Attempted to move a character with uid " + uid + " who's not on "+\
		"stage. Nothing is done.")

# If you're mad about how little this function does, see my comment at the
# top
func change_pos_2(uid:String, loca:Vector2, time:float, mode):
	var c = chara.all_chara[uid]
	if c.on_stage:
		c.change_pos_2(loca, time, mode)
	else:
		print("Attempted to move a character with uid " + uid + " who's not on "+\
		"stage. Nothing is done.")
		
func change_expression(uid:String, expression:String):
	var c = chara.all_chara[uid]
	if c.on_stage:
		c.change_expression(expression)
	# No error message because a character not on stage is still allowed
	# to talk. User might accidentally type in some expression, so this
	# should be not an error. 

func fadein(uid: String, time: float, loc: Vector2, expression:String) -> void:
	var c = chara.all_chara[uid]
	if not c.on_stage:
		add_child(c)
		
	c.position = loc
	c.on_stage = true
	c.fadein(time)
	c.change_expression(expression)

func fadeout(uid: String, time: float) -> void:
	if uid == 'all':
		for n in get_children():
			if n.in_all:
				n.on_stage = false
				n.fadeout(time)
	else:
		var c = chara.all_chara[uid]
		if c.on_stage:
			c.on_stage = false
			c.fadeout(time)
		else:
			vn.error('Character with this uid is already not on stage.')
	

func set_highlight(uid : String) -> void:
	var c = chara.all_chara[uid]
	if c.on_stage and c.apply_highlight:
		c.modulate = Color(1,1,1,1)

func remove_highlight() -> void:
	for n in get_children():
		if n.apply_highlight:
			n.modulate = vn.DIM

func remove_chara(uid : String):
	if uid == 'absolute_all':
		for n in get_children():
			n.on_stage = false
			self.remove_child(n)
	elif uid == 'all':
		for n in get_children():
			if n.in_all:
				n.on_stage = false
				self.remove_child(n)
	else:
		for n in get_children():
			if n.unique_id == uid:
				n.on_stage = false
				self.remove_child(n)
				return
		print('The node to remove is not found.')


# The methods below are only used internally, so no need to consider in_all
func set_modulate_4_all(c : Color):
	for n in get_children():
		n.modulate = c


func all_on_stage():
	var output = []
	for n in get_children():
		if n.on_stage:
			var temp = {n.unique_id: n.current_expression, 'loc': n.position}
			output.append(temp)
			
	return output
