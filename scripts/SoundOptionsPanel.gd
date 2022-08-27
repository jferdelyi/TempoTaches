extends Panel


signal tempo_sound_updated(AudioStream)
signal taches_sound_updated(AudioStream)
signal temps_sound_updated(AudioStream)
signal hs_sound_updated(AudioStream)
signal cra_sound_updated(AudioStream)


export var default_tempo_audio : AudioStream
export var default_taches_audio : AudioStream
export var default_temps_audio : AudioStream
export var default_hs_audio : AudioStream
export var default_cra_audio : AudioStream


onready var _tempo : HBoxContainer = $ScrollUI/UI/Tempo
onready var _taches : HBoxContainer = $ScrollUI/UI/Taches
onready var _temps : HBoxContainer = $ScrollUI/UI/PuDeTemps
onready var _hs : HBoxContainer = $ScrollUI/UI/HS
onready var _cra : HBoxContainer = $ScrollUI/UI/CRA
onready var _trim_threshold : HBoxContainer = $ScrollUI/UI/TrimValue


func _ready() -> void:
	_tempo.default_audio = default_tempo_audio
	_taches.default_audio = default_taches_audio
	_temps.default_audio = default_temps_audio
	_hs.default_audio = default_hs_audio
	_cra.default_audio = default_cra_audio
	var time : Dictionary = OS.get_datetime()
	if time["day"] >= 25 or time["day"] <= 4:
		_cra.visible = true
	if _trim_threshold.connect("value_changed", self, "_on_SliderValue_value_changed"):
		print("Connect error")
	_on_SliderValue_value_changed(_trim_threshold.get_value())


func _on_Tempo_sound_updated(audio : AudioStream) -> void:
	emit_signal("tempo_sound_updated", audio)


func _on_Taches_sound_updated(audio : AudioStream) -> void:
	emit_signal("taches_sound_updated", audio)


func _on_PuDeTemps_sound_updated(audio : AudioStream) -> void:
	emit_signal("temps_sound_updated", audio)


func _on_HS_sound_updated(audio : AudioStream) -> void:
	emit_signal("hs_sound_updated", audio)


func _on_CRA_sound_updated(audio : AudioStream) -> void:
	emit_signal("cra_sound_updated", audio)
	

func load_data(saved_data : Resource) -> void:
	_tempo.set_sound(saved_data.tempo_sound)
	_taches.set_sound(saved_data.taches_sound)
	_temps.set_sound(saved_data.temps_sound)
	_hs.set_sound(saved_data.hs_sound)
	_cra.set_sound(saved_data.cra_sound)
	_trim_threshold.set_value(saved_data.trim_value)


func get_trim_value() -> int:
	return _trim_threshold.get_value()


func reset_value() -> void:
	_tempo.reset()
	_taches.reset()
	_temps.reset()
	_hs.reset()
	_cra.reset()
	_trim_threshold.reset_value()


func _on_SliderValue_value_changed(new_value : int) -> void:
	_tempo.threshold = new_value
	_taches.threshold = new_value
	_temps.threshold = new_value
	_hs.threshold = new_value
	_cra.threshold = new_value
