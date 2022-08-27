# Options panel
#
# Change sound options for the moment
extends Panel


# Private variables
onready var _reverb : HBoxContainer = $ScrollUI/UI/Reverb
onready var _pitch : HBoxContainer = $ScrollUI/UI/Pitch
onready var _delay : HBoxContainer = $ScrollUI/UI/Delay


# Load data from ressource
func load_data(saved_data : Resource) -> void:
	_reverb.set_value(saved_data.reverb_value)
	_pitch.set_value(saved_data.pitch_value)
	_delay.set_value(saved_data.delay_value)


# Save data to ressource
func save_data(saved_data : Resource) -> void:
	saved_data.reverb_value = _reverb.get_value()
	saved_data.pitch_value = _pitch.get_value()
	saved_data.delay_value = _delay.get_value()


# Reset values
func reset_value() -> void:
	_reverb.reset_value()
	_pitch.reset_value()
	_delay.reset_value()


# Reset button pressed
func _on_Reset_pressed() -> void:
	reset_value()

