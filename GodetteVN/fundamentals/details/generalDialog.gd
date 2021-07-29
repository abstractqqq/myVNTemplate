extends Node2D
class_name generalDialog
export(bool) var debug_mode
export(PackedScene) var choiceBar = preload("res://GodetteVN/fundamentals/choiceBar.tscn")

var floatText = preload("res://GodetteVN/fundamentals/details/floatText.tscn")

var current_dialog = ""
var current_index = 0
var current_block = null
var all_blocks = null
var all_choices = null

# State controls
var hide_all_boxes = false
var nvl = false
var centered = false
var waiting_acc = false
var waiting_cho = false
var just_loaded = false
var hide_vnui = false
var no_scroll = false
var no_right_click = false
#----------------------
const cps_dict = {'fast':50, 'slow':25, 'instant':0, 'slower':10}
const arith_symbols = ['>','<', '=', '!', '+', '-', '*', '/']
# Important components
onready var bg = $background
onready var vnui = $VNUI
onready var QM = vnui.get_node('quickMenu')
onready var nvlBox = vnui.get_node('nvlBox')
onready var dialogbox = vnui.get_node('textBox/dialog')
onready var speaker = vnui.get_node('nameBox/speaker')
onready var camera = get_node('camera')
#-----------------------
# signals
signal player_accept

#--------------------------------- Intepretor ----------------------------------

func load_event_at_index(ind : int) -> void:
	if ind >= current_block.size():
		print("IMPORTANT: THERE IS NO PROPER ENDING. GOING BACK TO MAIN MENU.")
		change_scene_to(vn.ending_scene_path)
	else:
		intepret_events(current_block[ind])

func intepret_events(event):
	# Try to keep the code under each case <=3 lines
	# Also keep the number of cases small. Try to repeat the use of key words.
	if debug_mode: 
		var debugger = vnui.get_node('debugger')
		var msg = "Debug :" + str(event)
		debugger.text = msg 
		print(msg)
	
	# Pre-parse, keep this at minimum
	if event.has('loc'): 
		event['loc'] = parse_loc(event['loc'], event)
	if event.has('color'): 
		event['color'] = parse_color(event['color'], event)
	if event.has('nvl'):
		if (typeof(event['nvl'])!=1) and event['nvl'] != 'clear': 
			event['nvl'] = parse_true_false(event['nvl'], event)
	if event.has('scale'):
		event['scale'] = parse_loc(event['scale'], event)
	if event.has('dir'):
		event['dir'] = parse_dir(event['dir'], event)

	# End of pre-parse. Actual match event
	match event:
		{"condition", "then", "else",..}: conditional_branch(event)
		{"condition",..}:
			if check_condition(event['condition']):
				event.erase('condition')
				continue
			else: # condition fails.
				auto_load_next()
		{"fadein"}: fadein(event["fadein"])
		{"fadeout"}: fadeout(event["fadeout"])
		{"screen",..}: screen_effects(event)
		{"bg",..}: change_background(event)
		{"chara",..}: character_event(event)
		{"weather"}: change_weather(event)
		{"camera", ..}: camera_effect(event)
		{"express"}: express(event['express'])
		{"bgm",..}: play_bgm(event)
		{'audio',..}: play_sound(event)
		{'dvar'}: set_dvar(event)
		{'font', 'path'}: change_font(event)
		{'sfx',..}: sfx_player(event)
		{'then',..}: then(event)
		{'premade'}:
			if debug_mode:
				print("PREMADE EVENT:")
			intepret_events(fun.call_premade_events(event['premade']))
		{"system"}: system(event)
		{"sys"}: system(event)
		{'choice',..}: generate_choices(event)
		{'wait'}: wait(event['wait'])
		{'nvl'}: set_nvl(event)
		{'GDscene'}: change_scene_to(event['GDscene'])
		{'history', ..}: history_manipulation(event)
		{'float', 'wait',..}: float_text(event)
		{'voice'}:voice(event['voice'])
		{'center'}:
			self.centered = true
			set_nvl({'nvl': true}, false)
			if event.has('speed'):
				say('', event['center'], event['speed'])
			else:
				say('', event['center'])
		_: speech_parse(event)
				
			
#----------------------- on ready, new game, load, set up, end -----------------
func start_scene(blocks : Dictionary, choices: Dictionary, load_instruction : String) -> void:
	all_blocks = blocks
	all_choices = choices
	dialogbox.connect('load_next', self, 'trigger_accept')
	nvlBox.connect('load_next', self, 'trigger_accept')
	if load_instruction == "new_game":
		current_index = 0
		current_block = blocks['starter'] # this is an array of events
		game.currentIndex = 0
		game.currentBlock = 'starter' # this is the name corresponding to the array
	elif load_instruction == "load_game":
		game.load_instruction = "new_game" # reset after loading
		current_index = game.currentIndex
		current_block = blocks[game.currentBlock]
		load_playback(game.playback_events)
	else:
		vn.error('Unknown loading instruction.')
	
	if debug_mode:
		print("Debug: current block is " + game.currentBlock)
		print("Debug: current index is " + str(current_index))
	load_event_at_index(current_index)
	

