# Tab
extends TabContainer


# Reset tabs names
func _ready() -> void:
	set_tab_title(0, "Sound")
	set_tab_title(1, "Record")

