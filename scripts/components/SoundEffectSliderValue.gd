# Slider used to manipulate one real audio property
#
# Choose the bus and effect index by referring to the "audio" tab
# The name of the label can be changed using `audio_name` variable
# The default value is clamped between the min and max values
extends SliderValue


# Exposed variables
export var audio_bus_index : int
export var audio_effect_index : int
export var audio_property : String


# Private variables
var _audio_effect : AudioEffect


# On slider value change
func _on_SoundEffectSliderValue_value_changed(new_value : float) -> void:
	if _audio_effect == null:
		_audio_effect = AudioServer.get_bus_effect(audio_bus_index, audio_effect_index)
	_audio_effect.set(audio_property, new_value)

