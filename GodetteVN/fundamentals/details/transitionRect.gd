extends ColorRect

func fadeout(t:float):
	var animation = Animation.new()
	var transition_player = get_node("AnimationPlayer")
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ":color")
	animation.set_length(t)
	animation.track_insert_key(track_index, 0, Color(0,0,0,0))
	animation.track_insert_key(track_index, t, Color(0,0,0,1))
	transition_player.add_animation("fadeout", animation)
	transition_player.play("fadeout")
	
func fadein(t:float):
	var animation = Animation.new()
	var transition_player = get_node("AnimationPlayer")
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ":color")
	animation.set_length(t)
	animation.track_insert_key(track_index, 0, Color(0,0,0,1))
	animation.track_insert_key(track_index, t, Color(0,0,0,0))
	transition_player.add_animation("fadein", animation)
	transition_player.play("fadein")
	
func pixelate_out(t:float):
	var transition_player = get_node("AnimationPlayer")
	self.material = load("res://customShaders/pixelate.tres")
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ":material:shader_param/time")
	animation.set_length(t)
	animation.track_insert_key(track_index, 0, 0.0)
	animation.track_insert_key(track_index, t, 1.562)
	transition_player.add_animation("pixel", animation)
	transition_player.play("pixel")
	
func pixelate_in(t:float):
	var transition_player = get_node("AnimationPlayer")
	self.material = load("res://customShaders/pixelate.tres")
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ":material:shader_param/time")
	animation.set_length(t)
	animation.track_insert_key(track_index, 0, 1.562)
	animation.track_insert_key(track_index, t, 0)
	transition_player.add_animation("pixel", animation)
	transition_player.play("pixel")
	

func _on_AnimationPlayer_animation_finished(anim_name):
	
	if anim_name == "pixel":
		self.material = null
		
	if anim_name == "self_destruct":
		call_deferred('free')
	else:
		var c = self.color
		var animation = Animation.new()
		var transition_player = get_node("AnimationPlayer")
		var track_index = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_index, ":color")
		animation.set_length(0.05)
		animation.track_insert_key(track_index, 0, c)
		animation.track_insert_key(track_index, 0.05, Color(0,0,0,0))
		transition_player.add_animation("self_destruct", animation)
		transition_player.play("self_destruct")
