# All sound is synthesized at boot into PCM buffers: no audio assets.
# Levels stay low, highs are softened with one-pole low-pass filters.
extends Node

const RATE := 22050
var wind: AudioStreamPlayer
var drone: AudioStreamPlayer
var sfx := {}
var pool: Array = []

func _wav(samples: PackedFloat32Array, loop := false) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	for i in samples.size():
		data.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	w.data = data
	if loop:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_end = samples.size()
	return w

func _noise_lp(n: int, cut: float, rng: RandomNumberGenerator) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(n)
	var y := 0.0
	var a := clampf(cut * TAU / RATE, 0.0, 1.0)
	for i in n:
		y += a * (rng.randf_range(-1.0, 1.0) - y)
		out[i] = y
	return out

func _ready() -> void:
	# measured -34.7 LUFS / -18 dBFS peak in a movie capture; lift to about -30 LUFS, still quiet
	AudioServer.set_bus_volume_db(0, 5.0)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1170
	# wind bed: two low-passed noise layers with slow gusting, crossfaded at the loop seam
	var n := RATE * 6
	var a := _noise_lp(n, 380.0, rng)
	var b := _noise_lp(n, 120.0, rng)
	var s := PackedFloat32Array()
	s.resize(n)
	for i in n:
		var t := float(i) / RATE
		var gust := 0.55 + 0.45 * sin(t * TAU / 6.0) * sin(t * TAU / 3.0 + 1.0)
		s[i] = (a[i] * 1.6 * gust + b[i] * 2.4) * 0.5
	var fade := RATE / 2
	for i in fade:
		var k := float(i) / fade
		s[i] = s[i] * k + s[n - fade + i] * (1.0 - k)
	wind = _player(_wav(s, true), -20.0)
	# low organ drone for the tower field (fifth + octave, slow beating)
	n = RATE * 4
	s = PackedFloat32Array()
	s.resize(n)
	for i in n:
		var t := float(i) / RATE
		s[i] = (sin(TAU * 55.0 * t) * 0.5 + sin(TAU * 82.5 * t) * 0.3 + sin(TAU * 110.25 * t) * 0.18) * 0.5
	drone = _player(_wav(s, true), -80.0)
	# footstep: soft thud on grass
	sfx["step"] = _wav(_env(_noise_lp(int(RATE * 0.12), 260.0, rng), 0.004, 0.09, 1.8))
	# search: rustle of cloth and stone
	sfx["search"] = _wav(_env(_noise_lp(int(RATE * 0.9), 900.0, rng), 0.08, 0.7, 1.2))
	# find: a small dull bell
	sfx["find"] = _wav(_bell(392.0, 1.8, 0.35))
	# milestone line: distant low bell
	sfx["bell"] = _wav(_bell(196.0, 3.5, 0.3))
	# eat / tincture: short low tones
	sfx["eat"] = _wav(_env(_noise_lp(int(RATE * 0.35), 500.0, rng), 0.01, 0.3, 1.0))
	sfx["tincture"] = _wav(_bell(523.25, 1.2, 0.18))
	# heartbeat for high rot
	var hb := PackedFloat32Array()
	hb.resize(int(RATE * 0.5))
	for i in hb.size():
		var t := float(i) / RATE
		var e1 := exp(-pow((t - 0.05) / 0.025, 2.0))
		var e2 := exp(-pow((t - 0.25) / 0.03, 2.0)) * 0.7
		hb[i] = sin(TAU * 48.0 * t) * (e1 + e2) * 0.8
	sfx["heart"] = _wav(hb)
	for i in 4:
		var p := AudioStreamPlayer.new()
		add_child(p)
		pool.append(p)

func _env(x: PackedFloat32Array, att: float, dec: float, gain: float) -> PackedFloat32Array:
	for i in x.size():
		var t := float(i) / RATE
		var e := minf(t / att, 1.0) * exp(-maxf(t - att, 0.0) / (dec * 0.35))
		x[i] *= e * gain
	return x

func _bell(f: float, len_s: float, gain: float) -> PackedFloat32Array:
	var x := PackedFloat32Array()
	x.resize(int(RATE * len_s))
	var parts := [[1.0, 1.0], [2.01, 0.35], [2.76, 0.2], [0.5, 0.4]]
	for i in x.size():
		var t := float(i) / RATE
		var v := 0.0
		for p in parts:
			v += sin(TAU * f * p[0] * t) * p[1] * exp(-t * (1.2 + p[0]))
		x[i] = v * gain * minf(t / 0.004, 1.0)
	return x

func _player(stream: AudioStream, db: float) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = db
	add_child(p)
	return p

func start_beds() -> void:
	if not wind.playing:
		wind.play()
	if not drone.playing:
		drone.play()

func play(name: String, db := -14.0, pitch := 1.0) -> void:
	if not sfx.has(name):
		return
	for p in pool:
		if not p.playing:
			p.stream = sfx[name]
			p.volume_db = db
			p.pitch_scale = pitch
			p.play()
			return

# tower: 0..1 closeness to the tower field
func set_mood(tower: float, running: bool) -> void:
	drone.volume_db = lerpf(-60.0, -24.0, tower)
	wind.volume_db = -20.0 + (2.0 if running else 0.0)
