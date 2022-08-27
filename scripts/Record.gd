# Record line
#
# The label and the stream is accessible
extends HBoxContainer


signal sound_updated(new_sound)


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


func get_sound() -> AudioStream:
	return _player.stream


func reset() -> void:
	_on_Reset_pressed()


func set_sound(audio : AudioStream) -> void:
	_player.stream = audio
	_recording = audio
	emit_signal("sound_updated", _player.stream)
	check_audio(_recording)

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
		# Get 4bytes (L, L, R, R)
		var left_a = audio_data.substr(index, 2)
		var left_b = audio_data.substr(index + 2, 2)
		var rigth_a = audio_data.substr(index + 4, 2)
		var rigth_b = audio_data.substr(index + 6, 2)
		
		# Convert data (little-endian) to int
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
		
		# Next 4bytes
		index += 8
	
	# Replace raw data
	return_audio.data = raw_data
	return return_audio


func _on_Record_button_down() -> void:
	_effect.set_recording_active(true)
	var os_name = OS.get_name()
	if os_name == "Android" or os_name == "iOS" or os_name == "HTML5":
		Input.vibrate_handheld(50)


func _on_Record_button_up() -> void:
	_recording = _audio_trim(_effect.get_recording())
	_effect.set_recording_active(false)
	
	var os_name = OS.get_name()
	if os_name == "Android" or os_name == "iOS" or os_name == "HTML5":
		Input.vibrate_handheld(50)
	
	if not _recording:
		_recording = default_audio
	elif not _recording.data.empty():
		_player.stream = _recording
		check_audio(_player.stream)
		_on_Play_pressed()
		emit_signal("sound_updated", _player.stream)


func _on_Reset_pressed() -> void:
	_player.stream = default_audio
	_recording = default_audio
	check_audio(_player.stream)
	emit_signal("sound_updated", _player.stream)


func _on_Play_pressed() -> void:
	_player.play()

