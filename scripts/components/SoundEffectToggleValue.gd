# Toggle button used to manipulate boolean property
#
# Choose the bus and effect index by referring to the "audio" tab
# The name of the label can be changed using `audio_name` variable
extends ToggleValue


# Exposed variables
export var audio_bus_index : int
export var audio_effect_index : int
export var audio_property : String


# Private variables
var _audio_effect : AudioEffect


# On button value change
func _on_SoundEffectToggleValue_value_changed(new_value : bool) -> void:
	if _audio_effect == null:
		_audio_effect = AudioServer.get_bus_effect(audio_bus_index, audio_effect_index)
	_audio_effect.set(audio_property, new_value)

