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
onready var _pu_de_temps : AudioStreamPlayer2D = $PuDeTemps
onready var _start : Button = $Container/Buttons/StartPause

var _active : bool = true
var _default_time : float = 90.0
var _end_time : float = 90.0
var _inner_time : float = 0.0
var _end : bool = false
var _initialized : bool = false


# Set enabled
func _ready() -> void:
	_inner_time = _default_time
	if _minutes_spin_box.value >= 60:
		_minutes_spin_box.value = 59
	_enable()


# Timer behavior
func _physics_process(delta: float) -> void:
	if _active:
		_inner_time -= delta
		if _inner_time <= 0:
			_inner_time = 0
			emit_signal("time_out")
	_progress.value = (1 - (_inner_time / _end_time)) * 100


# Enable spinbox
func _enable() -> void:
	if _active:
		_active = false
		_minutes_spin_box.editable = true
		_seconds_spin_box.editable = true


# Disable spinbox
func _disable() -> void:
	if not _active:
		_active = true
		_minutes_spin_box.editable = false
		_seconds_spin_box.editable = false


# Stop button
func _on_Stop_pressed() -> void:
	_inner_time = _default_time
	_enable()
	_pu_de_temps.stop()
	_pu_de_temps.volume_db = 0
	_start.text = "Start"
	_end = false
	default_value()


# Start/Pause
func _on_StartPause_pressed() -> void:
	if _end:
		set_time(1, 0)
		_end = false
	
	if not _active:
		_start.text = "Pause"
		_disable()
	else:
		_start.text = "Start"
		_enable()
	_pu_de_temps.stop()
	_pu_de_temps.volume_db = 0


# Timeout
func _on_Chrono_time_out() -> void:
	default_value()
	_pu_de_temps.play()
	_enable()
	_start.text = "+1 minute"
	_end = true


# Minutes changed
func _on_Minutes_value_changed(value : float) -> void:
	set_minutes(value)


# Seconds changed
func _on_Seconds_value_changed(value : float) -> void:
	set_seconds(value)


# PuDeTemps finished
func _on_PuDeTemps_finished() -> void:
	_pu_de_temps.volume_db += 2
	if _pu_de_temps.volume_db > 10:
		_pu_de_temps.volume_db = 10
	_pu_de_temps.play()



# Compute inner time
func _compute_inner_time() -> void:
	_inner_time = _minutes_spin_box.value * 60
	_inner_time += _seconds_spin_box.value
	if _inner_time <= 0:
		_inner_time = 1
		_seconds_spin_box.value = 1
	_end_time = _inner_time


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


# Set seconds and minutes
func set_time(minutes : float, seconds : float) -> void:
	if minutes >= 61:
		_minutes_spin_box.value = 60
	else:
		_minutes_spin_box.value = minutes
	if seconds >= 60:
		_seconds_spin_box.value = 59
	else:
		_seconds_spin_box.value = seconds
	_compute_inner_time()


func init_time() -> void:
	_default_time = _inner_time


# Reset
func reset_value() -> void:
	set_minutes(1.0)
	set_seconds(30.0)


# Default
func default_value() -> void:
	var tmp : float = _default_time / 60.0
	var minutes : float = floor(tmp)
	var seconds : float = (tmp - minutes) * 60
	set_minutes(minutes)
	set_seconds(seconds)


func set_sound(audio : AudioStream) -> void:
	_pu_de_temps.stream = audio