func auto_load_next():
	current_index += 1
	game.currentIndex = current_index
	if debug_mode: 
		print("Debug: current event index is " + str(current_index))
	load_event_at_index(current_index)

func scene_end():
	pass
#------------------------ Related to Dialog Progression ------------------------
func set_nvl(ev: Dictionary, auto_forw = true):
	if typeof(ev['nvl']) == 1:
		self.nvl = ev['nvl']
		if self.nvl:
			nvl_on()
		else:
			nvl_off()
		
		if auto_forw: auto_load_next()
		return
	elif ev['nvl'] == 'clear':
		nvlBox.clear()
		if auto_forw: auto_load_next()
	else:
		vn.error('nvl expects a boolean or the keyword clear.', ev)
	
func speech_parse(ev : Dictionary) -> void:
	var combine = "NANITHEFUCK"
	for k in ev.keys(): # Not voice, not speed, means it has to be "uid expression"
		if k != 'voice' and k != 'speed':
			combine = k # combine=unique_id and expression combined
			break
			
	if combine == 'NANITHEFUCK': # Otherwise, error
		vn.error("Speech event requires a valid character/narrator." ,ev)
	
	if ev.has('speed'):
		if (ev['speed'] in cps_dict.keys()):
			say(combine, ev[combine], cps_dict[ev['speed']])
		else:
			say(combine, ev[combine])
	else:
		say(combine, ev[combine])
				
	if ev.has('voice') and not vn.skipping:
		voice(ev['voice'], false)


func generate_choices(event: Dictionary):
	# make a say event
	if self.nvl:
		nvl_off()
	else:
		dialogbox.text = ""
		speaker.text = ""
	if vn.auto_on or vn.skipping:
		QM.disable_skip_auto()
	waiting_cho = true
	if event.has('voice'):
		voice(event['voice'], false)
	var combine = ""
	for k in event.keys():
		if k != 'id' and k != 'choice' and k != 'voice':
			combine = k
			break
	if combine != "":
		say(combine, event[combine], 0, true)
		
	var options = all_choices[event['choice']]
	for i in options.size():
		var ev = options[i]
		if ev.size()>2 : 
			vn.error('Only size 1 or 2 dict will be accepted as choice.')
		elif ev.size() == 2:
			if ev.has('condition'):
				if not check_condition(ev['condition']):
					continue # skip to the next one if condition not met
			else:
				vn.error('If a choice is size 2, then it has to have a condition.')
					
		var choice_text = ""
		for k in ev.keys():
			if k != "condition":
				choice_text = k # grap the key not equal to condition
				break
					
		var choice_ev = ev[choice_text] # the choice action
		var choice = choiceBar.instance()
		choice.setup_choice_event(choice_text, choice_ev)
		choice.connect("choice_made", self, "on_choice_made")
		vnui.get_node('choiceContainer').add_child(choice)
		# waiting for user choice
	
func say(combine : String, words : String, cps = vn.cps, ques = false) -> void:
	var temp = combine.split(" ") # temp[0] = uid, temp[1] = expression
	var speaking_chara = stage.get_character_info(temp[0])
	if temp.size() == 2:
		stage.change_expression(temp[0], temp[1])
			
	words = preprocess(words)
	if vn.skipping: cps = 0
	waiting_acc = true
	if self.nvl:
		if just_loaded:
			just_loaded = false
			if centered:
				nvlBox.set_dialog(temp[0], words, cps)
			else:
				nvlBox.visible_characters = nvlBox.text.length()
		else:
			nvlBox.set_dialog(temp[0], words, cps)
			if centered: 
				game.nvl_text = ''
			else:
				game.nvl_text = nvlBox.bbcode_text
			game.history.push_back([temp[0], nvlBox.get_text()])
	else:
		speaker.set("custom_colors/default_color", speaking_chara["name_color"])
		speaker.bbcode_text = speaking_chara["display_name"]
		dialogbox.set_dialog(words, cps)
		if just_loaded:
			just_loaded = false
		else:
			game.history.push_back([temp[0], dialogbox.get_text()])
		
		stage.set_highlight(temp[0])
		
	# wait for ui_accept if this is not a question
	if not ques:
		yield(self, "player_accept")
		music.stop_voice()
		if centered:
			nvl_off()
			centered = false
		if not self.nvl: stage.remove_highlight()
		waiting_acc = false
		auto_load_next()
	
	# If this is a question, then displaying the text is all we need.

