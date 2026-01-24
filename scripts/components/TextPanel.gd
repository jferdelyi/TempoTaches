@tool

# Text panel
class_name TextPanel
extends Panel


# Exposed variables
@export_multiline var text: String = ""


# Private variables
@onready var _label: Label = $Label


func _ready() -> void:
	_label.text = text


# Set text
func set_text(new_text: String) -> void:
	text = new_text
	if _label:
		_label.text = new_text


# Get text
func get_text() -> String:
	return text
