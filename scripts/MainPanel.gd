# Main panel
#
# Use to play Tempo/Taches and CRA if active
extends Panel


# Private variables
onready var _taches_sound : AudioStreamPlayer2D = $Buttons/Taches/TachesSound
onready var _tempo_sound : AudioStreamPlayer2D = $Buttons/Tempo/TempoSound
onready var _cra_sound : AudioStreamPlayer2D = $Buttons/CRA/CRASound
onready var _cra_button : Button = $Buttons/CRA


func _ready() -> void:
	var time : Dictionary = OS.get_datetime()
	if time["day"] >= 25 or time["day"] <= 4:
		_cra_button.visible = true


# Set tempo Sound
func set_tempo_sound(audio : AudioStream):
	_tempo_sound.stream = audio


# Set taches sound
func set_taches_sound(audio : AudioStream):
	_taches_sound.stream = audio


# Set CRA sound
func set_cra_sound(audio : AudioStream):
	_cra_sound.stream = audio


# Get tempo sound
func get_tempo_sound() -> AudioStream:
	return _tempo_sound.stream


# Get taches sound
func get_taches_sound() -> AudioStream:
	return _taches_sound.stream


# Get CRA sound
func get_cra_sound() -> AudioStream:
	return _cra_sound.stream


# Play tempo when the button tempo is pressed
func _on_Tempo_pressed() -> void:
	_tempo_sound.play()


# Play taches when the button taches is pressed
func _on_Taches_pressed() -> void:
	_taches_sound.play()


# Play CRA sound
func _on_CRA_pressed() -> void:
	_cra_sound.play()