func _input(ev):
	if ev.is_action_pressed('vn_upscroll') and not vn.inSetting and not vn.inNotif and not no_scroll:
		QM._on_historyButton_pressed()
		return
	
	if waiting_cho:
		# Waiting for a choice. Do nothing. Any input will be nullified.
		# In a choice event, game resumes only when a choice button is selected.
		return
		
	if ev.is_action_pressed('vn_cancel') and not vn.inNotif and not vn.inSetting and not no_right_click:
		hide_UI()

	if (ev.is_action_pressed("ui_accept") or ev.is_action_pressed('vn_accept')) and waiting_acc:
		if hide_vnui: # Show UI
			hide_UI(true)
		# vn_accept is mouse left click
		if ev.is_action_pressed('vn_accept'):
			if vn.auto_on or vn.skipping:
				if not vn.noMouse:
					QM.reset_auto()
					QM.reset_skip()
				else:
					return
			else:
				if not vn.noMouse and not vn.inNotif and not vn.inSetting:
					check_dialog()
		else: # not mouse
			if vn.auto_on or vn.skipping:
				QM.reset_auto()
				QM.reset_skip()
			elif not vn.inNotif and not vn.inSetting:
				check_dialog()
				
	
func change_font(ev : Dictionary):
	var path = vn.FONT_DIR + ev['path']
	
	match ev['font']:
		'normal':
			dialogbox.add_font_override("normal_font", load(path))
			nvlBox.add_font_override("normal_font", load(path))
		'bold':
			dialogbox.add_font_override("bold_font", load(path))
			nvlBox.add_font_override("bold_font", load(path))
		'italics':
			dialogbox.add_font_override("bold_font", load(path))
			nvlBox.add_font_override("bold_font", load(path))
		'bold_italics':
			dialogbox.add_font_override("bold_font", load(path))
			nvlBox.add_font_override("bold_font", load(path))
		'mono':
			dialogbox.add_font_override("mono_font", load(path))
			nvlBox.add_font_override("mono_font", load(path))
		_: vn.error("Unknown font style (Use normal, bold, italics, bold_italics or mono.).", ev)
			
	auto_load_next()
	
	
#------------------------ Related to Music and Sound ---------------------------
func play_bgm(ev : Dictionary) -> void:
	var path = ev['bgm']
	if (path == "" or path == "off") and ev.size() == 1:
		music.stop_bgm()
		game.playback_events['bgm'] = {}
		auto_load_next()
		return
		
	if path == "pause":
		music.pause_bgm()
		auto_load_next()
		return
	elif path == "resume":
		music.resume_bgm()
		auto_load_next()
		return
		
	# Deal with fadeout first
	if path == "" and ev.size() > 1: # must be a fadeout
		if ev.has('fadeout'):
			music.fadeout(ev['fadeout'])
			game.playback_events['bgm'] = {}
			auto_load_next()
			return
		else:
			vn.error('If fadeout is intended, please supply a time. Otherwise, unknown '+\
			'keyword format.', ev)
			
	# Now we're sure it's either play bgm or fadein bgm
	var vol = 0
	if ev.has('vol'): vol = ev['vol']
	var music_path = vn.BGM_DIR + path
	if not ev.has('fadein'): # has path or volume
		music.play_bgm(music_path, vol)
		game.playback_events['bgm'] = ev
		if !vn.inLoading:
			auto_load_next()
		return
			
	if ev.has('fadein'):
		
		music.fadein(music_path, ev['fadein'], vol)
		game.playback_events['bgm'] = ev
		if !vn.inLoading:
			auto_load_next()
		return
	else:
		vn.error('If fadein is intended, please supply a time. Otherwise, unknown '+\
		'keyword format.', ev)
	
	
func play_sound(ev :Dictionary) -> void:
	var audio_path = vn.AUDIO_DIR + ev['audio']
	var vol = 0
	if ev.has('vol'): vol = ev['vol'] 
	music.play_sound(audio_path, vol)
	auto_load_next()
	
		
func voice(path:String, auto_forw = true) -> void:
	var voice_path = vn.VOICE_DIR + path
	music.play_voice(voice_path)
	if auto_forw:
		auto_load_next()
	
