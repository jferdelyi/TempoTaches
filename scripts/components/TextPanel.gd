# Text panel
#
# Just a text panel
class_name TextPanel
extends Panel


# Private variables
onready var _label : Label = $Label


# public variables
export(String, MULTILINE) onready var text setget set_text, get_text


# Set text
func set_text(new_text : String) -> void:
	if not is_inside_tree():
		yield(self, 'ready');
	_label.text = new_text


# Get text
func get_text() -> String:
	return _label.text

