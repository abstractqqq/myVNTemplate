extends TextureButton
class_name clickableObject

export(String) var change_to_on_click = ''

func _ready():
	var _error = self.connect('pressed', self, '_on_pressed')
	
func _on_pressed():
	game.makeSnapshot()
	get_parent().get_parent().generate_nullify()
	get_parent().get_parent().change_block_to(change_to_on_click, 0)

