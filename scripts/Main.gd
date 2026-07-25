# Game main
#
# Used to manage save and load data
extends Control


# Private variables
var _save := SaveLoad.new()
var _tween : Tween

@onready var _popup : Control = $Popup
@onready var _chrono : PanelContainer = $Container/Chrono
@onready var _main : PanelContainer = $Container/MainPanel
@onready var _sound_options : Panel = $Options/SoundOptions
@onready var _record_options : Panel = $Options/RecordOptions
@onready var _options : VBoxContainer = $Options
@onready var _container : VBoxContainer = $Container


# Load data on startup
func _ready() -> void:
	_load_data()
	if OS.has_feature("web"):
		RenderingServer.set_default_clear_color(Color.BLACK)


# Load data
func _load_data() -> void:
	var saved_data = SaveLoad.load_data()
	if saved_data != null:
		_chrono.load_data(saved_data)
		if _sound_options:
			_sound_options.load_data(saved_data)
		if _record_options:
			_record_options.load_data(saved_data)
	else:
		_on_SavePanel_reset_pressed()


# Load data
func _on_SavePanel_load_pressed() -> void:
	_load_data()
	_popup.start("Loaded")


# Open options
func _on_SavePanel_options_pressed(toggled : bool) -> void:
	if _tween:
		_tween.stop()
		_tween.kill()
		_tween = null
	_tween = create_tween()
	if not toggled:
		_tween.tween_property(
			_container, 
			"position", 
			Vector2(10, 10), 
			0.5).from(Vector2(-330,10)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_tween.parallel().tween_property(
			_options, 
			"position", 
			Vector2(350,10), 
			0.5).from(Vector2(10,10)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		#_tween.parallel().tween_property(
		#	_options, 
		#	"modulate",
		#	Color("FFFFFF00"),
		#	0.5).from(Color("FFFFFF")).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_tween.play()
	else:
		_tween.tween_property(
			_container, "position", 
			Vector2(-330,10), 
			0.5).from(Vector2(10,10)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_tween.parallel().tween_property(
			_options, "position", 
			Vector2(10, 10), 
			0.5).from(Vector2(350,10)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		#_tween.parallel().tween_property(
		#	_options, 
		#	"modulate",
		#	Color("FFFFFF"),
		#	0.5).from(Color("FFFFFF00")).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_tween.play()


# Reset default value
func _on_SavePanel_reset_pressed() -> void:
	_chrono.reset_value()
	_sound_options.reset_value()
	_record_options.reset_value()
	_popup.start("Reset")


# Save data
func _on_SavePanel_save_pressed() -> void:
	_chrono.save_data(_save)
	_sound_options.save_data(_save)
	_record_options.save_data(_save)
	_save.save_data()
	_popup.start("Saved")


# Set tempo sound
func _on_RecordOptions_tempo_sound_updated(new_sound : AudioStream) -> void:
	_main.set_tempo_sound(new_sound)


# Set taches sound
func _on_RecordOptions_taches_sound_updated(new_sound : AudioStream) -> void:
	_main.set_taches_sound(new_sound)


# Set CRA sound
func _on_RecordOptions_cra_sound_updated(new_sound : AudioStream) -> void:
	_main.set_cra_sound(new_sound)


# Set temps sound
func _on_RecordOptions_temps_sound_updated(new_sound : AudioStream) -> void:
	_chrono.set_pu_de_temps_sound(new_sound)


# Set HS sound
func _on_RecordOptions_hs_sound_updated(new_sound : AudioStream) -> void:
	_chrono.set_hs_sound(new_sound)
