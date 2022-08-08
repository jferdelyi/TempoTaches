# Game main
#
# Used to manage save and load data
extends Control


# Private variables
var _save := SaveLoad.new()

onready var _reverb : HBoxContainer = $OptionsPanel/UI/Reverb
onready var _pitch : HBoxContainer = $OptionsPanel/UI/Pitch
onready var _delay : HBoxContainer = $OptionsPanel/UI/Delay
onready var _popup : Control = $Popup


# Load data on startup
func _ready() -> void:
	_load_data()


# Load data
func _load_data() -> void:
	_save = SaveLoad.load_data()
	_reverb.set_value(_save.reverb_value)
	_pitch.set_value(_save.pitch_value)
	_delay.set_value(_save.delay_value)


# Load data
func _on_SavePanel_load_pressed() -> void:
	_load_data()
	_popup.start("Loaded")


# Save data
func _on_SavePanel_save_pressed() -> void:
	_save.reverb_value = _reverb.get_value()
	_save.pitch_value = _pitch.get_value()
	_save.delay_value = _delay.get_value()
	_save.save_data()
	_popup.start("Saved")


# Reset default value
func _on_SavePanel_reset_pressed() -> void:
	_reverb.reset_value()
	_pitch.reset_value()
	_delay.reset_value()
	_popup.start("Reset")

