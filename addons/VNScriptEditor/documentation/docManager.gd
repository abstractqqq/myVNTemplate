tool
extends TabContainer


func _on_documentation_resized():
	var tab = get_current_tab_control()
	tab.get_node('doc').rect_size.x = self.rect_size.x


func _on_documentation_tab_selected(tab):
	var prev_tab = get_tab_control(get_previous_tab())
	var cur_tab = get_tab_control(tab)
	cur_tab.get_node('doc').rect_size.x = prev_tab.get_node('doc').rect_size.x