#------------------- Related to Background and Godot Scene Change ----------------------
# I will need to refactor this...
func change_background(ev : Dictionary) -> void:
	var path = ev['bg']
	if ev.size() == 1 or vn.skipping or vn.inLoading:
		bg_change(path)
	elif ev.has('fade'):
		var t = float(ev['fade'])/2
		fadeout(t, false)
		yield(get_tree().create_timer(t), 'timeout')
		bg_change(path)
		fadein(t, false)
		yield(get_tree().create_timer(t), 'timeout')
	elif ev.has('pixelate'):
		var t = float(ev['pixelate'])/2
		screenEffects.pixel_out(t)
		clear_boxes()
		hide_boxes()
		QM.visible = false
		yield(get_tree().create_timer(t), 'timeout')
		bg_change(path)
		screenEffects.pixel_in(t)
		yield(get_tree().create_timer(t), 'timeout')
		show_boxes()
		if not QM.hiding: QM.visible = true
	
	else:
		vn.error("Unknown bg transition effect.", ev)
	
	if !vn.inLoading:
		game.playback_events['bg'] = ev
		auto_load_next()

func change_scene_to(path : String):
	stage.remove_chara('absolute_all')
	music.stop_voice()
	if path == vn.main_menu_path:
		music.stop_bgm()
	screenEffects.weather_off()
	QM.reset_auto()
	QM.reset_skip()
	var error = get_tree().change_scene(vn.ROOT_DIR + path)
	if error == OK:
		self.queue_free()
	else:
		vn.error('p')

#------------------------------ Related to Dvar --------------------------------
func set_dvar(ev : Dictionary) -> void:
	var splitted = fun.break_line(ev['dvar'], '=')
	var left = splitted[0]
	left = left.replace(" ","")
	var right = splitted[1]
	if has_dvar(left):
		vn.dvar[left] = fun.calculate(right)
	else:
		vn.error("Dvar {0} not found".format({0:left}) ,ev)
	
	auto_load_next()
	

func check_condition(cond : String) -> bool:
	var parsed = split_condition(cond)
	var front_var = parsed[0]
	var rel = parsed[1]
	var back_var = parsed[2]
	
	front_var = dvar_or_float(front_var)
	back_var = dvar_or_float(back_var)

	var result = false
	
	match rel:
		"=": result = (front_var == back_var)
		"==": result = (front_var <= back_var)
		"<=": result = (front_var <= back_var)
		">=": result = (front_var >= back_var)
		"<": result = (front_var < back_var)
		">": result = (front_var > back_var)
		"!=": result = (front_var != back_var)
		_: vn.error('Relation ' + rel + ' invalid.')
	
	return result

#--------------- Related to transition and other screen effects-----------------
func screen_effects(ev: Dictionary):
	var ef = ev['screen']
	match ef:
		"", "off": 
			screenEffects.removeLasting()
			game.playback_events['screen'] = {}
		"tint": tint(ev)
		"tintwave": tint(ev)
		"flashlight": flashlight(ev)
		_: vn.error('Unknown screen effect.' , ev)
	
	if !vn.inLoading:
		auto_load_next()

func flashlight(ev:Dictionary):
	var sc = Vector2(1,1) # Default value
	if ev.has('scale'): sc = ev['scale']
	screenEffects.flashlight(sc)
	game.playback_events['screen'] = ev

func fadein(time : float, auto_forw = true) -> void:
	clear_boxes()
	if not self.nvl: show_boxes()
	QM.visible = false
	if not vn.skipping:
		screenEffects.fadein(time)
		yield(get_tree().create_timer(time), "timeout")
	
	if not QM.hiding: QM.visible = true
	if auto_forw: auto_load_next()
	
func fadeout(time : float, auto_forw = true) -> void:
	clear_boxes()
	hide_boxes()
	QM.visible = false
	if not vn.skipping:
		screenEffects.fadeout(time)
		yield(get_tree().create_timer(time), "timeout")
	if not QM.hiding: QM.visible = true
	if not self.nvl: show_boxes()
	if auto_forw: auto_load_next()

func tint(ev : Dictionary) -> void:
	var time = 1
	if ev.has('time'): time = ev['time']
	if ev.has('color'):
		if ev['screen'] == 'tintwave':
			screenEffects.tintWave(ev['color'], time)
		elif ev['screen'] == 'tint':
			screenEffects.tint(ev['color'], time)
			
		game.playback_events['screen'] = ev
	else:
		vn.error("Tint or tintwave requires the color field.", ev)

# Scene animations...
func sfx_player(ev : Dictionary) -> void:
	var target_scene = load(vn.ROOT_DIR + ev['sfx']).instance()
	add_child(target_scene)
	if ev.has('loc'): target_scene.position = ev['loc']
	if ev.has('anim'):
		var anim = target_scene.get_node('AnimationPlayer')
		if anim.has_animation(ev['anim']):
			anim.play(ev['anim'])
			auto_load_next()
		else:
			vn.error('Animation not found.', ev)
	else: # Animation is not specified, that means it will automatically play
		auto_load_next()

