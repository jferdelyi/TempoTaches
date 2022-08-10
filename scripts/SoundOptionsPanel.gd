extends Panel


signal tempo_sound_updated(AudioStream)
signal taches_sound_updated(AudioStream)
signal temps_sound_updated(AudioStream)


export var default_tempo_audio : AudioStream
export var default_taches_audio : AudioStream
export var default_temps_audio : AudioStream


onready var tempo : HBoxContainer = $UI/Tempo
onready var taches : HBoxContainer = $UI/Taches
onready var temps : HBoxContainer = $UI/PuDeTemps


func _ready() -> void:
	tempo.default_audio = default_tempo_audio
	taches.default_audio = default_taches_audio
	temps.default_audio = default_temps_audio


func _on_Tempo_sound_updated() -> void:
	emit_signal("tempo_sound_updated", tempo.get_sound())


func _on_Taches_sound_updated() -> void:
	emit_signal("taches_sound_updated", taches.get_sound())


func _on_PuDeTemps_sound_updated() -> void:
	emit_signal("temps_sound_updated", temps.get_sound())

