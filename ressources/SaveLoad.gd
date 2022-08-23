# Save and load the game using the text or binary resource format
#
# This approach is unsafe if players download completed save games from the web
class_name SaveLoad
extends Resource


# Signals
signal save_pressed
signal load_pressed
signal reset_pressed


# See the get_save_path() function below
const SAVE_PATH = "user://save"


# Data to save
export var reverb_value : float
export var pitch_value : float
export var delay_value : bool

export var minutes_value : float
export var seconds_value : float

export var tempo_sound : AudioStream
export var taches_sound : AudioStream
export var temps_sound : AudioStream
export var hs_sound : AudioStream


# Save data (return error code)
func save_data() -> void:
	if ResourceSaver.save(get_save_path(), self) != 0:
		printerr("Error while saving data")


# Save data and return if the ressource exists
static func save_data_exists() -> bool:
	return ResourceLoader.exists(get_save_path())


# Load data
static func load_data() -> Resource:
	return ResourceLoader.load(get_save_path(), "", true)


# This function allows us to save and load a text resource in debug builds and a
# binary resource in the released product
static func get_save_path() -> String:
	var extension := ".tres" if OS.is_debug_build() else ".res"
	return SAVE_PATH + extension


# Passthrough: save
func _on_Save_pressed() -> void:
	emit_signal("save_pressed")


# Passthrough: load
func _on_Load_pressed() -> void:
	emit_signal("load_pressed")


# Passthrough: reset
func _on_Reset_pressed() -> void:
	emit_signal("reset_pressed")

