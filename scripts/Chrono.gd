# Chrono page
#
# If the chrono is not enable, the timer can be set
extends Control


# Timeout signal
signal time_out


# Private variables
onready var _minutes_spin_box : SpinBox = $Container/Time/Minutes
onready var _seconds_spin_box : SpinBox = $Container/Time/Seconds
onready var _progress : ProgressBar = $Container/ProgressBar
onready var _time_left : Label = $Container/ProgressBar/TimeLeft
onready var _pu_de_temps : AudioStreamPlayer2D = $PuDeTemps
onready var _hs : AudioStreamPlayer2D = $HS
onready var _start : Button = $Container/Buttons/StartPause

var _default_time : float = 90.0
var _end_time : float = 90.0
var _inner_time : float = 0.0

var _initialized : bool = false

# State machine
const STOPPED : int = 0
const STARTED : int = 1
const FINISHED : int = 2
const PAUSED : int = 3
var _state : int = STOPPED


# Set enabled
func _ready() -> void:
	_inner_time = _default_time
	if _minutes_spin_box.value >= 60:
		_minutes_spin_box.value = 59
	_enable_spin_boxes()
	_inner_time_format()


# Timer behavior
func _physics_process(delta: float) -> void:
	if _state == STARTED:
		_inner_time -= delta
		if _inner_time <= 0:
			_inner_time = 0
			emit_signal("time_out")
	_progress.value = (1 - (_inner_time / _end_time)) * 100
	_inner_time_format()


# Load data from ressource
func load_data(saved_data : Resource) -> void:
	_set_time(saved_data.minutes_value, saved_data.seconds_value)
	_default_time = _inner_time


# Load data toressource
func save_data(saved_data : Resource) -> void:
	saved_data.minutes_value = _minutes_spin_box.value
	saved_data.seconds_value = _seconds_spin_box.value
	_default_time = _inner_time


# Reset
func reset_value() -> void:
	set_minutes(1.0)
	set_seconds(30.0)


# Default value
func default_value() -> void:
	_set_spin_boxes(_default_time)


# Set pu de temps sound
func set_pu_de_temps_sound(audio : AudioStream) -> void:
	_pu_de_temps.stream = audio


# Get pu de temps sound
func get_pu_de_temps_sound() -> AudioStream:
	return _pu_de_temps.stream


# Set HS sound
func set_hs_sound(audio : AudioStream) -> void:
	_hs.stream = audio


# Set HS sound
func get_hs_sound() -> AudioStream:
	return _hs.stream


# Set minutes
func set_minutes(minutes : float) -> void:
	if minutes >= 61:
		_minutes_spin_box.value = 60
	else:
		_minutes_spin_box.value = minutes
	_compute_inner_time()


# Get minutes
func get_minutes() -> float:
	return _minutes_spin_box.value


# Set seconds
func set_seconds(seconds : float) -> void:
	if seconds >= 60:
		_seconds_spin_box.value = 59
	else:
		_seconds_spin_box.value = seconds
	_compute_inner_time()


# Get seconds
func get_seconds() -> float:
	return _seconds_spin_box.value


# Enable spinbox
func _enable_spin_boxes() -> void:
	_minutes_spin_box.editable = true
	_seconds_spin_box.editable = true


# Disable spinbox
func _disable_spin_boxes() -> void:
	_minutes_spin_box.editable = false
	_seconds_spin_box.editable = false


# Stop button
func _on_Stop_pressed() -> void:
	_inner_time = _default_time
	_set_spin_boxes(_inner_time)
	_enable_spin_boxes()
	_pu_de_temps.stop()
	_pu_de_temps.volume_db = 0
	_start.text = "Start"
	_state = STOPPED
	_time_left.visible = false


# Start/Pause
func _on_StartPause_pressed() -> void:
	if _state == FINISHED:
		_set_time(1, 0)
		_start.text = "Pause"
		_disable_spin_boxes()
		_state = STARTED
		_time_left.visible = true
	
	elif _state != STARTED:
		_start.text = "Pause"
		_disable_spin_boxes()
		_state = STARTED
		_time_left.visible = true
		
	else:
		_start.text = "Start"
		_enable_spin_boxes()
		_state = PAUSED
		_time_left.visible = true
	
	_pu_de_temps.stop()
	_pu_de_temps.volume_db = 0


# Timeout
func _on_Chrono_time_out() -> void:
	_pu_de_temps.play()
	_enable_spin_boxes()
	_start.text = "+1 minute"
	_state = FINISHED


# Minutes changed
func _on_Minutes_value_changed(value : float) -> void:
	set_minutes(value)


# Seconds changed
func _on_Seconds_value_changed(value : float) -> void:
	set_seconds(value)


# PuDeTemps finished
func _on_PuDeTemps_finished() -> void:
	_pu_de_temps.volume_db += 2
	if _pu_de_temps.volume_db > 20:
		_pu_de_temps.volume_db = 20
	_pu_de_temps.play()


func _on_HS_pressed() -> void:
	_hs.play()


# Compute inner time
func _compute_inner_time() -> void:
	_inner_time = _minutes_spin_box.value * 60
	_inner_time += _seconds_spin_box.value
	if _inner_time <= 0:
		_inner_time = 1
		_seconds_spin_box.value = 1
	_end_time = _inner_time


# Set minutes and seconds
func _set_spin_boxes(time : float) -> void:
	var tmp : float = time / 60.0
	var minutes : float = floor(tmp)
	var seconds : float = (tmp - minutes) * 60
	set_minutes(minutes)
	set_seconds(seconds)


# Format inner time
func _inner_time_format() -> void:
	var tmp : float = _inner_time / 60.0
	var minutes : float = floor(tmp)
	var seconds : float = ceil((tmp - minutes) * 60)
	
	if minutes == 0 and seconds == 60:
		minutes = 1
		seconds = 0
	
	var minutes_string : String = str(minutes)
	var seconds_string : String = str(seconds)
	if minutes < 10:
		minutes_string = "0" + str(minutes)
	if seconds < 10:
		seconds_string = "0" + str(seconds)
	_time_left.text = minutes_string + ":" + seconds_string


# Set seconds and minutes
func _set_time(minutes : float, seconds : float) -> void:
	if minutes >= 61:
		_minutes_spin_box.value = 60
	else:
		_minutes_spin_box.value = minutes
	if seconds >= 60:
		_seconds_spin_box.value = 59
	else:
		_seconds_spin_box.value = seconds
	_compute_inner_time()

