# Record line
#
# The label and the stream is accessible
extends HBoxContainer


signal sound_updated


export(String, MULTILINE) onready var text setget set_text, get_text
export var default_audio : AudioStream

# Private variables
var _effect : AudioEffect
var _recording : AudioStream


onready var _label : Label = $Label
onready var _record : Button = $Record
onready var _reset : Button = $Reset
onready var _player : AudioStreamPlayer = $AudioStreamPlayer
onready var _in : AudioStreamPlayer = $InAudio
onready var _out : AudioStreamPlayer = $OutAudio


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


func _on_Record_button_down() -> void:
	_effect.set_recording_active(true)
	_in.play()


func _on_Record_button_up() -> void:
	_recording = _effect.get_recording()
	_effect.set_recording_active(false)
	_on_Play_pressed()
	emit_signal("sound_updated")
	_out.play()


func _on_Reset_pressed() -> void:
	_player.stream = default_audio
	_recording = default_audio
	emit_signal("sound_updated")


func _on_Play_pressed() -> void:
	if not _recording:
		_recording = default_audio
	_player.stream = _recording
	_player.play()

