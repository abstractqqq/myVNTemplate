extends RichTextLabel


func display(tx:String, t:float, loc: Vector2):
	self.rect_position = loc
	self.bbcode_text = tx
	var anim_player = get_node("AnimationPlayer")
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ":modulate")
	animation.set_length(t)
	animation.track_insert_key(track_index, 0, Color(1,1,1,1))
	animation.track_insert_key(track_index, t, Color(1,1,1,0))
	anim_player.add_animation("float", animation)
	anim_player.play("float")

func _on_AnimationPlayer_animation_finished(_anim_name):
	self.queue_free()
