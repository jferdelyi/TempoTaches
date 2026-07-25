@tool
# Record line
#
# Can record and play the sound
# Manage the sound
#
# Capture goes through AudioEffectRecord on native platforms, and through
# MediaRecorder / JavaScriptBridge on Web, where AudioEffectRecord is not
# supported. Both paths end up producing a 16 bit AudioStreamWAV, so the
# processing chain below is shared.
extends HBoxContainer

# Sound change
signal sound_updated(new_sound)

# Browser side recorder. Uses MediaRecorder to capture, then decodeAudioData to
# get raw PCM back, which avoids depending on ScriptProcessorNode (deprecated)
# or AudioWorklet (needs a separate module). Result is handed over as base64.
const _WEB_RECORDER := """
window.godotRec = (function () {
	var chunks = [], rec = null, stream = null, out = "", rate = 0, err = "";
	async function start() {
		out = ""; err = ""; chunks = [];
		try {
			if (!stream) {
				stream = await navigator.mediaDevices.getUserMedia({
					audio: { echoCancellation: true, noiseSuppression: true, autoGainControl: true }
				});
			}
			rec = new MediaRecorder(stream);
			rec.ondataavailable = function (e) { if (e.data.size) chunks.push(e.data); };
			rec.onstop = async function () {
				try {
					var buf = await new Blob(chunks).arrayBuffer();
					var ctx = new (window.AudioContext || window.webkitAudioContext)();
					var audio = await ctx.decodeAudioData(buf);
					rate = audio.sampleRate;
					var ch = audio.getChannelData(0);
					var pcm = new Uint8Array(ch.length * 2);
					var view = new DataView(pcm.buffer);
					for (var i = 0; i < ch.length; i++) {
						var s = Math.max(-1, Math.min(1, ch[i]));
						view.setInt16(i * 2, s < 0 ? s * 0x8000 : s * 0x7FFF, true);
					}
					var bin = "", step = 8192;
					for (var j = 0; j < pcm.length; j += step) {
						bin += String.fromCharCode.apply(null, pcm.subarray(j, j + step));
					}
					out = btoa(bin);
					ctx.close();
				} catch (e) { err = String(e); }
			};
			rec.start();
			return true;
		} catch (e) { err = String(e); return false; }
	}
	return {
		start: start,
		stop: function () { if (rec && rec.state !== "inactive") rec.stop(); },
		result: function () { return out; },
		rate: function () { return rate; },
		error: function () { return err; },
		supported: !!(navigator.mediaDevices && window.MediaRecorder)
	};
})();
"""

# Exposed variables
@export_multiline var text: String = "":
	get:
		return text
	set(value):
		text = value
		$Label.text = value
@export var default_audio : AudioStream

@export_group("Trim")
## Discarded at the head of every take. The audio input stream emits a
## transient when it opens, loud enough to be mistaken for signal.
@export var skip_ms : int = 150
## Silence threshold, as a fraction of the take's own peak. Relative, so it
## follows the input level instead of having to be recalibrated.
@export_range(0.0, 1.0) var trim_ratio : float = 0.12
## Absolute floor for the threshold above, in 16 bit amplitude. Only kicks in
## on unusually loud takes, where 12% of the peak would still catch noise.
@export var threshold : int = 60

@export_group("Level")
@export var normalize : bool = true
## Target loudness, measured as RMS. 0.12 is about -18 dBFS, usual for speech.
@export_range(0.0, 0.5) var target_rms : float = 0.12
## Ceiling on the software gain. Hitting it regularly means the input gain is
## too low at the source: raise it in the OS instead, or you amplify the hiss.
@export_range(1.0, 64.0) var max_gain : float = 40.0
## Takes peaking below this are rejected rather than silently trimmed to nothing.
@export var min_peak : int = 120
## Fade applied to the head of the take, removes the click left by the cut.
@export var fade_ms : int = 5

@export_group("Vibration")
@export var vibration_enabled : bool = true
## Ignored on iOS, which uses a fixed system vibration.
@export var vibration_ms : int = 60
## Android 8 and later only, -1 keeps the device default.
@export_range(-1, 255) var vibration_amplitude : int = -1

@export_group("Web")
## How long to wait for the browser to decode the take before giving up.
@export var web_timeout_ms : int = 5000


