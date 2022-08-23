# Game main
#
# Used to manage save and load data
extends Control


# Private variables
var _save := SaveLoad.new()

onready var _reverb : HBoxContainer = $Options/SoundOptions/UI/Reverb
onready var _pitch : HBoxContainer = $Options/SoundOptions/UI/Pitch
onready var _delay : HBoxContainer = $Options/SoundOptions/UI/Delay
onready var _popup : Control = $Popup
onready var _chrono : Control = $Chrono
onready var _main : Panel = $MainPanel
onready var _sound_options : Panel = $Options/SoundOptions
onready var _record_options : Panel = $Options/RecordOptions

# Load data on startup
func _ready() -> void:
	_load_data()


# Load data
func _load_data() -> void:
	var saved_data = SaveLoad.load_data()
	if saved_data != null:
		_reverb.set_value(saved_data.reverb_value)
		_pitch.set_value(saved_data.pitch_value)
		_delay.set_value(saved_data.delay_value)
		_chrono.set_time(saved_data.minutes_value, saved_data.seconds_value)
		_record_options.set_sounds(saved_data)
		_chrono.init_time()


# Load data
func _on_SavePanel_load_pressed() -> void:
	_load_data()
	_popup.start("Loaded")


# Save data
func _on_SavePanel_save_pressed() -> void:
	_save.reverb_value = _reverb.get_value()
	_save.pitch_value = _pitch.get_value()
	_save.delay_value = _delay.get_value()
	_save.minutes_value = _chrono.get_minutes()
	_save.seconds_value = _chrono.get_seconds()
	_save.tempo_sound = _main.get_tempo_sound()
	_save.taches_sound = _main.get_taches_sound()
	_save.temps_sound = _chrono.get_pu_de_temps_sound()
	_save.hs_sound = _chrono.get_hs_sound()
	_save.save_data()
	_chrono.init_time()
	_popup.start("Saved")


# Reset default value
func _on_SavePanel_reset_pressed() -> void:
	_reverb.reset_value()
	_pitch.reset_value()
	_delay.reset_value()
	_chrono.reset_value()
	_record_options.reset_value()
	_popup.start("Reset")


func _on_RecordOptions_tempo_sound_updated(new_sound : AudioStream) -> void:
	_main.set_tempo_sound(new_sound)


func _on_RecordOptions_taches_sound_updated(new_sound : AudioStream) -> void:
	_main.set_taches_sound(new_sound)


func _on_RecordOptions_temps_sound_updated(new_sound : AudioStream) -> void:
	_chrono.set_pu_de_temps_sound(new_sound)


func _on_RecordOptions_hs_sound_updated(new_sound : AudioStream) -> void:
	_chrono.set_hs_sound(new_sound)

