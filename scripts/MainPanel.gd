# Sound buttons
#
# Not really reusable buttons, use to play Tempo/Taches
extends Panel


# Private variables
onready var _taches_sound : AudioStreamPlayer2D = $Buttons/Taches/TachesSound
onready var _tempo_sound : AudioStreamPlayer2D = $Buttons/Tempo/TempoSound


# Play tempo when the button tempo is pressed
func _on_Tempo_pressed() -> void:
	_tempo_sound.play()


# Play taches when the button taches is pressed
func _on_Taches_pressed() -> void:
	_taches_sound.play()


func set_tempo(audio : AudioStream):
	_tempo_sound.stream = audio


func set_taches(audio : AudioStream):
	_taches_sound.stream = audio

