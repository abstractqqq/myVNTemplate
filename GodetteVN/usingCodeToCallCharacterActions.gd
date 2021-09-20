extends Node2D

var vnui

func _ready():
	stage.fadein("gt", 2, Vector2(1600,600), "")
	stage.change_expression("gt", "crya")
	yield(get_tree().create_timer(2), 'timeout')
	stage.change_pos_2("gt", Vector2(200,600), 2, "quad") # 2 for non-instant movement
	stage.spin("gt",1080.0,2,-1)
	yield(get_tree().create_timer(2.5), 'timeout')
	vnui = load("res://GodetteVN/fundamentals/VNUI.tscn").instance()
	add_child(vnui)
	# As you can see, it is not so easy to control "stepping" of dialogs
	# outside the VN setting. It is doable. You just need a lot of yields.
	# I do not have a general method for you when you're not in the 
	# VN setting, because that is currently not the top concern for this
	# VN framework. (I might change my mind later...)
	
	# This is an example of auto-stepping
	# See comment 1 for player-click stepping
	vnui.show_text("Hello World!")
	yield(vnui.get_dialog_box(), 'load_next')
	yield(get_tree().create_timer(2), 'timeout')
	vnui.show_text("Hello again.")
	yield(vnui.get_dialog_box(), 'load_next')
	yield(get_tree().create_timer(2), 'timeout')
	screen.play_fade_out()
	vnui.queue_free()
	stage.remove_chara("absolute_all") # clean up


# Comment 1:
# Player click stepping has to be done manually. The easiest way is to
# yield to a signal which gets triggered whenever there is a vn_accept/ui_accept
# input. (See input map for those keys.)
