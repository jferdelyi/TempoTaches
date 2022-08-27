extends Panel


onready var _reverb : HBoxContainer = $UI/Reverb
onready var _pitch : HBoxContainer = $UI/Pitch
onready var _delay : HBoxContainer = $UI/Delay


func _on_Reset_pressed() -> void:
	_reverb.reset_value()
	_pitch.reset_value()
	_delay.reset_value()

