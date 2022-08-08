# Toggle button used to manipulate one boolean audio property
#
# Choose the bus and effect index by referring to the "audio" tab
# The name of the label can be changed using `audio_name` variable
extends Control


# Exposed variables
export var audio_bus_index : int
export var audio_effect_index : int
export var audio_property : String

export var audio_name : String
export var default_value : bool


# Private variables
onready var _audio_effect : AudioEffect = AudioServer.get_bus_effect(audio_bus_index, audio_effect_index)
onready var _button : Button = $Button
onready var _name_label : Label = $Name


# Set default value and label name
func _ready() -> void:
	_name_label.text = audio_name
	_button.pressed = default_value


# Set value
func set_value(value: bool) -> void:
	_button.pressed = value


# Get value
func get_value() -> bool:
	return _button.pressed


# Reset value
func reset_value() -> void:
	_button.pressed = default_value


# If the button is toggled change the value of the audio property
func _on_Button_toggled(button_pressed : bool) -> void:
	_audio_effect.set(audio_property, button_pressed)

