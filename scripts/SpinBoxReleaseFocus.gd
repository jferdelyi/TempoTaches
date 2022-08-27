extends SpinBox


onready var _line = get_line_edit()


func _is_pos_in(checkpos : Vector2) -> bool:
	var gr = get_global_rect()
	return checkpos.x >= gr.position.x and checkpos.y >= gr.position.y and checkpos.x < gr.end.x and checkpos.y < gr.end.y


func _input(event) -> void:
	if event is InputEventMouseButton and not _is_pos_in(event.position):
		_line.release_focus()

