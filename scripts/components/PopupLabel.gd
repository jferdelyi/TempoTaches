# Popup infos
#
# Fadein and fadeout text panel
class_name PopupLabel
extends Control


# Exposed variable
export var animation_duration = 1.0 #sec


# Privates
var _start_color : Color
var _default_color : Color
var _default_text_color : Color

onready var _pop_tween_in : Tween = $PopupTweenIn
onready var _pop_tween_out : Tween = $PopupTweenOut
onready var _label : Label = $TextPanel/Label
onready var _panel : Panel = $TextPanel
onready var _style := StyleBoxFlat.new()


# Set the start color with alpha = 0
func _ready() -> void:
	_panel.set("custom_styles/panel", _style)
	_style.set_corner_radius_all(5)
	_default_color = Color(0, 0, 0, 0.5)
	_default_text_color = Color.white
	_start_color = _default_color
	_start_color.a = 0
	hide()


# Stop animation
func _stop() -> void:
	if not _pop_tween_in.stop_all():
		printerr("Error when stopping the popup animation")
	if not _pop_tween_out.stop_all():
		printerr("Error when stopping the popup animation")
	hide()


# Start animation and set the label text
func start(text : String) -> void:
	# Init
	if _pop_tween_in.is_active() or _pop_tween_out.is_active():
		_stop()
	_label.text = text
	show()
	
	# Fade In
	if not _pop_tween_in.interpolate_property(_style, "bg_color", _start_color, _default_color, animation_duration, Tween.TRANS_LINEAR, Tween.EASE_IN):
		printerr("Error when adding in an interpolate animation for bg_color")
	if not _pop_tween_in.interpolate_property(_label, "custom_colors/font_color", _start_color, _default_text_color, animation_duration, Tween.TRANS_LINEAR, Tween.EASE_IN):
		printerr("Error when adding in an interpolate animation for custom_colors/font_color")
	if not _pop_tween_in.start():
		printerr("Error when starting the popup animation")
	yield(_pop_tween_in, "tween_completed")
	if not _pop_tween_in.stop_all():
		printerr("Error when stopping the popup animation")
	
	# Fade out
	if not _pop_tween_out.interpolate_property(_style, "bg_color", _default_color, _start_color, animation_duration, Tween.TRANS_LINEAR, Tween.EASE_IN):
		printerr("Error when adding out an interpolate animation for bg_color")
	if not _pop_tween_out.interpolate_property(_label, "custom_colors/font_color", _default_text_color, _start_color, animation_duration, Tween.TRANS_LINEAR, Tween.EASE_IN):
		printerr("Error when adding out an interpolate animation for custom_colors/font_color")
	if not _pop_tween_out.start():
		printerr("Error when starting the popup animation")
	yield(_pop_tween_out, "tween_completed")
	_stop()
