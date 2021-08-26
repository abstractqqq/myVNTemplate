extends CanvasLayer

# This part is copied from eh_jogo's great project on transition effects
# You can find it at https://github.com/eh-jogos/eh_Transitions
signal transition_started
signal transition_mid_point_reached
signal transition_finished

var transition_data : Resource = null setget _set_transition_data, _get_transition_data

#--- private variables ------------------------------------------------------------------

var _casted_transition_data : eh_TransitionData = null

onready var _color_panel: ColorRect = $eh_Transitions
onready var _animator: AnimationPlayer = $eh_Transitions/AnimationPlayer
onready var _shader: ShaderMaterial = _color_panel.material

const all_weathers = {
	'rain': "res://GodetteVN/fundamentals/details/weather/rain.tscn",
	'snow': "res://GodetteVN/fundamentals/details/weather/snow.tscn",
	'light': "res://GodetteVN/fundamentals/details/weather/light.tscn",
	'dust': "res://GodetteVN/fundamentals/details/weather/dust.tscn"
}

#--------------------------------------------------------------------------------------------------

func _ready(): # turn off everything on ready
	removeLasting()
	weather_off()
	
func weather_off():
	var w = get_node("weather")
	for n in w.get_children():
		n.call_deferred('free')
	
func show_weather(w_name:String):
	weather_off() # Weather is exclusive
	var w = get_node("weather")
	if all_weathers.has(w_name):
		var weather = load(all_weathers[w_name])
		w.add_child(weather.instance())
	else:
		if w_name != "":
			print('Warning: weather not found. Nothing is done.')

func removeLasting():
	var lasting = get_node('lasting')
	for n in lasting.get_children():
		n.call_deferred('free')


func pixel_in(t:float):
	var rect = load("res://GodetteVN/fundamentals/details/transitionRect.tscn")
	var r = rect.instance()
	self.add_child(r)
	r.pixelate_in(t)

func pixel_out(t:float):
	var rect = load("res://GodetteVN/fundamentals/details/transitionRect.tscn")
	var r = rect.instance()
	self.add_child(r)
	r.pixelate_out(t)


func tint(c: Color,time : float):
	removeLasting()
	var tintRect = load("res://GodetteVN/fundamentals/details/tintRect.tscn")
	var tint = tintRect.instance()
	get_node('lasting').add_child(tint)
	tint.set_tint(c, time)
	
func tintWave(c: Color, t : float):
	removeLasting()
	var tintRect = load("res://GodetteVN/fundamentals/details/tintRect.tscn")
	var tint = tintRect.instance()
	get_node('lasting').add_child(tint)
	tint.set_tintwave(c, t)
	
func flashlight(sc : Vector2):
	removeLasting()
	var lasting = get_node("lasting")
	var fl_scene = load("res://GodetteVN/sfxScenes/flashLightScreen.tscn").instance()
	lasting.add_child(fl_scene)
	fl_scene.scale = sc
	
func clear_debug()->void:
	get_node("debugger").text = ''

### eh's Public Methods --------------------------------------------------------------------------------

func play_transition_in() -> void:
	_color_panel.visible = true
	_play_in_animation(
			_casted_transition_data.transition_in,
			_casted_transition_data.color,
			_casted_transition_data.duration
	)

func play_transition_out() -> void:
	_color_panel.visible = true
	_play_out_animation(
			_casted_transition_data.transition_out,
			_casted_transition_data.color,
			_casted_transition_data.duration
	)

func play_transition_full() -> void:
	_color_panel.visible = true
	if _animator.is_playing():
		_raise_multiple_transition_error()
		return
	
	play_transition_in()
	yield(self, "transition_mid_point_reached")
	play_transition_out()


func play_fade_in(color: Color = Color.black, duration: float = 0.5) -> void:
	_play_in_animation("fade_in", color, duration)


func play_fade_out(color: Color = Color.black, duration: float = 0.5) -> void:
	_play_out_animation("fade_out", color, duration)


func play_fade_transition(color: Color = Color.black, duration: float = 0.5) -> void:
	if _animator.is_playing():
		_raise_multiple_transition_error()
		return
	
	play_fade_in(color, duration)
	yield(self, "transition_mid_point_reached")
	play_fade_out(color, duration)


func change_transition_data_oneshot(data: eh_TransitionData) -> void:
	var backup_transition: eh_TransitionData = transition_data
	_set_transition_data(data)
	yield(self, "transition_finished")
	_set_transition_data(backup_transition)


func is_transitioning_in() -> bool:
	var is_fade_in = (
			_animator.assigned_animation == "fade_in"
			or _animator.assigned_animation == "reversed_in"
			or _animator.assigned_animation == "transition_in"
	)
	return _animator.is_playing() and is_fade_in


func is_transitioning_out() -> bool:
	var is_fade_out = (
			_animator.assigned_animation == "fade_out"
			or _animator.assigned_animation == "reversed_out"
			or _animator.assigned_animation == "transition_out"
	)
	return _animator.is_playing() and is_fade_out
	

#--------------------------------------------------------------------------------
### eh's Private Methods -------------------------------------------------------------------------------

func _play_in_animation(animation : String, color: Color, duration: float) -> void:
	if _animator.is_playing():
		_raise_multiple_transition_error()
		return
	
	_color_panel.color = color
	_set_playback_speed(duration)
	
	emit_signal("transition_started")
	_animator.play(animation)
	yield(_animator, "animation_finished")
	emit_signal("transition_mid_point_reached")


func _play_out_animation(animation : String, color: Color, duration: float) -> void:
	if _animator.is_playing():
		_raise_multiple_transition_error()
		return
	
	_color_panel.color = color
	_set_playback_speed(duration)
	_animator.play(animation)
	
	yield(_animator, "animation_finished")
	emit_signal("transition_finished")
	_color_panel.visible = false


func _set_playback_speed(duration: float) -> void:
	_animator.playback_speed = 1.0 / duration

func _set_transition_data(data : eh_TransitionData) -> void:
	if data == null:
		return
	
	transition_data = data
	_casted_transition_data = transition_data as eh_TransitionData
	
	if _shader != null:
		_shader.set_shader_param("mask", _casted_transition_data.mask)
		_shader.set_shader_param("smooth_size", _casted_transition_data.smooth_size)

func _get_transition_data() -> eh_TransitionData:
	if _casted_transition_data != null:
		return _casted_transition_data
	else:
		return null


func _raise_multiple_transition_error() -> void:
	push_error("A new transition is being called while another one is playing")
	# If you're in Debug or this is intended, press F12 or the continue 
	# button in the debugger to continue
	assert(false)

### -----------------------------------------------------------------------------------------------
