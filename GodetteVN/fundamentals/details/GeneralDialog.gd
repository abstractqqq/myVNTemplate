extends Node2D
class_name GeneralDialog

export(String, FILE, "*.json") var dialog_json 
export(bool) var debug_mode
export(String) var scene_description

export(String, FILE, "*.tscn") var choice_bar = ''
export(String, FILE, "*.tscn") var float_text = ''

# Core data
var current_index : int = 0
var current_block = null
var all_blocks = null
var all_choices = null
var all_conditions = null
# Other
var latest_voice = null
var idle : bool = false
var _nullify_prev_yield : bool = false
# Only used in rollback
var _cur_bgm = null
# State controls
var nvl : bool = false
var centered : bool = false
var waiting_acc : bool = false
var waiting_cho : bool = false
var just_loaded : bool = false
var hide_all_boxes : bool = false
var hide_vnui : bool = false
var no_scroll : bool = false
var no_right_click : bool = false
var one_time_font_change : bool = false
#
var _propagate_dvar_list = {}
#----------------------
const cps_dict = {'fast':50, 'slow':25, 'instant':0, 'slower':10}
# Important components
onready var bg = $background
onready var vnui = $VNUI
onready var QM = vnui.get_node('quickMenu')
onready var dialogbox = vnui.get_node('textBox/dialog')
onready var speaker = vnui.get_node('nameBox/speaker')
onready var choiceContainer = vnui.get_node('choiceContainer')
onready var camera = screen.get_node('camera')

var nvlBox = null # dynamic. The NVL component is only instanced when in nvl mode.
#-----------------------
# signals
signal player_accept(npv)
signal dvar_set

#--------------------------------------------------------------------------------
func _ready():
	fileRelated.load_config()
	var _error = self.connect("player_accept", self, '_yield_check')

func set_bg_path(node_path:String):
	bg = get_node(node_path)
	
func _input(ev):
	if ev.is_action_pressed('vn_rollback') and (waiting_acc or idle) and not vn.inSetting \
	and not vn.inNotif and not vn.skipping:
		QM.reset_auto_skip()
		if game.rollback_records.size() >= 1:
			waiting_acc = false
			idle = false
			screen.removeLasting()
			screen.weather_off()
			sideImageChange({},false)
			camera.reset_zoom()
			waiting_cho = false
			centered = false
			nvl_off()
			for n in choiceContainer.get_children():
				n.queue_free()
			generate_nullify()
			game.history.pop_back()
			on_rollback()
			return
		else: # Show to readers that they cannot rollback further
			notif.show('rollback')
			
	if ev.is_action_pressed('vn_upscroll') and not vn.inSetting and not vn.inNotif and not no_scroll:
		QM._on_historyButton_pressed()
		return
	# QM hiding means that quick menu is being hidden. If that is the case,
	# then the user probably wants to disable access to main menu too.
	if ev.is_action_pressed('ui_cancel') and not vn.inSetting and not vn.inNotif and not QM.hiding:
		add_child(vn.MAIN_MENU.instance())
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
					QM.reset_auto_skip()
				else:
					return
			else:
				if not vn.noMouse and not vn.inNotif and not vn.inSetting:
					check_dialog()
		else: # not mouse
			if vn.auto_on or vn.skipping:
				QM.reset_auto_skip()
			elif not vn.inNotif and not vn.inSetting:
				check_dialog()
	
#--------------------------------- Interpretor ----------------------------------

func load_event_at_index(ind : int) -> void:
	if ind >= current_block.size():
		print("IMPORTANT: THERE IS NO PROPER ENDING. GOING BACK TO MAIN MENU.")
		change_scene_to(vn.ending_scene_path)
	else:
		if debug_mode:print("Debug: current event index is " + str(current_index))
		interpret_events(current_block[ind])

func interpret_events(event):
	# Try to keep the code under each case <=3 lines
	# Also keep the number of cases small. Try to repeat the use of key words.
	var ev = event.duplicate(true)
	if debug_mode: 
		var debugger = screen.get_node('debugger')
		var msg = "Debug :" + str(ev)
		debugger.text = msg 
		print(msg)
	
	# Pre-parse, keep this at minimum
	if ev.has('loc'): ev['loc'] = _parse_loc(ev['loc'], ev)
	if ev.has('params'): ev['params'] = _parse_params(ev['params'],ev)
	if ev.has('color'): ev['color'] = _parse_color(ev['color'], ev)
	if ev.has('nvl'):
		if (typeof(ev['nvl'])!=1) and ev['nvl'] != 'clear': 
			ev['nvl'] = _parse_true_false(ev['nvl'], ev)
	if ev.has('scale'): ev['scale'] = _parse_loc(ev['scale'], ev)
	if ev.has('dir'): ev['dir'] = _parse_dir(ev['dir'], ev)
	# End of pre-parse. Actual match event
	match ev:
		{"condition", "then", "else",..}: conditional_branch(ev)
		{"condition",..}:
			if check_condition(ev['condition']):
				ev.erase('condition')
				continue
			else: # condition fails.
				auto_load_next()
		{"screen",..}: screen_effects(ev)
		{"bg",..}: change_background(ev)
		{"chara",..}: character_event(ev)
		{"weather"}: change_weather(ev['weather'])
		{"camera", ..}: camera_effect(ev)
		{"express"}: express(ev['express'])
		{"bgm",..}: play_bgm(ev)
		{'audio',..}: play_sound(ev)
		{'dvar'}: set_dvar(ev)
		{'sfx',..}: sfx_player(ev)
		{'then',..}: then(ev)
		{'extend', ..}, {'ext', ..}:extend(ev)
		{'premade'}:
			if debug_mode: print("PREMADE EVENT:")
			interpret_events(fun.call_premade_events(ev['premade']))
		{"system"},{"sys"}: system(ev)
		{'side'}: sideImageChange(ev)
		{'choice',..}: generate_choices(ev)
		{'wait'}: wait(ev['wait'])
		{'nvl'}: set_nvl(ev)
		{'GDscene'}: change_scene_to(ev['GDscene'])
		{'history', ..}: history_manipulation(ev)
		{'float', 'wait',..}: flt_text(ev)
		{'voice'}:voice(ev['voice'])
		{'id'}, {}:auto_load_next()
		{'center',..}: set_center(ev)
		_: speech_parse(ev)
				
			
