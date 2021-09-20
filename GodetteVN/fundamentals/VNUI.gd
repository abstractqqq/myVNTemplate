extends CanvasLayer

# These functions are supposed to be used when you're not in a VN setting,
# but want to show dialogs and such

# Note that such dialogs will not be saved in history, unless you
# manually change the code here. The reason is the the internal dialog
# system does not reply on functions here to do dialogs and other things.

# It is possible in the future I will make changes to let the internal
# dialog system use this component as well.

# Returns the dialog box node

onready var dbox = $textBox/dialog

func free_QM():
	get_node("quickMenu").queue_free()

func get_dialog_box():
	return dbox
	
# Text displayed by this method won't move on to the next one 
# upon any user input.
# In you scene, if you have
# vnui.show_timed_text(s1, 1)
# vnui.show_timed_text(s2, 1)
# ...
# Then it will display s1 first, after s1 is shown and then it waits for 1s,
# and then it shows s2, and waits for 1s again.
func show_text(s:String):
	dbox.nw = true
	dbox.set_dialog(s)

