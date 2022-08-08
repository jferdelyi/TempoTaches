# Save and load the game using the text or binary resource format
#
# I prefer this method for signal propagation instead of
# save_button.connect("pressed", self, "emit_signal", ["save_pressed"])
# Because there is no warning and I think it's cleaner.
# Performance should be the same
class_name SavePanel
extends Panel


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