# Private variables
var _effect : AudioEffectRecord
var _recording : AudioStream
var _record_start_ms : int = 0
var _can_vibrate : bool = false
var _is_web : bool = false
var _web_ready : bool = false
@onready var _label : Label = $Label
@onready var _reset : Button = $Reset
@onready var _player : AudioStreamPlayer = $AudioStreamPlayer


# Get and set record from audio bus
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_is_web = OS.has_feature("web")
	_check_vibration()
	if _is_web:
		_web_setup()
	else:
		_native_setup()


func _native_setup() -> void:
	_request_microphone_permission()
	var idx := AudioServer.get_bus_index("Record")
	if idx == -1:
		push_error("Audio bus 'Record' not found")
		return
	_effect = AudioServer.get_bus_effect(idx, 0) as AudioEffectRecord
	if _effect == null:
		push_error("Effect 0 of bus 'Record' is not an AudioEffectRecord")


func _web_setup() -> void:
	JavaScriptBridge.eval(_WEB_RECORDER, true)
	_web_ready = bool(JavaScriptBridge.eval("window.godotRec.supported", true))
	if not _web_ready:
		push_error("MediaRecorder unavailable. Recording needs a secure context (HTTPS or localhost).")


# Android needs the runtime grant on top of the export preset permission,
# otherwise capture silently returns silence
func _request_microphone_permission() -> void:
	if OS.get_name() != "Android":
		return
	if not "android.permission.RECORD_AUDIO" in OS.get_granted_permissions():
		OS.request_permissions()


# Vibration is a no-op on desktop, and silently does nothing on Android when the
# permission is missing from the manifest. Resolve it once, loudly.
func _check_vibration() -> void:
	_can_vibrate = false
	if not vibration_enabled:
		return
	match OS.get_name():
		"iOS":
			_can_vibrate = true
		"Android":
			_can_vibrate = "android.permission.VIBRATE" in OS.get_granted_permissions()
			if not _can_vibrate:
				push_warning("VIBRATE permission missing, add it to the Android export preset")
		"Web":
			_can_vibrate = bool(JavaScriptBridge.eval("typeof navigator.vibrate === 'function'", true))
			if not _can_vibrate:
				push_warning("navigator.vibrate unavailable, this browser has no vibration API")
		_:
			pass


# ---------------------------------------------------------------- public API

# Set text
func set_text(new_text : String) -> void:
	if not is_inside_tree():
		await self.ready
	_label.text = new_text


# Get text
func get_text() -> String:
	return _label.text


# Get actual sound
func get_sound() -> AudioStream:
	return _player.stream


# Reset to default sound
func reset() -> void:
	_on_Reset_pressed()


# Set new sound
func set_sound(audio : AudioStream) -> void:
	_player.stream = audio
	_recording = audio
	check_audio(_recording)
	sound_updated.emit(_player.stream)


# Check if the sound is the default one
func check_audio(audio : AudioStream) -> void:
	_reset.disabled = audio == default_audio


# ---------------------------------------------------------------- processing

# Highest sample amplitude over a buffer, all channels
func _peak_of(data : PackedByteArray) -> int:
	var peak := 0
	var offset := 0
	while offset + 2 <= data.size():
		peak = maxi(peak, absi(data.decode_s16(offset)))
		offset += 2
	return peak


# Reference loudness of a take.
# Block RMS, then a high percentile of the blocks. Averaging over a block
# dilutes isolated clicks, and the percentile discards the quiet blocks, so
# neither a leading silence nor a transient can move the result.
func _reference_level(data : PackedByteArray, rate : int, channels : int) -> float:
	var block := maxi(int(rate * 0.05) * channels, 1)
	var total := data.size() >> 1
	var levels := PackedFloat32Array()
	var index := 0
	while index < total:
		var last := mini(index + block, total)
		var sum := 0.0
		for sample in range(index, last):
			var value := float(data.decode_s16(sample * 2))
			sum += value * value
		levels.append(sqrt(sum / float(last - index)))
		index = last
	if levels.is_empty():
		return 0.0
	levels.sort()
	return levels[mini(int(levels.size() * 0.85), levels.size() - 1)]


