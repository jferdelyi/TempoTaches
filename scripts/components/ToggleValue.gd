# Toggle button used to manipulate boolean property
class_name ToggleValue
extends Control


# Value changed
signal value_changed(new_value)


# Exposed variables
export var value_name : String
export var default_value : bool


# Private variables (oldschool passthrough see TextPanel)
onready var _name_label : Label = $Name
onready var _button : Button = $Button
onready var _reset : Button = $Reset


# Set default value, label name and the min/max values
func _ready() -> void:
	_name_label.text = value_name
	set_value(default_value)


# Set value 
func set_value(value: bool) -> void:
	_button.pressed = value


# Get value
func get_value() -> bool:
	return _button.pressed


# Reset value
func reset_value() -> void:
	set_value(default_value)


# On button value change
func _on_Button_toggled(value: bool) -> void:
	if value != default_value:
		_reset.disabled = false
	else:
		_reset.disabled = true
	emit_signal("value_changed", value)


# Reset pressed
func _on_Reset_pressed() -> void:
	reset_value()