#----------------------- on ready, new game, load, set up, end -----------------
func start_scene(blocks : Dictionary, choices: Dictionary, conditions: Dictionary, load_instruction : String) -> void:
	all_blocks = blocks
	all_choices = choices
	all_conditions = conditions
	dialogbox.connect('load_next', self, 'trigger_accept')
	if load_instruction == "new_game":
		current_index = 0
		if blocks.has("starter"):
			current_block = blocks['starter'] # this is an array of events
		else:
			vn.error("Dialog must have a block called starter.")
		game.currentIndex = 0
		game.currentBlock = 'starter' # this is the name corresponding to the array
	elif load_instruction == "load_game":
		game.load_instruction = "new_game" # reset after loading
		current_index = game.currentIndex
		current_block = all_blocks[game.currentBlock]
		load_playback(game.playback_events)
	else:
		push_error("Unknow loading instruction")
	
	if music.bgm != '':
		_cur_bgm = music.bgm
	if debug_mode: print("Debug: current block is " + game.currentBlock)
	load_event_at_index(current_index)


func auto_load_next():
	current_index += 1
	game.currentIndex = current_index
	if vn.skipping:
		yield(get_tree(), "idle_frame")
		if not game.checkSkippable():
			vn.skipping = false
			QM.reset_skip()
	
	load_event_at_index(current_index)

#------------------------ Related to Dialog Progression ------------------------
func set_nvl(ev: Dictionary, auto_forw = true):
	if typeof(ev['nvl']) == TYPE_BOOL:
		self.nvl = ev['nvl']
		if self.nvl:
			if ev.has('font'):
				nvl_on(ev['font'])
			else:
				nvl_on()
		else:
			nvl_off()
		
		if auto_forw: auto_load_next()
	elif ev['nvl'] == 'clear':
		nvlBox.clear()
		if auto_forw: auto_load_next()
	else:
		vn.error('nvl expects a boolean or the keyword clear.', ev)
	
func set_center(ev: Dictionary):
	self.centered = true
	if ev.has('font'):
		set_nvl({'nvl': true,'font':ev['font']}, false)
	else:
		set_nvl({'nvl': true}, false)
	var u = ''
	if ev.has('who'): u = ev['who']
	if ev.has('speed'):
		say(u, ev['center'], ev['speed'])
	else:
		say(u, ev['center'])
	var _has_voice = _check_latest_voice(ev) # not gonna be used, thus _

func speech_parse(ev : Dictionary) -> void:
	# Voice first
	var _has_voice = _check_latest_voice(ev)
	# one time font change
	one_time_font_change = ev.has('font')
	if one_time_font_change:
		var path = vn.FONT_DIR + ev['font']
		dialogbox.add_font_override('normal_font', load(path))

	# Speech
	var combine = "wwttff"
	for k in ev.keys(): # k is not voice, not speed, means it has to be "uid expression"
		if k != 'voice' and k != 'speed':
			combine = k # combine=unique_id and expression combined
			break
	if combine == "wwttff": # for loop ends without setting combine
		vn.error("Speech event requires a valid character/narrator." ,ev)
	
	if ev.has('speed'):
		if (ev['speed'] in cps_dict.keys()):
			say(combine, ev[combine], cps_dict[ev['speed']])
		else:
			say(combine, ev[combine])
	else:
		say(combine, ev[combine])

func generate_choices(ev: Dictionary):
	# make a say event
	if self.nvl: nvl_off()
	else:
		dialogbox.text = ""
		speaker.text = ""
	if vn.auto_on or vn.skipping:
		QM.disable_skip_auto()
	
	var _has_voice = _check_latest_voice(ev)
	one_time_font_change = ev.has('font')
	if one_time_font_change:
		var path = vn.FONT_DIR + ev['font']
		dialogbox.add_font_override('normal_font', load(path))
	var combine = ""
	for k in ev.keys():
		if k != 'id' and k != 'choice' and k != 'voice':
			combine = k
			break
	if combine != "":
		say(combine, ev[combine], 0, true)
	
	if ev['choice'] == '' or ev['choice'] == 'url': 
		# This is for url (in-line, textbased) choices
		return
	# Actual choices
	var options = all_choices[ev['choice']]
	waiting_cho = true
	for i in options.size():
		var ev2 = options[i]
		if ev2.size()>2 : 
			vn.error('Only size 1 or 2 dict will be accepted as choice.')
		elif ev2.size() == 2:
			if ev2.has('condition'):
				if not check_condition(ev2['condition']):
					continue # skip to the next choice if condition not met
			else:
				vn.error('If a choice is size 2, then it has to have a condition.')
					
		var choice_text = ''
		for k in ev2.keys():
			if k != "condition":
				choice_text = k # grab the key not equal to condition
				break
		
		var choice_ev = ev2[choice_text] # the choice action
		choice_text = fun.dvarMarkup(choice_text)
		var choice = load(choice_bar).instance()
		choice.setup_choice_event(choice_text, choice_ev)
		choice.connect("choice_made", self, "on_choice_made")
		choiceContainer.add_child(choice)
		# waiting for user choice
		
	choiceContainer.visible = true # make it visible now
	
