extends generalDialog

# It is possible to use your own choice bar or float text
# For choice bar, it is recommended that you use the node structure
# textureButton
# |-----RichTextLabel
# 
# and the script should have the same function names

#extends TextureButton
#signal choice_made(event)
#var choice_action = null
#func setup_choice_event(t: String, ev: Dictionary):
#   get_node('text').bbcode_text = "[center]" + t + "[/center]"
#   choice_action = ev
#func _on_choiceBar_pressed():
#   emit_signal("choice_made", choice_action)

#If you're new to programming, it is better if you simply go to the choiceBar.tscn
#scene and only change the appearance of the default choiceBar.
#

# For custom float text,
# You should have the structure
# richTextLabel
# |--- AnimationPlayer
# you can have your richTextLabel extend from FloatText class, which is a class
# I defined for this purpose. The base functionalities will be inherited
# and you can write your own functions like shaking or flying in circles or
# whatever you want. (Those effects should be called in _ready 
# and if you want your custom event with float text, then you will have to 
# make changes to generalDialog.gd's script. If you want, go to the 
# flt_text() and take a look. 
# Currently, generalDialog.gd is quite a mess. )
#
