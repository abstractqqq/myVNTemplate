extends Node2D


func _ready():
	
	stage.fadein("gt", 2, Vector2(1600,600), "")
	stage.change_expression("gt", "crya")
	yield(get_tree().create_timer(1), 'timeout')
	stage.change_pos_2("gt", Vector2(500,600), 2)
	stage.spin("gt",1080.0,2,-1)