func say(combine : String, words : String, cps = 50, ques = false) -> void:
	var temp = combine.split(" ") # temp[0] = uid, temp[1] = expression
	var uid = chara.forward_uid(temp[0])
	if temp.size() == 2:
		stage.change_expression(uid, temp[1])
		
	words = preprocess(words)
	if vn.skipping: cps = 0
	if self.nvl:
		if just_loaded:
			just_loaded = false
			if centered:
				nvlBox.set_dialog(uid, words, cps, true)
			else:
				nvlBox.visible_characters = nvlBox.text.length()
		else:
			if centered:
				nvlBox.set_dialog(uid, words, cps, true)
				game.nvl_text = ''
			else:
				nvlBox.set_dialog(uid, words, cps)
				game.nvl_text = nvlBox.bbcode_text
			if latest_voice == null:
				game.history.push_back([uid, nvlBox.get_text()])
			else:
				game.history.push_back([uid, nvlBox.get_text(), latest_voice])
	else:
		if not _hide_namebox(uid):
			var info = chara.all_chara[uid]
			speaker.set("custom_colors/default_color", info["name_color"])
			speaker.bbcode_text = info["display_name"]
			if info['font'] and not nvl and not one_time_font_change:
				var fonts = {'normal_font': info['normal_font'],
				'bold_font': info['bold_font'],
				'italics_font':info['italics_font'],
				'bold_italics_font':info['bold_italics_font']}
				dialogbox.set_chara_fonts(fonts)
			elif not one_time_font_change:
				dialogbox.reset_fonts()
		
		if just_loaded:
			dialogbox.set_dialog(words, 50)
			just_loaded = false
		else:
			dialogbox.set_dialog(words, cps)
			var new_text = dialogbox.get_text()
			if latest_voice == null:
				game.history.push_back([uid, new_text])
			else:
				game.history.push_back([uid, new_text, latest_voice])
				
			game.playback_events['speech'] = new_text
		
		stage.set_highlight(uid)
	# wait for ui_accept if this is not a question
	waiting_acc = true
	wait_for_accept(ques)
	# If this is a question, then displaying the text is all we need.


func extend(ev:Dictionary):
	# Cannot use extend with a choice, extend doesn't support font
	if game.playback_events['speech'] == '' or self.nvl:
		print("Warning: you're getting his warning either because you're in nvl mode")
		print("Or because you're using extend without a previous speech event.")
		print("In either case, nothing is done.")
		auto_load_next()
	else:
		# get previous speaker from history
		# you will get an error by using extend as the first sentence
		var prev_speaker = game.history[game.history.size()-1][0]
		if not _hide_namebox(prev_speaker):
			var info = chara.all_chara[prev_speaker]
			speaker.set("custom_colors/default_color", info["name_color"])
			speaker.bbcode_text = info["display_name"]
			
		var ext = 'extend'
		for k in ev.keys():
			if k == "ext":
				ext = 'ext'
				break
		
		var words = preprocess(ev[ext])
		var cps = 50
		if ev.has('speed'):
			if (ev['speed'] in cps_dict.keys()):
				cps = cps_dict[ev['speed']]
		
		if _check_latest_voice(ev):
			game.history.push_back([prev_speaker, words, latest_voice])
		else:
			game.history.push_back([prev_speaker, words])
			
		if just_loaded:
			just_loaded = false
			dialogbox.set_dialog(game.playback_events['speech'], 50)
			game.history.pop_back()
		else:
			dialogbox.bbcode_text = game.playback_events['speech']
			dialogbox.set_dialog(words, cps, true)
			game.playback_events['speech'] += " " + words
			
		stage.set_highlight(prev_speaker)
		# wait for accept
		waiting_acc = true
		wait_for_accept(false)

func wait_for_accept(ques:bool = false):
	if not ques:
		yield(self, "player_accept")
		if not _nullify_prev_yield:
			game.makeSnapshot()
			music.stop_voice()
			if centered:
				nvl_off()
				centered = false
			if not self.nvl: stage.remove_highlight()
			waiting_acc = false
			auto_load_next()


#------------------------ Related to Music and Sound ---------------------------
func play_bgm(ev : Dictionary, auto_forw=true) -> void:
	var path = ev['bgm']
	if (path == "" or path == "off") and ev.size() == 1:
		music.stop_bgm()
		game.playback_events['bgm'] = {'bgm':''}
		if auto_forw: auto_load_next()
		return
		
	#if path == "pause":
	#	music.pause_bgm()
	#	auto_load_next()
	#	return
	#elif path == "resume":
	#	music.resume_bgm()
	#	auto_load_next()
	#	return
		
	# Deal with fadeout first
	if path == "" and ev.size() > 1: # must be a fadeout
		if ev.has('fadeout'):
			music.fadeout(ev['fadeout'])
			game.playback_events['bgm'] = {}
			if auto_forw: auto_load_next()
			return
		else:
			vn.error('If fadeout is intended, please supply a time. Otherwise, unknown '+\
			'keyword format.', ev)
			
	# Now we're sure it's either play bgm or fadein bgm
	var vol = 0
	if ev.has('vol'): vol = ev['vol']
	_cur_bgm = path
	music.bgm = path
	var music_path = vn.BGM_DIR + path
	if not ev.has('fadein'): # has path or volume
		music.play_bgm(music_path, vol)
		game.playback_events['bgm'] = ev
		if auto_forw: auto_load_next()
		return
			
	if ev.has('fadein'):
		music.fadein(music_path, ev['fadein'], vol)
		game.playback_events['bgm'] = ev
		if auto_forw: auto_load_next()
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
	
		
func voice(path:String, auto_forw:bool = true) -> void:
	var voice_path = vn.VOICE_DIR + path
	music.play_voice(voice_path)
	if auto_forw: auto_load_next()
	
