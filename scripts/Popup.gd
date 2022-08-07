extends Panel


# Constantes
const ANIMATION_DURATION = 1.0 #sec


# Privates
var _start_color : Color
var _popup_in : bool = true
var _lable_in : bool = true

onready var _pop_tween : Tween = $PopupTween
onready var _label : Label = $Label
onready var _style : StyleBoxFlat = get("custom_styles/panel")
onready var _default_color : Color = _style.get_bg_color()
onready var _default_text_color : Color = Color.white


# Set the start color with alpha = 0
func _ready() -> void:
	_start_color = _default_color
	_start_color.a = 0


# Stop animation
func _stop() -> void:
	_popup_in = false;
	_lable_in = false;
	if not _pop_tween.stop_all():
		printerr("Error when stopping the popup animation")
	hide()
	set_process(false)


# Start animation and set the label text
func start(text : String) -> void:
	if _pop_tween.is_active():
		_stop()
	_label.text = text
	_popup_in = true;
	_lable_in = true;
	if not _pop_tween.interpolate_property(_style, "bg_color", _start_color, _default_color, ANIMATION_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN):
		printerr("Error when adding in an interpolate animation for bg_color")
	if not _pop_tween.interpolate_property(_label, "custom_colors/font_color", _start_color, _default_text_color, ANIMATION_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN):
		printerr("Error when adding in an interpolate animation for custom_colors/font_color")
	if not _pop_tween.start():
		printerr("Error when starting the popup animation")
	set_process(true)
	show()


# Tween callback
func _on_PopupTween_tween_completed(__: Object, key: NodePath) -> void:
	if key == ":bg_color":
		if _popup_in:
			_popup_in = false;
			if not _pop_tween.interpolate_property(_style, "bg_color", _default_color, _start_color, ANIMATION_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN):
				printerr("Error when adding out an interpolate animation for bg_color")
	elif key == ":custom_colors/font_color":
		if _lable_in:
			_lable_in = false;
			if not _pop_tween.interpolate_property(_label, "custom_colors/font_color", _default_text_color, _start_color, ANIMATION_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN):
				printerr("Error when adding out an interpolate animation for custom_colors/font_color")