func camera_effect(ev : Dictionary) -> void:
	var ef_name = ev['camera']
	match ef_name:
		"vpunch": if not vn.skipping: camera.vpunch()
		"hpunch": if not vn.skipping: camera.hpunch()
		"reset": 
			camera.reset_zoom()
			game.playback_events['camera'] = {}
		"zoom":
			QM.reset_skip()
			if ev.has('scale'):
				var time = 1
				var offset = Vector2(0,0)
				var type = 'linear'
				if ev.has('time'): time = ev['time']
				if ev.has('type'): type = ev['type']
				if ev.has('loc'): offset = ev['loc']
				if type == 'instant':
					camera.zoom(ev['scale'], offset)
				else:
					camera.zoom_timed(ev['scale'], time, type,offset)
				game.playback_events['camera'] = {'zoom':ev['scale'], 'offset':offset}
			else:
				vn.error('Camera zoom expects a scale.', ev)
		"move":
			QM.reset_skip()
			var time = 1
			var type = "linear"
			if ev.has('time'): time = ev['time']
			if ev.has('type'): type = ev['type']
			if ev.has('loc'):
				if vn.skipping: time = 0
				if ev.has('type'):
					if type == 'instant': ev['time'] = 0
					camera.camera_move(ev['loc'],time, type)
				else:
					camera.camera_move(ev['loc'], time)
				
				game.playback_events['camera'] = {'zoom':camera.zoom, 'offset':ev['loc']}
				yield(get_tree().create_timer(time), 'timeout')
			else:
				vn.error("Camera move expects a loc and time, and type (optional)", ev)
		"shake":
			if not vn.skipping:
				var amount = 250
				var time = 2
				if ev.has('amount'): amount = ev['amount']
				if ev.has('time'): time = ev['time']
				camera.shake(amount, time)
		_:
			vn.error("Camera effect not found.", ev)
			
	auto_load_next()
#----------------------------- Related to Character ----------------------------
func character_event(ev : Dictionary) -> void:
	# For character event, auto_load_next should be consider within
	# each individual method. Because some methods requires a yield
	# before auto_load_next.
	
	var temp = ev['chara'].split(" ")
	if temp.size() != 2:
		vn.error('Expecting a uid and an effect name separated by a space.', ev)
	var uid = temp[0] # uid of the character
	var ef = temp[1] # what character effect
	if uid == 'all' or stage.is_on_stage(uid):
		match ef: # jump and shake will be ignored during skipping
			"shake": 
				if vn.skipping : 
					auto_load_next()
				else:
					character_shake(uid, ev)
			"jump": 
				if vn.skipping : 
					auto_load_next()
				else:
					character_jump(uid, ev)
			'move': 
				if uid == 'all': 
					print("Warning: Attempting to move all character at once.")
					print("This cannot be done and this event is ignored.")
					auto_load_next()
				else:
					character_move(uid, ev)
			'fadeout': 
				if vn.skipping:
					stage.remove_chara(uid)
					auto_load_next()
				else:
					character_fadeout(uid,ev)
			'leave': 
				stage.remove_chara(uid)
				auto_load_next()
			_: vn.error('Unknown character event/action.', ev)
		
	else: # uid is not all, and character not on stage
		var expression = ""
		if ev.has('expression'): expression = ev['expression'] 
		if ef == 'join':
			if ev.has('loc'):
				stage.join(uid,ev['loc'], expression)
			else:
				vn.error('Character join expects a loc.', ev)
		elif ef == 'fadein':
			var time = 1
			if ev.has('time'): time = ev['time']
			if ev.has('loc'): 
				stage.fadein(uid,time, ev['loc'], expression)
			else:
				vn.error('Character fadein expects a time and a loc.', ev)
		else:
			vn.error('Unknown character event/action.', ev)	
			
		if !vn.inLoading:
			auto_load_next()

# Maybe we can refactor all these character functions below to stage?
func character_shake(uid:String, ev:Dictionary) -> void:
	var amount = 250
	var time = 2
	if ev.has('amount'): amount = ev['amount']
	if ev.has('time'): time = ev['time']
	stage.shake_chara(uid, amount, time)
	auto_load_next()
	

func express(combine : String) -> void:

	var temp = combine.split(" ")
	if temp.size() > 2 or temp.size() == 0:
		vn.error("Wrong express format.")
	elif temp.size() == 1:
		temp.push_back("")
	
	# express only works for on stage charas
	stage.change_expression(temp[0],temp[1])
	auto_load_next()

