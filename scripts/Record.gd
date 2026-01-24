@tool
# Record line
#
# Can record and play the sound
# Manage the sound
extends HBoxContainer


# Sound change
signal sound_updated(new_sound)


# Exposed variables
@export_multiline var text: String = "":
	get:
		return text
	set(value):
		text = value
		$Label.text = value
@export var default_audio : AudioStream
@export var threshold : int


# Private variables
var _effect : AudioEffect
var _recording : AudioStream

@onready var _label : Label = $Label
@onready var _reset : Button = $Reset
@onready var _player : AudioStreamPlayer = $AudioStreamPlayer


# Get and set record from audio bus
func _ready():
	var _idx = AudioServer.get_bus_index("Record")
	_effect = AudioServer.get_bus_effect(_idx, 0)


# Set text
func set_text(new_text : String) -> void:
	if not is_inside_tree():
		await self.ready;
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
func _audio_trim(audio : AudioStreamWAV) -> AudioStreamWAV:
	var return_audio := audio.duplicate()
	var audio_data = return_audio.data.hex_encode()
	var raw_data : PackedByteArray = []
	var threshold_triggered = false

	var index = 0
	var audio_size = audio_data.length()

	while index + 7 < audio_size:
		var left_a = audio_data.substr(index, 2)
		var left_b = audio_data.substr(index + 2, 2)
		var right_a = audio_data.substr(index + 4, 2)
		var right_b = audio_data.substr(index + 6, 2)

		var left = ("0x" + left_b + left_a).hex_to_int()
		var right = ("0x" + right_b + right_a).hex_to_int()

		if left > 32767: left -= 65536
		if right > 32767: right -= 65536

		if not threshold_triggered and (abs(left) > threshold or abs(right) > threshold):
			threshold_triggered = true

		if threshold_triggered:
			raw_data.append(("0x" + left_a).hex_to_int())
			raw_data.append(("0x" + left_b).hex_to_int())
			raw_data.append(("0x" + right_a).hex_to_int())
			raw_data.append(("0x" + right_b).hex_to_int())

		index += 8

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
	_effect.set_recording_active(false)
	_vibrate()

	var rec = _effect.get_recording()

	if rec == null:
		push_warning("No recording returned")
		return

	if not rec is AudioStreamWAV:
		push_warning("Recording is not AudioStreamSample")
		return

	if rec.data.is_empty():
		push_warning("Recording buffer is empty")
		return

	_recording = _audio_trim(rec)

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