#------------------- Related to Background and Godot Scene Change ----------------------

func change_background(ev : Dictionary, auto_forw=true) -> void:
	var path = ev['bg']
	if ev.size() == 1 or vn.skipping or vn.inLoading:
		bg.bg_change(path)
	else:
		var eff_name = 'wwttff'
		for n in ev.keys():
			if n in vn.TRANSITIONS:
				eff_name = n
				break
		if eff_name == 'wwttff':
			print("Error at " + str(ev))
			push_error("Unknown transition type given in bg change event.")
			
		var eff_dur = float(ev[eff_name])/2 # transition effect total duration / 2
		var color = Color.black
		if ev.has('color'): color = ev['color']
		hide_boxes()
		QM.visible = false
		screen.in_transition(eff_name, color, eff_dur)
		yield(screen, "transition_mid_point_reached")
		bg.bg_change(path)
		screen.out_transition(eff_name, color, eff_dur)
		yield(screen, "transition_finished")
		show_boxes()
		if not QM.hiding: QM.visible = true
	
	if !vn.inLoading and auto_forw:
		game.playback_events['bg'] = path
		auto_load_next()

func change_scene_to(path : String):
	stage.remove_chara('absolute_all')
	stage.reset_sideImage()
	change_weather('', false)
	QM.reset_auto_skip()
	fileRelated.write_to_config()
	if path == vn.title_screen_path:
		game.rollback_records = []
		music.stop_bgm()
	if path == "free":
		game.rollback_records = []
		self.queue_free()
	elif path == 'idle':
		idle = true
	else:
		game.rollback_records = []
		var error = get_tree().change_scene(vn.ROOT_DIR + path)
		if error == OK:
			self.queue_free()

#------------------------------ Related to Dvar --------------------------------
func set_dvar(ev : Dictionary) -> void:
	var splitted = fun.break_line(ev['dvar'], '=')
	var left = splitted[0].strip_edges()
	var right = splitted[1].strip_edges()
	if vn.dvar.has(left):
		if typeof(vn.dvar[left])== TYPE_STRING:
			# If we get string, just set it to RHS
			vn.dvar[left] = right
		elif right == "true" or right == "True":
			vn.dvar[left] = true
		elif right == "false" or right == "False":
			vn.dvar[left] = false
		else:
			vn.dvar[left] = fun.calculate(right)
			
	else:
		vn.error("Dvar {0} not found".format({0:left}) ,ev)
	
	emit_signal("dvar_set")
	propagate_dvar_calls(left)
	auto_load_next()
	
func check_condition(cond_list) -> bool:
	if typeof(cond_list) == 4: # if this is a string, not a list
		cond_list = [cond_list]
	
	var final_result = true # start by assuming final_result is true
	var is_or = false
	while cond_list.size() > 0:
		var result = false
		var cond = cond_list.pop_front()
		if all_conditions.has(cond):
			cond = all_conditions[cond]
		if typeof(cond) == 4: # string, so do the regular thing
			if cond == "or" or cond == "||":
				is_or = true
				continue
			elif vn.dvar.has(cond) and typeof(vn.dvar[cond]) == 1: # 1 for bool
				result = vn.dvar[cond]
				final_result = _a_what_b(is_or, final_result, result)
				is_or = false
				continue

			var parsed = split_condition(cond)
			var front_var = parsed[0]
			var rel = parsed[1]
			var back_var = parsed[2]
			front_var = _parse_var(front_var)
			back_var = _parse_var(back_var)
			match rel:
				"=": result = (front_var == back_var)
				"==": result = (front_var == back_var)
				"<=": result = (front_var <= back_var)
				">=": result = (front_var >= back_var)
				"<": result = (front_var < back_var)
				">": result = (front_var > back_var)
				"!=": result = (front_var != back_var)
				_: vn.error('Unknown Relation ' + rel)
			
			final_result = _a_what_b(is_or, final_result, result)
		elif typeof(cond) == 19: # array type
			final_result = _a_what_b(is_or, final_result, check_condition(cond))
		else:
			vn.error("Unknown entry in a condition array.")

		is_or = false
	# If for loop ends, then all conditions must be passed. 
	return final_result

func _parse_var(st:String):
	if st == "true":
		return true
	elif st == "false":
		return false
	else:
		return dvar_or_float(st)
		
func _a_what_b(is_or:bool, a:bool, b:bool)->bool:
	if is_or:
		return (a or b)
	else:
		return (a and b)
#--------------- Related to transition and other screen effects-----------------
func screen_effects(ev: Dictionary, auto_forw=true):
	var temp = ev['screen'].split(" ")
	var ef = temp[0]
	match ef:
		"", "off": 
			screen.removeLasting()
			game.playback_events.erase('screen')
		"tint": tint(ev)
		"tintwave": tint(ev)
		"flashlight": flashlight(ev)
		_:
			if temp.size()==2 and not vn.skipping:
				var mode = temp[1]
				var c = Color.black
				var t = 1
				if ev.has('time'): t = ev['time']
				if ev.has('color'): c = ev['color']
				if ef in vn.TRANSITIONS:
					if mode == "out": # this might be a bit counter-intuitive
						# but we have to stick with this
						screen.in_transition(ef,c,t)
						yield(screen, "transition_mid_point_reached")
					elif mode == "in":
						screen.out_transition(ef,c,t)
						yield(screen, "transition_finished")
				screen.reset()
	
	if !vn.inLoading and auto_forw: auto_load_next()

