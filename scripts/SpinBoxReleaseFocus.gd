# Used to resolve the focus bug
#
# Remove the focus if the user click somewhere on the app
extends SpinBox


# Private variables
onready var _line = get_line_edit()


# Return true if the pos is in
func _is_pos_in(checkpos : Vector2) -> bool:
	var gr = get_global_rect()
	return checkpos.x >= gr.position.x and checkpos.y >= gr.position.y and checkpos.x < gr.end.x and checkpos.y < gr.end.y


# If the event is mouse and the position if outside the current SpinBox
# Do release focus
func _input(event) -> void:
	if event is InputEventMouseButton and not _is_pos_in(event.position):
		_line.release_focus()