# Trim leading silence, normalize the loudness and fade the head in
func _audio_process(audio : AudioStreamWAV) -> AudioStreamWAV:
	var out : AudioStreamWAV = audio.duplicate()
	if audio.format != AudioStreamWAV.FORMAT_16_BITS:
		push_warning("Unexpected format %d, processing skipped" % audio.format)
		return out

	var data : PackedByteArray = audio.data
	var channels := 2 if audio.stereo else 1
	var frame := 2 * channels
	var rate := audio.mix_rate

	# 1. Drop the stream start up transient
	var head := mini(int(rate * skip_ms / 1000.0) * frame, data.size())
	data = data.slice(head)
	if data.size() < frame:
		push_warning("Take shorter than skip_ms")
		out.data = PackedByteArray()
		return out

	# 2. Reject takes with no usable signal, rather than trimming them to nothing
	var peak := _peak_of(data)
	if peak < min_peak:
		push_warning("Signal too weak (peak %d), take rejected" % peak)
		out.data = PackedByteArray()
		return out

	# 3. Cut the leading silence. The threshold follows the take's own peak, and
	#    is capped at half of it so the loop is guaranteed to find its trigger.
	var trigger := mini(maxi(int(peak * trim_ratio), threshold), peak >> 1)
	var start := 0
	while start + frame <= data.size():
		var loud := false
		for channel in channels:
			if absi(data.decode_s16(start + channel * 2)) > trigger:
				loud = true
				break
		if loud:
			break
		start += frame
	data = data.slice(start)
	if data.size() < frame:
		push_warning("Everything trimmed (peak %d, trigger %d)" % [peak, trigger])
		out.data = PackedByteArray()
		return out

	# 4. Gain and head fade in a single pass. The clamp doubles as a limiter for
	#    whatever transient survived step 1.
	var fade := int(rate * fade_ms / 1000.0) * channels
	var count := data.size() >> 1
	for sample in count:
		var value := data.decode_s16(sample * 2) * 1.0
		if fade > 0 and sample < fade:
			value *= float(sample) / fade
		data.encode_s16(sample * 2, clampi(int(value), -32768, 32767))

	out.data = data
	return out


# If OS allow vibration, do vibration
func _vibrate() -> void:
	if not _can_vibrate:
		return
	Input.vibrate_handheld(vibration_ms, vibration_amplitude)


# Record button down
func _on_Record_button_down() -> void:
	_record_start_ms = Time.get_ticks_msec()
	if _is_web:
		if not _web_ready:
			return
		# Must run inside the user gesture, otherwise the browser refuses the
		# microphone prompt
		JavaScriptBridge.eval("window.godotRec.start()", true)
	else:
		if _effect == null:
			return
		_effect.set_recording_active(true)
	_vibrate()


# Record button up
func _on_Record_button_up() -> void:
	_vibrate()
	var rec : AudioStreamWAV = await _stop_and_fetch()
	if rec == null:
		return
	if rec.data.is_empty():
		push_warning("Recording buffer is empty")
		return

	var processed := _audio_process(rec)
	if processed.data.is_empty():
		return

	_recording = processed
	_player.stream = _recording
	check_audio(_player.stream)
	_on_Play_pressed()
	sound_updated.emit(_player.stream)


# Stop capture and return the take, whichever backend produced it
func _stop_and_fetch() -> AudioStreamWAV:
	if _is_web:
		return await _web_stop_and_fetch()
	if _effect == null:
		return null
	_effect.set_recording_active(false)
	var rec = _effect.get_recording()
	if rec == null:
		push_warning("No recording returned")
		return null
	if not rec is AudioStreamWAV:
		push_warning("Recording is not an AudioStreamWAV")
		return null
	return rec


# MediaRecorder decodes asynchronously, so poll until the base64 payload shows up
func _web_stop_and_fetch() -> AudioStreamWAV:
	if not _web_ready:
		return null
	JavaScriptBridge.eval("window.godotRec.stop()", true)
	var deadline := Time.get_ticks_msec() + web_timeout_ms
	var payload := ""
	while Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
		var error := str(JavaScriptBridge.eval("window.godotRec.error()", true))
		if error != "":
			push_warning("Web recorder: %s" % error)
			return null
		payload = str(JavaScriptBridge.eval("window.godotRec.result()", true))
		if payload != "":
			break
	if payload == "":
		push_warning("Web recorder timed out")
		return null

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.stereo = false
	wav.mix_rate = int(JavaScriptBridge.eval("window.godotRec.rate()", true))
	wav.data = Marshalls.base64_to_raw(payload)
	return wav

# Reset
func _on_Reset_pressed() -> void:
	_player.stream = default_audio
	_recording = default_audio
	check_audio(_player.stream)
	sound_updated.emit(_player.stream)


# Play
func _on_Play_pressed() -> void:
	if _player.stream == null:
		return
	_player.play()