func flashlight(ev:Dictionary):
	var sc = Vector2(1,1) # Default value
	if ev.has('scale'): sc = ev['scale']
	screen.flashlight(sc)
	game.playback_events['screen'] = ev

#func fadein(time : float, auto_forw:bool = true) -> void:
#	clear_boxes()
#	if not self.nvl: show_boxes()
#	QM.visible = false
#	if not vn.skipping:
#		screen.play_fade_in(Color.black, time)
#		yield(get_tree().create_timer(time), "timeout")
#	
#	if not QM.hiding: QM.visible = true
#	if auto_forw: auto_load_next()
	
#func fadeout(time : float, auto_forw:bool = true) -> void:
#	clear_boxes()
#	hide_boxes()
#	QM.visible = false
#	if not vn.skipping:
#		screen.play_fade_out(Color.black, time)
#		yield(get_tree().create_timer(time), "timeout")
#	if not QM.hiding: QM.visible = true
#	if not self.nvl: show_boxes()
#	if auto_forw: auto_load_next()

func tint(ev : Dictionary) -> void:
	game.playback_events['screen'] = ev
	var time = 1
	if ev.has('time'): 
		time = ev['time']
	if ev.has('color'):
		if ev['screen'] == 'tintwave':
			screen.tintWave(ev['color'], time)
		elif ev['screen'] == 'tint':
			screen.tint(ev['color'], time)
			# When saving to playback, no need to replay the fadein effect
			ev['time'] = 0.05
		
	else:
		vn.error("Tint or tintwave requires the color field.", ev)

# Scene animations/special effects
func sfx_player(ev : Dictionary) -> void:
	var target_scene = load(vn.ROOT_DIR + ev['sfx']).instance()
	if ev.has('loc'): target_scene.position = ev['loc']
	if ev.has('params'):target_scene.params = ev['params']
	add_child(target_scene)
	if ev.has('anim'):
		var anim = target_scene.get_node('AnimationPlayer')
		if anim.has_animation(ev['anim']):
			anim.play(ev['anim'])
		else:
			vn.error("Animation not found.", ev)
			assert(false)

	auto_load_next()

func camera_effect(ev : Dictionary) -> void:
	var ef_name = ev['camera']
	match ef_name:
		"vpunch": if not vn.skipping: camera.vpunch()
		"hpunch": if not vn.skipping: camera.hpunch()
		"reset": 
			camera.reset_zoom()
			game.playback_events.erase('camera')
		"zoom":
			QM.reset_skip()
			if ev.has('scale'):
				var time = 1
				var offset = Vector2(0,0)
				var type = 'linear'
				if ev.has('time'): time = ev['time']
				if ev.has('type'): type = ev['type']
				if ev.has('loc'): offset = ev['loc']
				if type == 'instant' or vn.skipping:
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
				print("Wrong camera event format: " + str(ev))
				push_error("Camera move expects a loc and time, and type (optional)")
		"shake":
			if not vn.skipping:
				var amount = 250
				var time = 2
				if ev.has('amount'): amount = ev['amount']
				if ev.has('time'): time = ev['time']
				camera.shake(amount, time)
		_:
			print("Unknown camera event: " + str(ev))
			push_error("Camera effect not found.")
			
	auto_load_next()
#----------------------------- Related to Character ----------------------------
func character_event(ev : Dictionary) -> void:
	# For character event, auto_load_next should be considered within
	# each individual method.
	var temp = ev['chara'].split(" ")
	if temp.size() != 2:
		vn.error('Expecting a uid and an effect name separated by a space.', ev)
	var uid = chara.forward_uid(temp[0]) # uid of the character
	var ef = temp[1] # what character effect
	if uid == 'all' or stage.is_on_stage(uid):
		match ef: # jump and shake will be ignored during skipping
			"shake", "vpunch", "hpunch": 
				if vn.skipping : 
					auto_load_next()
				else:
					if ef == "vpunch":
						character_shake(uid, ev, 1)
					elif ef == "hpunch":
						character_shake(uid, ev, 2)
					else:
						character_shake(uid, ev, 0)
			"add": character_add(uid, ev)
			"spin": character_spin(uid,ev)
			"jump": 
				if vn.skipping : 
					auto_load_next()
				else:
					character_jump(uid, ev)
			'move': 
				if uid == 'all': 
					print("Warning: Attempting to move all character at once.")
					print("This is currently not allowed and this event is ignored.")
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

# This method is here to fill in default values
func character_shake(uid:String, ev:Dictionary, mode:int=0) -> void:
	var amount = 250
	var time = 2
	if ev.has('amount'): amount = ev['amount']
	if ev.has('time'): time = ev['time']
	stage.shake(uid, amount, time, mode)
	auto_load_next()
	

func express(combine : String) -> void:
	var temp = combine.split(" ")
	var uid = chara.forward_uid(temp[0])
	if temp.size() > 2 or temp.size() == 0:
		vn.error("Wrong express format.")
	elif temp.size() == 1:
		temp.push_back("")
	
	stage.change_expression(uid,temp[1])
	auto_load_next()

# This method is here to fill in default values
func character_jump(uid : String, ev : Dictionary) -> void:
	var amount = 80
	var time = 0.25
	var dir = vn.DIRECTION['up']
	if ev.has('amount'): amount = ev['amount']
	if ev.has('time'): time = ev['time']
	if ev.has('dir'): dir = ev['dir']
	stage.jump(uid, dir, amount, time)
	auto_load_next()
	
# This method is here to fill in default values
func character_fadeout(uid: String, ev:Dictionary):
	var time = 1
	if ev.has('time'): time = ev['time']
	stage.fadeout(uid, time)
	yield(get_tree().create_timer(time), 'timeout')
	auto_load_next()