func character_jump(uid : String, ev : Dictionary) -> void:
	var amount = 80
	var time = 0.25
	var dir = "up"
	if ev.has('amount'): amount = ev['amount']
	if ev.has('time'): time = ev['time']
	if ev.has('dir'): dir = ev['dir']
	stage.jump(uid, dir, amount, time)
	auto_load_next()
	

func character_fadeout(uid: String, ev:Dictionary):
	var time = 1
	if ev.has('time'): time = ev['time']
	stage.fadeout(uid, time)
	yield(get_tree().create_timer(time), 'timeout')
	auto_load_next()

func character_move(uid:String, ev:Dictionary):
	var type = "linear"
	if ev.has('type'): type = ev['type']
	if ev.has('loc'):
		if ev['type'] == 'instant' or vn.skipping:
			stage.change_pos(uid, ev['loc'])
		else:
			var time = 1
			if ev.has('time'):time = ev['time']
			stage.change_pos_2(uid, ev['loc'], time, type)
		auto_load_next()
	else:
		vn.error("Character move expects a loc.", ev)


#--------------------------------- Weather -------------------------------------
func change_weather(ev:Dictionary):
	var we = ev['weather']
	screenEffects.show_weather(we) # If given weather doesn't exist, nothing will happen
	if !vn.inLoading:
		if we == "":
			game.playback_events['weather'] = {}
		else:
			game.playback_events['weather'] = ev
		
		auto_load_next()

#--------------------------------- History -------------------------------------
func history_manipulation(ev: Dictionary):
	
	var what = ev['history']
	if what == "push":
		if ev.size() != 2:
			vn.error('History push got more fields than 2.', ev)
		
		for k in ev.keys():
			if k != 'history':
				game.history.push_back([k, preprocess(ev[k])])
				break
		
	elif what == "pop":
		game.history.pop_back()
	else:
		vn.error('History expects either push or pop.', ev)
		
	auto_load_next()
	
#--------------------------------- Utility -------------------------------------
func conditional_branch(ev : Dictionary) -> void:
	if check_condition(ev['condition']):
		change_block_to(ev['then'],0)
	else:
		change_block_to(ev['else'],0)

func then(ev : Dictionary) -> void:
	if ev.has('target id') and ev['target id'] != -1:
		change_block_to(ev['then'], 1 + get_target_index(ev['then'], ev['target id']))
	else:
		change_block_to(ev['then'], 0)
		
func change_block_to(bname : String, bindex : int) -> void:
	if all_blocks.has(bname):
		current_block = all_blocks[bname]
		if bindex >= current_block.size():
			vn.error("Cannot go back to the last event of block " + bname + ".")
		else:
			game.currentBlock = bname
			game.currentIndex = bindex
			current_index = bindex 
			if debug_mode:
				print("Debug: current block is " + bname)
				print("Debug: current index is " + str(bindex))
			load_event_at_index(current_index)
	else:
		vn.error('Cannot find block with the name ' + bname)

func get_target_index(bname : String, target_id):
	for i in range(all_blocks[bname].size()):
		var d = all_blocks[bname][i]
		if d.has('id') and (d['id'] == target_id):
			return i
	vn.error('Cannot find event with id ' + target_id + ' in ' + bname)
	
func has_dvar(key : String) -> bool:
	if vn.dvar.has(key):
		return true
	else:
		return false

func check_dialog():
	if not QM.hiding: QM.visible = true
	hide_vnui = false
	if hide_vnui:
		hide_vnui = false
		if self.nvl:
			nvlBox.visible = true
			if self.centered:
				dimming(vn.CENTER_DIM)
			else:
				dimming(vn.NVL_DIM)
		else:
			show_boxes()
	
	if self.nvl and nvlBox.adding:
		nvlBox.force_finish()
	elif not self.nvl and dialogbox.adding:
		dialogbox.force_finish()
	else:
		emit_signal("player_accept")


func clear_boxes():
	speaker.bbcode_text = ''
	dialogbox.bbcode_text = ''

func wait(time : float) -> void:
	if vn.skipping:
		auto_load_next()
		return
	if time >= 0.1:
		time = stepify(time, 0.1)
		yield(get_tree().create_timer(time), "timeout")
		auto_load_next()
	else:
		vn.error('Wait time has to be 0.1s or longer.')

func on_choice_made(ev : Dictionary) -> void:
	QM.enable_skip_auto()
	for n in vnui.get_node('choiceContainer').get_children():
		n.queue_free()
	
	waiting_cho = false
	if ev.size() == 0:
		auto_load_next()
	else:
		intepret_events(ev)


