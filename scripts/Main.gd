# Game main
#
# Used to manage save and load data
extends Control


# Private variables
var _save := SaveLoad.new()

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
		_chrono.load_data(saved_data)
		_sound_options.load_data(saved_data)
		_record_options.load_data(saved_data)


# Load data
func _on_SavePanel_load_pressed() -> void:
	_load_data()
	_popup.start("Loaded")


# Save data
func _on_SavePanel_save_pressed() -> void:
	_chrono.save_data(_save)
	_sound_options.save_data(_save)
	_record_options.save_data(_save)
	_save.save_data()
	_popup.start("Saved")


# Reset default value
func _on_SavePanel_reset_pressed() -> void:
	_chrono.reset_value()
	_sound_options.reset_value()
	_record_options.reset_value()
	_popup.start("Reset")


# Set tempo sound
func _on_RecordOptions_tempo_sound_updated(new_sound : AudioStream) -> void:
	_main.set_tempo_sound(new_sound)


# Set taches sound
func _on_RecordOptions_taches_sound_updated(new_sound : AudioStream) -> void:
	_main.set_taches_sound(new_sound)


# Set CRA sound
func _on_RecordOptions_cra_sound_updated(new_sound : AudioStream) -> void:
	_main.set_cra_sound(new_sound)


# Set temps sound
func _on_RecordOptions_temps_sound_updated(new_sound : AudioStream) -> void:
	_chrono.set_pu_de_temps_sound(new_sound)


# Set HS sound
func _on_RecordOptions_hs_sound_updated(new_sound : AudioStream) -> void:
	_chrono.set_hs_sound(new_sound)

