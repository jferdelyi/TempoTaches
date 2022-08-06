# Save and load the game using the text or binary resource format
#
# This approach is unsafe if players download completed save games from the web
class_name SaveLoadButtons
extends Control


# Signals
signal save_pressed
signal load_pressed
signal reset_pressed


# Passthrough: save
func _on_Save_pressed() -> void:
	emit_signal("save_pressed")


# Passthrough: load
func _on_Load_pressed() -> void:
	emit_signal("load_pressed")


# Passthrough: reset
func _on_Reset_pressed() -> void:
	emit_signal("reset_pressed")

