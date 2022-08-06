# Game main
#
# Used to manage save and load data
extends PanelContainer


# Private variables
var _save := SaveLoad.new()

onready var _reverb : Control = $UI/Reverb
onready var _pitch : Control = $UI/Pitch
onready var _delay : Control = $UI/Delay


# Load data
func _on_SaveLoadButtons_load_pressed() -> void:
	_save = SaveLoad.load_data()
	_reverb.set_value(_save.reverb_value)
	_pitch.set_value(_save.pitch_value)
	_delay.set_value(_save.delay_value)


# Save data
func _on_SaveLoadButtons_save_pressed() -> void:
	_save.reverb_value = _reverb.get_value()
	_save.pitch_value = _pitch.get_value()
	_save.delay_value = _delay.get_value()
	if _save.save_data() != 0:
		printerr("Error during loading data")


# Reset default value
func _on_SaveLoadButtons_reset_pressed() -> void:
	_reverb.reset_value()
	_pitch.reset_value()
	_delay.reset_value()

