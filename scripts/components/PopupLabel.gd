@tool

# Popup infos
#
# Fadein and fadeout text panel
extends Control


# Exposed variable
@export var animation_duration = 0.5 #sec


# Privates
var _start_color : Color
var _default_color : Color
var _default_text_color : Color

@onready var _pop_tween_in : Tween
@onready var _pop_tween_out : Tween
@onready var _label : Label = $TextPanel/Label
@onready var _panel : Panel = $TextPanel
@onready var _style := StyleBoxFlat.new()


# Set the start color with alpha = 0
func _ready() -> void:
	_panel.set("theme_override_styles/panel", _style)
	_style.set_corner_radius_all(5)
	_default_color = Color(0, 0, 0, 0.5)
	_default_text_color = Color.WHITE
	_start_color = _default_color
	_start_color.a = 0
	hide()


# Stop animation
func _stop() -> void:
	if _pop_tween_in:
		_pop_tween_in.stop()
		_pop_tween_in.kill()
		_pop_tween_in = null
	if _pop_tween_out:
		_pop_tween_out.stop()
		_pop_tween_out.kill()
		_pop_tween_out = null
	hide()


## Start animation and set the label text
func start(text: String) -> void:
	# Init
	if (_pop_tween_in and _pop_tween_in.is_running()) or (_pop_tween_out and _pop_tween_out.is_running()):
		_stop()

	_label.text = text
	show()

	# Fade In
	_pop_tween_in = create_tween()
	_pop_tween_in.tween_property(
		_style,
		"bg_color",
		_default_color,
		animation_duration
	).from(_start_color).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	_pop_tween_in.parallel().tween_method(
		func(c: Color) -> void:
			_label.add_theme_color_override("font_color", c),
		_start_color,
		_default_text_color,
		animation_duration
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)

	_pop_tween_in.play()
	await _pop_tween_in.finished
	await get_tree().create_timer(1).timeout

	# Fade Out
	_pop_tween_out = create_tween()
	_pop_tween_out.tween_property(
		_style,
		"bg_color",
		_start_color,
		animation_duration
	).from(_default_color).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	_pop_tween_out.play()

	_pop_tween_out.parallel().tween_method(
		func(c: Color) -> void:
			_label.add_theme_color_override("font_color", c),
		_default_text_color,
		_start_color,
		animation_duration
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)

	await _pop_tween_out.finished

	_stop()