func load_playback(play_back):
	vn.inLoading = true
	if play_back['bg'].size() > 0:
		intepret_events(play_back['bg'])
	if play_back['bgm'].size() > 0:
		intepret_events(play_back['bgm'])
	if play_back['screen'].size() > 0:
		intepret_events(play_back['screen'])
	if play_back['camera'].size() > 0:
		camera.set_camera(play_back['camera'])
	if play_back['weather'].size() > 0:
		intepret_events(play_back['weather'])
	
	for d in play_back['charas']:
		var dkeys = d.keys()
		var loc = d['loc']
		dkeys.erase('loc')
		var uid = dkeys[0]
		intepret_events({'chara': uid + ' join', 'loc': loc, 'expression': d[uid]})
		
	if play_back['nvl'] != '':
		nvl_on()
		game.nvl_text = play_back['nvl']
		nvlBox.bbcode_text = game.nvl_text
	
	vn.inLoading = false
	just_loaded = true

func split_condition(line:String):
	var front_var = ''
	var back_var = ''
	var rel = ''
	var presymbol = true
	for i in line.length():
		var le = line[i]
		if le != " ":
			var is_symbol = le in arith_symbols
			if is_symbol:
				presymbol = false
				rel += le

			if not (is_symbol) and presymbol:
				front_var += le
				
			if not (is_symbol) and not presymbol:
				back_var += le
				
	return [front_var, rel, back_var]

func dvar_or_float(dvar:String):
	var output = 0
	if has_dvar(dvar):
		output = vn.dvar[dvar]
	elif dvar.is_valid_float():
		output = dvar.to_float()
	else:
		vn.error('Variable is not a dvar and is not a valid float.')
	return output

func float_text(ev: Dictionary) -> void:
	var wt = ev['wait']
	ev['float'] = preprocess(ev['float'])
	var loc = Vector2(600,300)
	if ev.has('loc'): loc = ev['loc']
	var in_t = 1
	if ev.has('fadein'): in_t = ev['fadein']
	var f = floatText.instance()
	if ev.has('font') and ev['font'] != "" and ev['font'] != "default":
		f.set_font(ev['font'])
	self.add_child(f)
	if ev.has('time') and ev['time'] > wt:
		f.display(ev['float'], ev['time'], in_t, loc)
	else:
		f.display(ev['float'], wt, in_t, loc)
	
	if vn.FLOAT_HIS:
		game.history.push_back(["", ev['float']])
		
	wait(wt)

func nvl_off():
	show_boxes()
	dialogbox.get_node('autoTimer').start()
	nvlBox.visible = false
	nvlBox.clear()
	nvlBox.get_node('autoTimer').stop()
	get_node('background').modulate = Color(1,1,1,1)
	stage.set_modulate_4_all(Color(0.86,0.86,0.86,1))
	self.nvl = false

func nvl_on():
	stage.set_modulate_4_all(vn.DIM)
	if centered: nvl_off()
	clear_boxes()
	hide_boxes()
	dialogbox.get_node('autoTimer').stop()
	nvlBox.visible = true
	nvlBox.get_node('autoTimer').start()
	if centered:
		nvlBox.center_mode()
		get_node('background').modulate = vn.CENTER_DIM
		stage.set_modulate_4_all(vn.CENTER_DIM)
	else:
		get_node('background').modulate = vn.NVL_DIM
		stage.set_modulate_4_all(vn.NVL_DIM)
	
	self.nvl = true

func trigger_accept():
	if not waiting_cho:
		emit_signal("player_accept")
		if hide_vnui:
			if not QM.hiding: QM.visible = true
			if self.nvl:
				nvlBox.visible = true
				if self.centered:
					dimming(vn.CENTER_DIM)
				else:
					dimming(vn.NVL_DIM)
			else:
				show_boxes()
		
func hide_UI(show=false):
	if show:
		hide_vnui = false
	else:
		hide_vnui = ! hide_vnui 
	if hide_vnui:
		QM.visible = false
		hide_boxes()
		nvlBox.visible = false
		if self.nvl:
			dimming(Color(1,1,1,1))
	else:
		if not QM.hiding: QM.visible = true
		if self.nvl:
			nvlBox.visible = true
			if self.centered:
				dimming(vn.CENTER_DIM)
			else:
				dimming(vn.NVL_DIM)
		else:
			show_boxes()


func hide_boxes():
	get_node('VNUI/textBox').visible = false
	get_node('VNUI/nameBox').visible = false
	
func show_boxes():
	if not hide_all_boxes:
		get_node('VNUI/textBox').visible = true
		get_node('VNUI/nameBox').visible = true
		
func bg_change(path: String):
	var bg_path = vn.BG_DIR + path
	bg.texture = load(bg_path)