# This method is here to fill in default values
func character_move(uid:String, ev:Dictionary):
	var type = "linear"
	var expr = ''
	if ev.has('expression'): expr = ev['expression']
	if ev.has('type'): type = ev['type']
	if ev.has('loc'):
		if type == 'instant' or vn.skipping:
			stage.change_pos(uid, ev['loc'], expr)
		else:
			var time = 1
			if ev.has('time'):time = ev['time']
			stage.change_pos_2(uid, ev['loc'], time, type, expr)
		auto_load_next()
	else:
		vn.error("Character move expects a loc.", ev)

func character_add(uid:String, ev:Dictionary):
	if ev.has('path') and ev.has('at'):
		stage.add_to_chara_at(uid, ev['at'], vn.ROOT_DIR + ev['path'])
		auto_load_next()
	else:
		vn.error('Character add expects a path and an "at".', ev)
# This method is here to fill in default values
func character_spin(uid:String, ev:Dictionary):
	var sdir : int = 1
	var deg = 360.0
	var time = 1
	var type = "linear"
	if ev.has('type'): type = ev['type']
	if ev.has('sdir'): time = int(ev['sdir'])
	if ev.has('deg'): deg = ev['deg']
	if ev.has('time'): time = ev['time']
	stage.spin(uid, deg, time, sdir, type)
	auto_load_next()
#--------------------------------- Weather -------------------------------------
func change_weather(we:String, auto_forw = true):
	screen.show_weather(we) # If given weather doesn't exist, nothing will happen
	if !vn.inLoading:
		if we == "":
			game.playback_events.erase('weather')
		else:
			game.playback_events['weather'] = {'weather':we}
		
		if auto_forw: auto_load_next()

#--------------------------------- History -------------------------------------
func history_manipulation(ev: Dictionary):
	# WARNING: 
	# THIS DOES NOT WORK WELL WITH CURRENT IMPLEMENTATION OF ROLLBACK
	var what = ev['history']
	if what == "push":
		if ev.size() != 2:
			print("History event format error " + str(ev))
			push_error("History push should have only two fields.")
		
		for k in ev.keys():
			if k != 'history':
				game.history.push_back([k, fun.dvarMarkup(ev[k])])
				break
		
	elif what == "pop":
		game.history.pop_back()
	else:
		print("History event format error " + str(ev))
		push_error("History expects only push or pop.")
		
	auto_load_next()
	
#--------------------------------- Utility -------------------------------------
func conditional_branch(ev : Dictionary) -> void:
	if check_condition(ev['condition']):
		change_block_to(ev['then'],0)
	else:
		change_block_to(ev['else'],0)

func then(ev : Dictionary) -> void:
	if ev.has('target id'):
		change_block_to(ev['then'], 1 + get_target_index(ev['then'], ev['target id']))
	else:
		change_block_to(ev['then'],0)
		
func change_block_to(bname : String, bindex:int = 0) -> void:
	idle = false
	if all_blocks.has(bname):
		current_block = all_blocks[bname]
		if bindex >= current_block.size()-1:
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
		push_error('Cannot find block with the name ' + bname)

func get_target_index(bname : String, target_id):
	for i in range(all_blocks[bname].size()):
		var d = all_blocks[bname][i]
		if d.has('id') and (d['id'] == target_id):
			return i
	push_error('Cannot find event with id ' + str(target_id) + ' in ' + bname)
	
func sideImageChange(ev:Dictionary, auto_forw:bool = true):
	if ev.size() == 0:
		return
	var path = ev['side']
	var sideImage = stage.get_node('other/sideImage')
	sideImage.position = Vector2(-35,530) # by default
	if path == "":
		sideImage.texture = null
		game.playback_events.erase('side')
	else:
		sideImage.texture = load(vn.SIDE_IMAGE+path)
		game.playback_events['side'] = ev
		if ev.has("scale"):
			# if you want to limit scale to 0-1 for both x and y, use
			# fun.correct_scale(ev['scale'])
			sideImage.scale = ev['scale']
		if ev.has('loc'):
			sideImage.position = ev['loc']
	if auto_forw: auto_load_next()

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
		emit_signal("player_accept", false)

func generate_nullify():
	# Suppose you're in an invetigation scene. Speaker A says something, then 
	# the dialog will enter an yield state and if a player_accept signal comes in, 
	# it will continue. If the signal is generated by generate_nullify(), then
	# the previous yield state will be 'nullified'.
	emit_signal("player_accept", true)

func clear_boxes():
	speaker.bbcode_text = ''
	dialogbox.bbcode_text = ''

func wait(time : float) -> void:
	if just_loaded:
		just_loaded = false
	
	if vn.skipping:
		auto_load_next()
		return
	if time >= 0.1:
		time = stepify(time, 0.1)
		yield(get_tree().create_timer(time), "timeout")
		auto_load_next()
	else:
		print("Warning: wait time < 0.1s is ignored.")
		auto_load_next()

func on_choice_made(ev : Dictionary, allow_rollback = true) -> void:
	QM.enable_skip_auto()
	for n in choiceContainer.get_children():
		n.queue_free()
	
	if allow_rollback: # allow_rollback can only be set externally. Currently
		# there is no method in GeneralDialog that alters this value
		game.makeSnapshot()
	waiting_cho = false
	choiceContainer.visible = false
	if ev.size() == 0:
		auto_load_next()
	else:
		interpret_events(ev)

func _yield_check(npy : bool): # npy = nullily_previous_yield ?
	_nullify_prev_yield = npy

