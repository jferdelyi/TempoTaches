# Text panel
#
# Just a text panel
class_name TextPanel
extends Panel


# public variables
export(String, MULTILINE) onready var text setget set_text, get_text


# Private variables
onready var _label : Label = $Label


# Set text
func set_text(new_text : String) -> void:
	if not is_inside_tree():
		yield(self, 'ready');
	_label.text = new_text


# Get text
func get_text() -> String:
	return _label.text

