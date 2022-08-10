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
		_save = saved_data
		_reverb.set_value(saved_data.reverb_value)
		_pitch.set_value(saved_data.pitch_value)
		_delay.set_value(saved_data.delay_value)
		_chrono.set_minutes(saved_data.minutes_value)
		_chrono.set_seconds(saved_data.seconds_value)


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
	_save.save_data()
	_popup.start("Saved")


# Reset default value
func _on_SavePanel_reset_pressed() -> void:
	_reverb.reset_value()
	_pitch.reset_value()
	_delay.reset_value()
	_chrono.reset_value()
	_popup.start("Reset")


func _on_RecordOptions_tempo_sound_updated(new_sound : AudioStream) -> void:
	_main.set_tempo(new_sound)


func _on_RecordOptions_taches_sound_updated(new_sound : AudioStream) -> void:
	_main.set_taches(new_sound)


func _on_RecordOptions_temps_sound_updated(new_sound : AudioStream) -> void:
	_chrono.set_sound(new_sound)

