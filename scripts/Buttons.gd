# Sound buttons
#
# Not really reusable buttons, use to play Tempo/Tache
extends HBoxContainer


# Private variables
onready var _tache_sound : AudioStreamPlayer2D = $Tache/TacheSound
onready var _tempo_sound : AudioStreamPlayer2D = $Tempo/TempoSound


# Play tempo when the button tempo is pressed
func _on_Tempo_pressed() -> void:
	_tempo_sound.play()


# Play tache when the button tache is pressed
func _on_Tache_pressed() -> void:
	_tache_sound.play()

