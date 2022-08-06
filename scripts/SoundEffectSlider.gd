# Toggle button used to manipulate one real audio property
#
# Choose the bus and effect index by referring to the "audio" tab
# The name of the label can be changed using `audio_name` variable
# The default value is clamped between the min and max values
extends Control


# Exposed variables
export var audio_bus_index : int
export var audio_effect_index : int
export var audio_property : String

export var audio_name : String
export var default_value : float
export var min_value : float
export var max_value : float


# Private variables
onready var _audio_effect : AudioEffect = AudioServer.get_bus_effect(audio_bus_index, audio_effect_index)
onready var _value_label : Label = $Value
onready var _name_label : Label = $Name
onready var _slider : Slider = $Slider


# Set default value, label name and the min/max values
func _ready() -> void:
	_name_label.text = audio_name
	_slider.min_value = min_value
	_slider.max_value = max_value
	set_value(default_value)


# Set value (clamped)
func set_value(value: float) -> void:
	_slider.value = clamp(value, min_value, max_value)


# Get value
func get_value() -> float:
	return _slider.value


# Reset value
func reset_value() -> void:
	set_value(default_value)


# Set the property when the slider value change
func _on_Slider_value_changed(value : float) -> void:
	_audio_effect.set(audio_property, value)
	_value_label.text = str(((value - min_value) / (max_value - min_value)) * 100) + "%"

