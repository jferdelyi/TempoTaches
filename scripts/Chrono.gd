# Chrono page
#
# If the chrono is not enable, the timer can be set
extends Control


# Timeout signal
signal time_out


# Private variables
onready var _minutes : SpinBox = $Container/Time/Minutes
onready var _seconds : SpinBox = $Container/Time/Seconds
onready var _progress : ProgressBar = $Container/ProgressBar
onready var _pu_de_temps : AudioStreamPlayer2D = $PuDeTemps

var _active : bool = true
var _default_time : float = 90.0
var _inner_time : float = 0.0
var _inner_seconds: float = 0.0
var _inner_minutes : float = 0.0


# Set enabled
func _ready() -> void:
	_inner_time = _default_time
	_inner_seconds = _seconds.value
	_inner_minutes = _minutes.value
	if (_inner_minutes >= 60):
		_inner_minutes = 59
	_enable()


# Timer behavior
func _physics_process(delta: float) -> void:
	if _active:
		_inner_time -= delta
		if _inner_time <= 0:
			_inner_time = 0
			emit_signal("time_out")
	_progress.value = (1 - (_inner_time / _default_time)) * 100


# Enable spinbox
func _enable() -> void:
	if _active:
		_active = false
		_minutes.editable = true
		_seconds.editable = true


# Disable spinbox
func _disable() -> void:
	if not _active:
		_active = true
		_minutes.editable = false
		_seconds.editable = false

# Stop button
func _on_Stop_pressed() -> void:
	_inner_time = _default_time
	_enable()
	_pu_de_temps.stop()
	_pu_de_temps.volume_db = -15


# Start/Pause
func _on_StartPause_pressed() -> void:
	if not _active:
		_disable()
	else:
		_enable()
	_pu_de_temps.stop()
	_pu_de_temps.volume_db = -15


# Timeout
func _on_Chrono_time_out() -> void:
	_inner_time = _default_time
	_pu_de_temps.play()
	_enable()


# Minutes changed
func _on_Minutes_value_changed(value: float) -> void:
	if value >= 61:
		_minutes.value = 60
	
	_inner_minutes = value
	_inner_time = _inner_minutes * 60
	_inner_time += _inner_seconds
	_default_time = _inner_time
	
	if _default_time <= 0:
		_seconds.value = 1
		_default_time = 1


# Seconds changed
func _on_Seconds_value_changed(value: float) -> void:
	if value >= 60:
		_seconds.value = 59
	
	_inner_seconds = value
	_inner_time = _inner_minutes * 60
	_inner_time += _inner_seconds
	_default_time = _inner_time
	
	if _default_time <= 0:
		_seconds.value = 1
		_default_time = 1


func _on_PuDeTemps_finished() -> void:
	_pu_de_temps.volume_db += 2
	_pu_de_temps.play()
