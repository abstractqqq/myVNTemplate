extends RichTextLabel

func set_font(font_path:String):
	self.add_font_override("normal_font", load(font_path))

func display(tx:String, t:float, in_t:float, loc: Vector2):
	self.rect_position = loc
	self.bbcode_text = tx
	var anim_player = get_node("AnimationPlayer")
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ":modulate")
	animation.set_length(in_t)
	animation.track_insert_key(track_index, 0, Color(1,1,1,0))
	animation.track_insert_key(track_index, in_t, Color(1,1,1,1))
	anim_player.add_animation("appear", animation)
	anim_player.play("appear")
	var animation2 = Animation.new()
	var track_index2 = animation2.add_track(Animation.TYPE_VALUE)
	animation2.track_set_path(track_index2, ":modulate")
	animation2.set_length(t)
	animation2.track_insert_key(track_index, 0, Color(1,1,1,1))
	animation2.track_insert_key(track_index, t, Color(1,1,1,0))
	anim_player.add_animation("disappear", animation2)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "appear":
		get_node("AnimationPlayer").play('disappear')
	else:
		self.queue_free()
