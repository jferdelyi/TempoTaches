extends Panel


signal tempo_sound_updated(AudioStream)
signal taches_sound_updated(AudioStream)
signal temps_sound_updated(AudioStream)
signal hs_sound_updated(AudioStream)


export var default_tempo_audio : AudioStream
export var default_taches_audio : AudioStream
export var default_temps_audio : AudioStream
export var default_hs_audio : AudioStream


onready var _tempo : HBoxContainer = $UI/Tempo
onready var _taches : HBoxContainer = $UI/Taches
onready var _temps : HBoxContainer = $UI/PuDeTemps
onready var _hs : HBoxContainer = $UI/HS


func _ready() -> void:
	_tempo.default_audio = default_tempo_audio
	_taches.default_audio = default_taches_audio
	_temps.default_audio = default_temps_audio
	_hs.default_audio = default_hs_audio


func _on_Tempo_sound_updated(audio : AudioStream) -> void:
	emit_signal("tempo_sound_updated", audio)


func _on_Taches_sound_updated(audio : AudioStream) -> void:
	emit_signal("taches_sound_updated", audio)


func _on_PuDeTemps_sound_updated(audio : AudioStream) -> void:
	emit_signal("temps_sound_updated", audio)


func _on_HS_sound_updated(audio : AudioStream) -> void:
	emit_signal("hs_sound_updated", audio)


func set_sounds(saved_data : Resource) -> void:
	_tempo.set_sound(saved_data.tempo_sound)
	_taches.set_sound(saved_data.taches_sound)
	_temps.set_sound(saved_data.temps_sound)
	_hs.set_sound(saved_data.hs_sound)


func reset_value() -> void:
	_tempo.reset()
	_taches.reset()
	_temps.reset()
	_hs.reset()
