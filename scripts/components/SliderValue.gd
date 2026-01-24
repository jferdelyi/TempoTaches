@tool

# Slider  used to manipulate real property
class_name SliderValue
extends Control


# Value changed
signal value_changed(new_value)


# Exposed variables
@export var value_name : String
@export var default_value : float
@export var min_value : float
@export var max_value : float


# Private variables (oldschool passthrough see TextPanel)
@onready var _name_label : Label = $Name
@onready var _slider : Slider = $Slider
@onready var _reset : Button = $Reset

# Set default value, label name and the min/max values
func _ready() -> void:
	_name_label.text = value_name
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


# On slider value change
func _on_Slider_value_changed(value: float) -> void:
	if value != default_value:
		_reset.disabled = false
	else:
		_reset.disabled = true
	emit_signal("value_changed", value)


# Reset pressed
func _on_Reset_pressed() -> void:
	reset_value()