func on_rollback():
	var last = game.rollback_records.pop_back()
	vn.dvar = last['dvar']
	propagate_dvar_calls()
	game.currentSaveDesc = last['currentSaveDesc']
	game.currentIndex = last['currentIndex']
	game.currentBlock = last['currentBlock']
	game.playback_events = last['playback']
	chara.chara_name_patch = last['name_patches']
	chara.patch_display_names()
	current_index = game.currentIndex
	current_block = all_blocks[game.currentBlock]
	load_playback(game.playback_events, true)
	load_event_at_index(current_index)


func load_playback(play_back, RBM = false): # Roll Back Mode
	# print(play_back)
	vn.inLoading = true
	if play_back.has('bg'):
		bg.bg_change(play_back['bg'])
	if play_back['bgm'].size() > 0:
		var bgm = play_back['bgm']
		if RBM:
			if _cur_bgm != bgm['bgm']:
				play_bgm(bgm, false)
		else:
			play_bgm(play_back['bgm'], false)
	if play_back.has('screen'):
		screen_effects(play_back['screen'], false)
	if play_back.has('camera'):
		camera.set_camera(play_back['camera'])
	if play_back.has('weather'):
		change_weather(play_back['weather']['weather'], false)
	if play_back.has('side'):
		sideImageChange(play_back['side'], false)
	
	var onStageCharas = []
	for d in play_back['charas']:
		var dkeys = d.keys()
		var loc = d['loc']
		dkeys.erase('loc')
		var uid = dkeys[0]
		if RBM:
			onStageCharas.push_back(uid)
			if stage.is_on_stage(uid):
				stage.change_pos(uid, _parse_loc(loc))
				stage.change_expression(uid, d[uid])
			else:
				interpret_events({'chara': uid + ' join', 'loc': loc, 'expression': d[uid]})
		else:
			interpret_events({'chara': uid + ' join', 'loc': loc, 'expression': d[uid]})
	
	if RBM: stage.remove_on_rollback(onStageCharas)
	
	if play_back['nvl'] != '':
		nvl_on()
		game.nvl_text = play_back['nvl']
		nvlBox.bbcode_text = game.nvl_text
	
	vn.inLoading = false
	just_loaded = true

func split_condition(line:String):
	var arith_symbols = ['>','<', '=', '!', '+', '-', '*', '/']
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
	if vn.dvar.has(dvar):
		output = vn.dvar[dvar]
	elif dvar.is_valid_float():
		output = dvar.to_float()
	else:
		vn.error('Variable is not a dvar and is not a valid float.')
	return output

func flt_text(ev: Dictionary) -> void:
	var wt = ev['wait']
	ev['float'] = fun.dvarMarkup(ev['float'])
	var loc = Vector2(600,300)
	if ev.has('loc'): loc = ev['loc']
	var in_t = 1
	if ev.has('fadein'): in_t = ev['fadein']
	var f = load(float_text).instance()
	if ev.has('font') and ev['font'] != "" and ev['font'] != "default":
		f.set_font(vn.ROOT_DIR + ev['font'])
	if ev.has('dir'):
		var speed = 30
		if ev.has('speed'): speed = ev['speed']
		f.set_movement(ev['dir'], speed)
	self.add_child(f)
	if ev.has('time') and ev['time'] > wt:
		f.display(ev['float'], ev['time'], in_t, loc)
	else:
		f.display(ev['float'], wt, in_t, loc)
	
	var has_voice = _check_latest_voice(ev)
	if ev.has('hist') and (_parse_true_false(ev['hist'])):
		var who = ''
		if ev.has('who'): who = ev['who']
		if has_voice:
			game.history.push_back([who, ev['float'], latest_voice])
		else:
			game.history.push_back([who, ev['float']])
		
	wait(wt)

func nvl_off():
	show_boxes()
	dialogbox.get_node('autoTimer').start()
	if nvlBox != null:
		nvlBox.clear() # will queue free
	nvlBox = null
	get_node('background').modulate = Color(1,1,1,1)
	stage.set_modulate_4_all(Color(0.86,0.86,0.86,1))
	self.nvl = false

func nvl_on(center_font:String=''):
	stage.set_modulate_4_all(vn.DIM)
	if centered: nvl_off()
	clear_boxes()
	hide_boxes()
	dialogbox.get_node('autoTimer').stop()
	nvlBox = load(vn.DEFAULT_NVL).instance()
	nvlBox.connect('load_next', self, 'trigger_accept')
	vnui.add_child(nvlBox)
	nvlBox.get_node('autoTimer').start()
	if centered:
		nvlBox.center_mode()
		if center_font != '':
			nvlBox.add_font_override('normal_font', load(vn.ROOT_DIR+center_font))
		get_node('background').modulate = vn.CENTER_DIM
		stage.set_modulate_4_all(vn.CENTER_DIM)
	else:
		get_node('background').modulate = vn.NVL_DIM
		stage.set_modulate_4_all(vn.NVL_DIM)
	
	self.nvl = true

func trigger_accept():
	if not waiting_cho:
		emit_signal("player_accept", false)
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
		if self.nvl:
			nvlBox.visible = false
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
	hide_all_boxes = true
	get_node('VNUI/textBox').visible = false
	get_node('VNUI/nameBox').visible = false
	
func show_boxes():
	if hide_all_boxes:
		get_node('VNUI/textBox').visible = true
		get_node('VNUI/nameBox').visible = true
		hide_all_boxes = false
		
func _hide_namebox(uid:String):
	if not hide_all_boxes:
		get_node('VNUI/nameBox').visible = true
	if chara.all_chara.has(uid):
		var info = chara.all_chara[uid]
		if info.has('no_nb') and info['no_nb']:
			get_node('VNUI/nameBox').visible = false
			return true
			
	return false

