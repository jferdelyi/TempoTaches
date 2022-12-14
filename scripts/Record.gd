# Record line
#
# Can record and play the sound
# Manage the sound
extends HBoxContainer


# Sound change
signal sound_updated(new_sound)


# Exposed variables
export(String, MULTILINE) onready var text setget set_text, get_text
export var default_audio : AudioStream
export var threshold : int


# Private variables
var _effect : AudioEffect
var _recording : AudioStream

onready var _label : Label = $Label
onready var _record : Button = $Record
onready var _reset : Button = $Reset
onready var _player : AudioStreamPlayer = $AudioStreamPlayer


# Get and set record from audio bus
func _ready():
	var _idx = AudioServer.get_bus_index("Record")
	_effect = AudioServer.get_bus_effect(_idx, 0)


# Set text
func set_text(new_text : String) -> void:
	if not is_inside_tree():
		yield(self, 'ready');
	_label.text = new_text


# Get text
func get_text() -> String:
	return _label.text


# Get actual sound
func get_sound() -> AudioStream:
	return _player.stream


# Reset to default sound
func reset() -> void:
	_on_Reset_pressed()


# Set new sound
func set_sound(audio : AudioStream) -> void:
	_player.stream = audio
	_recording = audio
	check_audio(_recording)
	emit_signal("sound_updated", _player.stream)


# Check if the sound is the default one
func check_audio(audio : AudioStream) -> void:
	if audio != default_audio:
		_reset.disabled = false
	else:
		_reset.disabled = true


# Trim beginning audio data 
func _audio_trim(audio : AudioStream) -> AudioStream:
	var return_audio : AudioStream = audio
	var audio_data = return_audio.data.hex_encode()
	var raw_data : PoolByteArray = []
	var threshold_triggered = false
	
	# Get hex raw data
	var index = 0
	var size = audio_data.length()
	while index < size:
		# Get 2bytes (L, L, R, R)
		var left_a = audio_data.substr(index, 2)
		var left_b = audio_data.substr(index + 2, 2)
		var rigth_a = audio_data.substr(index + 4, 2)
		var rigth_b = audio_data.substr(index + 6, 2)
		
		# Convert hex data (little-endian) to int
		var left = ("0x" + left_b + left_a).hex_to_int()
		var right = ("0x" + rigth_b + rigth_a).hex_to_int()
		
		# Convert to signed data
		if left > 32767:
			left -= 65536
		if right > 32767:
			right -= 65536
		
		# Check threshold
		if not threshold_triggered and (abs(left) > threshold or abs(right) > threshold):
			threshold_triggered = true
		
		# If triggered, copy raw data (little-endian) 
		if threshold_triggered:
			raw_data.append(("0x" + left_a).hex_to_int())
			raw_data.append(("0x" + left_b).hex_to_int())
			raw_data.append(("0x" + rigth_a).hex_to_int())
			raw_data.append(("0x" + rigth_b).hex_to_int())
		
		# Next 2bytes
		index += 8
	
	# Replace raw data
	return_audio.data = raw_data
	return return_audio


# If OS allow vibration, do vibration 
func _vibrate() -> void:
	var os_name = OS.get_name()
	if os_name == "Android" or os_name == "iOS" or os_name == "HTML5":
		Input.vibrate_handheld(50)


# Record button down
func _on_Record_button_down() -> void:
	_effect.set_recording_active(true)
	_vibrate()


# Record button up
func _on_Record_button_up() -> void:
	_recording = _audio_trim(_effect.get_recording())
	_effect.set_recording_active(false)
	_vibrate()
	
	# Check if the recording is clean
	if _recording and not _recording.data.empty():
		_player.stream = _recording
		check_audio(_player.stream)
		_on_Play_pressed()
		emit_signal("sound_updated", _player.stream)


# Reset
func _on_Reset_pressed() -> void:
	_player.stream = default_audio
	_recording = default_audio
	check_audio(_player.stream)
	emit_signal("sound_updated", _player.stream)


# Play
func _on_Play_pressed() -> void:
	_player.play()

