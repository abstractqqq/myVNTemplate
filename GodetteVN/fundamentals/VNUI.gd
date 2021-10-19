extends CanvasLayer

export(bool) var show_quick_menu = true
export(bool) var draggable_dialog = false
export(bool) var resizable_dialog = false
export(bool) var fix_relative_name_box_pos = true

onready var dbox = $dialogBox/textBox
onready var fixed_diff = $nameBox.rect_position-$dialogBox.rect_position

func _ready():
	set_dialog_box_options(draggable_dialog,resizable_dialog)
	if show_quick_menu == false: free_QM()

func free_QM():
	get_node("quickMenu").queue_free()

func get_dialog_box():
	return dbox
	
func reset_namebox_pos(pos = Vector2(0,0)):
	if fix_relative_name_box_pos:
		$nameBox.rect_position = $dialogBox.rect_position+fixed_diff
	else:
		$nameBox.rect_position = pos
	
func set_dialog_box_options(draggable:bool=false, resizable:bool=false):
	$dialogBox.resizable = resizable
	$dialogBox.draggable = draggable
	if resizable == false:
		$dialogBox.hide_resize_handler()