func dimming(c : Color):
	get_node('background').modulate = c
	stage.set_modulate_4_all(c)

func system(ev : Dictionary):
	if ev.size() != 1:
		vn.error("System event only receives one field.")
	
	var k = ev.keys()[0]
	var temp = ev[k].split(" ")
	match temp[0]:
		"auto": # This doesn't have on.
			# Simply turns off dialog auto forward.
			if temp[1] == "off":
				QM.reset_auto()
			
		"skip": # same as above
			if temp[1] == "off":
				QM.reset_skip()
		
		"save_load", "SL":
			if temp[1] == "on":
				QM.get_node("saveButton").disabled = false
				QM.get_node("QsaveButton").disabled = false
				QM.get_node("loadButton").disabled = false
			elif temp[1] == "off":
				QM.get_node("saveButton").disabled = true
				QM.get_node("QsaveButton").disabled = true
				QM.get_node("loadButton").disabled = true
				
		# The above 3 are not included in all.
		
		"right_click", "RC":
			if temp[1] == "on":
				self.no_right_click = false
			elif temp[1] == "off":
				self.no_right_click = true
				
		"quick_menu", "QM":
			if temp[1] == "on":
				QM.visible = true
				QM.hiding = false
			elif temp[1] == "off":
				QM.visible = false
				QM.hiding = true
		
		"boxes":
			if temp[1] == "on":
				hide_all_boxes = false
				show_boxes()
			elif temp[1] == "off":
				hide_all_boxes = true
				hide_boxes()
				
		"scroll":
			if temp[1] == "on":
				no_scroll = false
			elif temp[1] == "off":
				no_scroll = true
				
		"all":
			if temp[1] == "on":
				hide_all_boxes = false
				no_scroll = false
				QM.visible = true
				QM.hiding = false
				self.no_right_click = false
				show_boxes()
			elif temp[1] == "off":
				hide_all_boxes = true
				no_scroll = true
				QM.visible = false
				QM.hiding = true
				no_right_click = true
				hide_boxes()

	auto_load_next()
	
#-------------------- Extra Preprocessing ----------------------
func parse_loc(loc, ev = {}) -> Vector2:
	if typeof(loc) == 5: # 5 = Vector2
		return loc
	
	var vec = loc.split(" ")
	if vec.size() != 2 or not vec[0].is_valid_float() or not vec[1].is_valid_float():
		vn.error("Expecting value of the form \"float1 float2\" after loc.", ev)
	
	return Vector2(float(vec[0]), float(vec[1]))
	
func parse_dir(dir, ev = {}) -> Vector2:
	if dir in vn.DIRECTION:
		return vn.DIRECTION[dir]
	else:
		return parse_loc(dir, ev)

func parse_color(color, ev = {}) -> Color:
	if typeof(color) == 14: # 14 = color
		return color
	if color.is_valid_html_color():
		return Color(color)
	else:
		var vec = color.split(" ")
		var s = vec.size()
		var temp2 = []
		if s == 3 or s == 4:
			for i in s:
				if vec[i].is_valid_float():
					temp2.append(float(vec[i]))
				else:
					vn.error("Script Editor: Expecting float values for color.")
					# we are able to finish, that means all entries valid
			
			if s == 3:
				return Color(temp2[0], temp2[1], temp2[2])
			else:
				return Color(temp2[0], temp2[1], temp2[2], temp2[3])
		else:
			vn.error("Expecting value of the form flaot1 float2 float3( float4) after color.", ev)
			return Color()

func parse_true_false(truth, ev = {}) -> bool:
	if typeof(truth) == 1: # 1 = bool
		return truth
	if truth == "true":
		return true
	elif truth == "false":
		return false
	else:
		vn.error("Expecting true or false after this indicator.", ev)
		return false

func preprocess(words : String) -> String:
	# preprocess the input to see if there are any special things
	dialogbox.nw = false
	nvlBox.nw = false
	var leng = words.length()
	var output = ''
	var i = 0
	while i < leng:
		var c = words[i]
		var inner = ""
		if c == '[':
			i += 1
			while words[i] != ']':
				inner += words[i]
				i += 1
				if i >= leng:
					vn.error("Please do not use square brackets " +\
					"unless for bbcode and display dvar purposes.")
					
			match inner:
				"nw":
					if not vn.skipping:
						if self.nvl:
							nvlBox.nw = true
						else:
							dialogbox.nw = true
				"sm": output += ";"
				"dc": output += "::"
				"nl": output += "\n"
				_: 
					if has_dvar(inner):
						output += str(vn.dvar[inner])
					else:
						output += '[' + inner + ']'
						
		else:
			output += c
			
		i += 1
	
	return output