# Check this event for latest voice... If there is a voice field,
# play the voice and then return true
func _check_latest_voice(ev:Dictionary):
	if ev.has('voice'):
		latest_voice = ev['voice']
		if not vn.skipping:
			voice(ev['voice'], false)
			return true
	else:
		latest_voice = null
	
	return false

func dimming(c : Color):
	get_node('background').modulate = c
	stage.set_modulate_4_all(c)


func register_dvar_propagation(method_name:String, dvar_name:String):
	if vn.dvar.has(dvar_name):
		_propagate_dvar_list[method_name] = dvar_name
	else:
		print("The dvar %s cannot be found. Nothing is done." % [dvar_name])

func propagate_dvar_calls(dvar_name:String=''):
	# propagate to call all methods that should be called when a dvar
	# is changed. 
	if dvar_name == '':
		for k in _propagate_dvar_list.keys():
			propagate_call(k, [vn.dvar[_propagate_dvar_list[k]]], true)
	else:
		for k in _propagate_dvar_list.keys():
			if _propagate_dvar_list[k] == dvar_name:
				propagate_call(k, [vn.dvar[dvar_name]], true)
				

func system(ev : Dictionary):
	if ev.size() != 1:
		print("Warning: wrong system event format for " + str(ev))
		push_error("System event only receives one field.")
	
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
				
		"clear": # clears the dialog box
			clear_boxes()
			
		"rollback", "roll_back" ,"RB":
			if temp[1] == "clear":
				game.rollback_records = []
			else:
				var splitted = fun.break_line(temp[1], '_')
				if splitted[0]=='clear' and splitted[1].is_valid_integer():
					var n = int(splitted[1])
					for _i in range(n):
						game.rollback_records.pop_back()
		"auto_save", "AS": # make a save, with 0 seconds delay, and save
			# at current index - 1 because at current index, the event is sys:auto_save
			fun.make_a_save("[Auto Save] ",0,1)
		"make_save", "MS":
			QM.reset_auto_skip()
			notif.show("make_save")
			var cur_notif = notif.get_current_notif()
			yield(cur_notif, "clicked")
		"save_load", "SL":
			if temp[1] == "on":
				QM.get_node("saveButton").disabled = false
				QM.get_node("QsaveButton").disabled = false
				QM.get_node("loadButton").disabled = false
			elif temp[1] == "off":
				QM.get_node("saveButton").disabled = true
				QM.get_node("QsaveButton").disabled = true
				QM.get_node("loadButton").disabled = true
				
		# The above are not included in all.
		
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
				show_boxes()
			elif temp[1] == "off":
				hide_boxes()
				
		"scroll":
			if temp[1] == "on":
				no_scroll = false
			elif temp[1] == "off":
				no_scroll = true
				
		"all":
			if temp[1] == "on":
				no_scroll = false
				QM.visible = true
				QM.hiding = false
				self.no_right_click = false
				show_boxes()
			elif temp[1] == "off":
				no_scroll = true
				QM.visible = false
				QM.hiding = true
				no_right_click = true
				hide_boxes()

	auto_load_next()
	
#-------------------- Extra Preprocessing ----------------------
func _parse_loc(loc, ev = {}) -> Vector2:
	if typeof(loc) == TYPE_VECTOR2: # 5 = Vector2
		return loc
	
	if typeof(loc) == TYPE_STRING and loc == "R":
		var v = get_viewport().size
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var rndv = Vector2(rng.randf_range(100, v.x-100),\
		rng.randf_range(80, v.y-80))
		return rndv
	
	var vec = loc.split(" ")
	if vec.size() != 2 or not vec[0].is_valid_float() or not vec[1].is_valid_float():
		vn.error("Expecting value of the form \"float1 float2\" after loc.", ev)
	
	return Vector2(float(vec[0]), float(vec[1]))
	
func _parse_dir(dir, ev = {}) -> Vector2:
	if dir in vn.DIRECTION:
		return vn.DIRECTION[dir]
	elif typeof(dir) == TYPE_STRING and dir == "R":
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var rndv = Vector2(rng.randf_range(-1, 1),rng.randf_range(-1, 1))
		return rndv
	else:
		return _parse_loc(dir, ev)

func _parse_color(color, ev = {}) -> Color:
	if typeof(color) == TYPE_COLOR: # 14 = color
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
			print("Error event: " + str(ev))
			push_error("Expecting value of the form flaot1 float2 float3( float4) after color.")
			return Color()

func _parse_true_false(truth, ev = {}) -> bool:
	if typeof(truth) == TYPE_BOOL: # 1 = bool
		return truth
	if truth == "true":
		return true
	elif truth == "false":
		return false
	else:
		print("Error event: " + str(ev))
		push_error("Expecting either boolean data or 'true' or 'false' strings.")
		return false

func _parse_params(p, _ev = {}): # If params has a string which is a dvar,
	# then this will be replaced by the value of a dvar
	var t = typeof(p)
	if t == TYPE_REAL or t == TYPE_INT:
		return p
	if t == TYPE_STRING and vn.dvar.has(p):
		return vn.dvar[p]
	if t == TYPE_ARRAY:
		var temp = p
		for i in range(temp.size()):
			if typeof(temp[i]) == TYPE_STRING and vn.dvar.has(temp[i]):
				temp[i] = vn.dvar[temp[i]]
		return temp


func _dialog_state_reset():
	if nvl:
		nvlBox.nw = false
	else:
		dialogbox.nw = false

func preprocess(words : String) -> String:

	_dialog_state_reset()
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
				"lbr": output += "["
				"rbr": output += "]"
				_: 
					if vn.dvar.has(inner):
						output += str(vn.dvar[inner])
					else:
						output += '[' + inner + ']'
						
		else:
			output += c
			
		i += 1
	
	return output
