# O Empire: Ward the Flowering Rot - Godot build.
# Same pilgrimage loop as the web build: walk / run / kneel / search, bread and tincture,
# flowering rot, milestone story lines, title screen, two endings.
extends Node

const World := preload("res://scripts/world.gd")
const Bearer := preload("res://scripts/bearer.gd")
const Audio := preload("res://scripts/audio.gd")
const Satchel := preload("res://scripts/satchel.gd")
const PATH_LEN := 1170.0
const CELLS_W := 132.0
const PAPER := Color(0.945, 0.918, 0.835)
const SCARLET := Color(0.87, 0.2, 0.19)

const LINES := [
	"The bells stopped before your grandfather was born.",
	"Every red head turns toward the reliquary.",
	"A road is only a wound that learned direction.",
	"Someone knelt here. The flowers kept the shape.",
	"The empire ended. Its weight did not.",
	"The tower has no door from this side.",
	"Carry what cannot forgive you.",
]

var G := {}
var svp: SubViewport
var world
var bearer
var cam: Camera3D
var screen: TextureRect
var post: ShaderMaterial
var ui: Control
var lbl_dist: Label
var lbl_msg: Label
var lbl_inv: Label
var bar_stam: ColorRect
var bar_rot: ColorRect
var bar_h := 200.0
var title: Control
var endscr: Control
var end_title: Label
var end_sub: Label
var touch_ui: Control
var stick_base := Vector2.ZERO
var stick_vec := Vector2.ZERO
var stick_idx := -1
var btn_touch := {}
var buttons := {}
var cam_pos := Vector3.ZERO
var params := {}
var frame := 0
var font: FontVariation
var gothic: FontFile
var audio
var heart_t := 0.0
var stir_told := false
var note_queue: Array = []
var satchel
var last_step := 0

func _ready() -> void:
	_parse_params()
	_setup_input()
	audio = Audio.new()
	add_child(audio)
	svp = SubViewport.new()
	svp.size = Vector2i(132, 286)
	svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	svp.msaa_3d = Viewport.MSAA_DISABLED
	svp.positional_shadow_atlas_size = 0
	add_child(svp)
	world = World.new()
	svp.add_child(world)
	bearer = Bearer.new()
	world.add_child(bearer)
	bearer.scale = Vector3.ONE * 1.4
	cam = Camera3D.new()
	cam.keep_aspect = Camera3D.KEEP_WIDTH
	cam.fov = 38.0
	cam.near = 1.0
	cam.far = 160.0
	svp.add_child(cam)
	cam.current = true

	var layer := CanvasLayer.new()
	add_child(layer)
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(bg)
	screen = TextureRect.new()
	screen.texture = svp.get_texture()
	screen.stretch_mode = TextureRect.STRETCH_SCALE
	screen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	post = ShaderMaterial.new()
	post.shader = load("res://shaders/halftone.gdshader")
	post.set_shader_parameter("scene", svp.get_texture())
	# WebGL hands the viewport texture over brighter than desktop GL; calibrated against the Steam frames
	post.set_shader_parameter("tone", float(params.get("tone", "1.45" if OS.has_feature("web") else "1.15")))
	post.set_shader_parameter("contrast", float(params.get("contrast", "1.3" if OS.has_feature("web") else "1.1")))
	post.set_shader_parameter("exposure", float(params.get("exp", "0.72" if OS.has_feature("web") else "1.0")))
	screen.material = post
	layer.add_child(screen)

	font = FontVariation.new()
	font.base_font = ThemeDB.fallback_font
	font.spacing_glyph = 2
	gothic = load("res://fonts/UnifrakturMaguntia-Book.ttf")
	_build_ui(layer)
	get_viewport().size_changed.connect(_layout)
	_reset()
	_layout()
	_apply_params()

func _parse_params() -> void:
	var raw := ""
	if OS.has_feature("web"):
		var s = JavaScriptBridge.eval("window.location.search", true)
		if s is String:
			raw = s.trim_prefix("?")
		for kv in raw.split("&", false):
			var p = kv.split("=")
			params[p[0]] = p[1].uri_decode() if p.size() > 1 else "1"
	for a in OS.get_cmdline_user_args():
		var t: String = a.trim_prefix("--")
		var p = t.split("=")
		params[p[0]] = p[1] if p.size() > 1 else "1"

func _setup_input() -> void:
	var map := {
		"up": [KEY_W, KEY_UP], "down": [KEY_S, KEY_DOWN], "left": [KEY_A, KEY_LEFT], "right": [KEY_D, KEY_RIGHT],
		"run": [KEY_SHIFT], "kneel": [KEY_R], "search": [KEY_E], "bread": [KEY_1], "tincture": [KEY_2], "start": [KEY_ENTER, KEY_SPACE], "satchel": [KEY_I, KEY_TAB],
	}
	for act in map:
		if not InputMap.has_action(act):
			InputMap.add_action(act, 0.2)
		for k in map[act]:
			var ev := InputEventKey.new()
			ev.physical_keycode = k
			InputMap.action_add_event(act, ev)
	var pads := {"run": JOY_BUTTON_A, "kneel": JOY_BUTTON_B, "bread": JOY_BUTTON_X, "tincture": JOY_BUTTON_Y, "search": JOY_BUTTON_RIGHT_SHOULDER, "start": JOY_BUTTON_START, "satchel": JOY_BUTTON_BACK}
	for act in pads:
		var jb := InputEventJoypadButton.new()
		jb.button_index = pads[act]
		InputMap.action_add_event(act, jb)
	for ax in [[JOY_AXIS_LEFT_Y, -1.0, "up"], [JOY_AXIS_LEFT_Y, 1.0, "down"], [JOY_AXIS_LEFT_X, -1.0, "left"], [JOY_AXIS_LEFT_X, 1.0, "right"]]:
		var jm := InputEventJoypadMotion.new()
		jm.axis = ax[0]
		jm.axis_value = ax[1]
		InputMap.action_add_event(ax[2], jm)

func _label(parent: Control, size: int, col: Color, align := HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var l := Label.new()
	l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	l.add_theme_constant_override("shadow_offset_x", 1)
	l.add_theme_constant_override("shadow_offset_y", 1)
	l.add_theme_constant_override("shadow_outline_size", 3)
	l.horizontal_alignment = align
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l

func _frame_box(parent: Control, txt: String) -> Panel:
	var p := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.1, 0.09, 0.1, 0.55)
	sb.border_color = Color(PAPER, 0.75)
	sb.set_border_width_all(1)
	p.add_theme_stylebox_override("panel", sb)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(p)
	var l := _label(p, 13, PAPER)
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.text = txt
	p.set_meta("label", l)
	return p

func _build_ui(layer: CanvasLayer) -> void:
	ui = Control.new()
	ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(ui)
	lbl_dist = _label(ui, 13, PAPER)
	lbl_msg = _label(ui, 17, PAPER)
	lbl_msg.add_theme_font_override("font", gothic)
	lbl_msg.add_theme_font_size_override("font_size", 22)
	lbl_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_inv = _label(ui, 12, PAPER)
	for which in ["stam", "rot"]:
		var back := ColorRect.new()
		back.color = Color(0, 0, 0, 0.45)
		back.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.add_child(back)
		var fill := ColorRect.new()
		fill.color = PAPER if which == "stam" else SCARLET
		fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		back.add_child(fill)
		back.set_meta("fill", fill)
		if which == "stam":
			bar_stam = back
		else:
			bar_rot = back

	touch_ui = Control.new()
	touch_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	touch_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	touch_ui.draw.connect(_draw_stick)
	ui.add_child(touch_ui)
	for b in [["run", "RUN"], ["kneel", "KNEEL"], ["search", "SEARCH"], ["bread", "BREAD"], ["tincture", "TINCTURE"], ["satchel", "SATCHEL"]]:
		buttons[b[0]] = _frame_box(touch_ui, b[1])

	satchel = Satchel.new()
	satchel.setup(font, gothic)
	satchel.visible = false
	layer.add_child(satchel)

	title = Control.new()
	title.set_anchors_preset(Control.PRESET_FULL_RECT)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(title)
	var band := ColorRect.new()
	band.color = Color(0.08, 0.07, 0.08, 0.62)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.add_child(band)
	title.set_meta("band", band)
	var t1 := _label(title, 52, PAPER)
	t1.add_theme_font_override("font", gothic)
	t1.text = "O EMPIRE!"
	var t2 := _label(title, 15, SCARLET)
	t2.text = "WARD THE FLOWERING ROT"
	var t3 := _label(title, 13, Color(PAPER, 0.85))
	t3.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t3.text = "Carry the reliquary to the far tower.\nWalk, kneel to breathe, search the cairns."
	var t4 := _label(title, 14, PAPER)
	t4.text = "TAP TO BEGIN"
	title.set_meta("labels", [t1, t2, t3, t4])

	endscr = Control.new()
	endscr.set_anchors_preset(Control.PRESET_FULL_RECT)
	endscr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	endscr.visible = false
	layer.add_child(endscr)
	var eb := ColorRect.new()
	eb.color = Color(0.06, 0.05, 0.06, 0.7)
	eb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	endscr.add_child(eb)
	endscr.set_meta("band", eb)
	end_title = _label(endscr, 30, PAPER)
	end_title.add_theme_font_override("font", gothic)
	end_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	end_sub = _label(endscr, 14, Color(PAPER, 0.85))
	end_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var e3 := _label(endscr, 13, SCARLET)
	e3.text = "TAP TO WALK AGAIN"
	endscr.set_meta("again", e3)

func _frame_rect() -> Rect2:
	# Game frame: full screen in portrait; capped near square and centred on wide screens,
	# like the reference's viewfinder crop.
	var vs := get_viewport().get_visible_rect().size
	var w := minf(vs.x, vs.y * 0.92)
	return Rect2(Vector2((vs.x - w) * 0.5, 0), Vector2(w, vs.y))

func _layout() -> void:
	var fr := _frame_rect()
	screen.position = fr.position
	screen.size = fr.size
	var ch := roundf(CELLS_W * fr.size.y / fr.size.x)
	svp.size = Vector2i(int(CELLS_W), int(ch))
	post.set_shader_parameter("cells", Vector2(CELLS_W, ch))
	var x0 := fr.position.x
	var w := fr.size.x
	var h := fr.size.y
	lbl_dist.position = Vector2(x0, 18)
	lbl_dist.size = Vector2(w, 20)
	bar_h = h * 0.26
	bar_stam.position = Vector2(x0 + 12, 54)
	bar_stam.size = Vector2(5, bar_h)
	bar_rot.position = Vector2(x0 + w - 17, 54)
	bar_rot.size = Vector2(5, bar_h)
	lbl_msg.position = Vector2(x0 + 28, h * 0.16)
	lbl_msg.size = Vector2(w - 56, 60)
	lbl_inv.position = Vector2(x0, h - 218)
	lbl_inv.size = Vector2(w, 18)
	# touch controls: stick bottom-left, button grid bottom-right
	stick_base = Vector2(x0 + 78, h - 104)
	var bw := 84.0
	var bh := 40.0
	var gx := x0 + w - 2 * bw - 22
	var gy := h - 3 * bh - 34
	var place := {"search": [0, 0], "kneel": [1, 0], "bread": [0, 1], "tincture": [1, 1], "run": [0, 2], "satchel": [1, 2]}
	for k in place:
		var b: Panel = buttons[k]
		b.position = Vector2(gx + place[k][0] * (bw + 8), gy + place[k][1] * (bh + 8))
		b.size = Vector2(bw, bh)
	var band: ColorRect = title.get_meta("band")
	band.position = Vector2(x0, h * 0.30)
	band.size = Vector2(w, 250)
	var tl: Array = title.get_meta("labels")
	var ys := [h * 0.30 + 26, h * 0.30 + 90, h * 0.30 + 128, h * 0.30 + 200]
	for i in 4:
		tl[i].position = Vector2(x0 + 20, ys[i])
		tl[i].size = Vector2(w - 40, 40)
	var eb: ColorRect = endscr.get_meta("band")
	eb.position = Vector2(x0, h * 0.32)
	eb.size = Vector2(w, 230)
	end_title.position = Vector2(x0 + 20, h * 0.32 + 24)
	end_title.size = Vector2(w - 40, 84)
	end_sub.position = Vector2(x0 + 24, h * 0.32 + 124)
	end_sub.size = Vector2(w - 48, 60)
	var e3: Label = endscr.get_meta("again")
	e3.position = Vector2(x0, h * 0.32 + 204)
	e3.size = Vector2(w, 20)
	satchel.position = fr.position
	satchel.size = fr.size
	touch_ui.queue_redraw()

func _draw_stick() -> void:
	if not touch_ui.visible:
		return
	touch_ui.draw_arc(stick_base, 52, 0, TAU, 40, Color(PAPER, 0.7), 1.5)
	touch_ui.draw_circle(stick_base, 52, Color(0.1, 0.09, 0.1, 0.35))
	touch_ui.draw_circle(stick_base + stick_vec * 40.0, 18, Color(PAPER, 0.8))
	touch_ui.draw_circle(stick_base + stick_vec * 40.0, 14, Color(0.2, 0.18, 0.2, 0.9))

func _reset() -> void:
	stir_told = false
	note_queue.clear()
	G = {"mode": "title", "t": 0.0, "stam": 100.0, "rot": 4.0, "bread": 1, "tincture": 0, "milestone": -1,
		"msgT": 0.0, "search": 0.0, "ended": false, "prog": 0.0, "pos": Vector3(World.path_x(0), 0, 0), "vel": Vector3.ZERO}
	for c in world.caches:
		c["used"] = false
		c["sack"].visible = true
	title.visible = true
	endscr.visible = false
	lbl_msg.text = ""
	bearer.position = G.pos
	cam_pos = Vector3.ZERO
	_sync()

func _start() -> void:
	_reset()
	G.mode = "play"
	title.visible = false
	audio.start_beds()
	_note("The reliquary wakes against your spine.")

func _note(s: String) -> void:
	# a line already on screen finishes first; later lines wait their turn instead of overwriting it
	if G.msgT > 0.8:
		if not note_queue.has(s):
			note_queue.append(s)
		return
	lbl_msg.text = s
	lbl_msg.modulate.a = 1.0
	G.msgT = 4.2

func _near_cache():
	var best = null
	var bd := 1e9
	for c in world.caches:
		var d: float = Vector2(c.pos.x - G.pos.x, c.pos.z - G.pos.z).length()
		if d < bd:
			bd = d
			best = c
	return [best, bd]

func _search() -> void:
	if G.mode != "play":
		return
	var nc = _near_cache()
	var c = nc[0]
	if nc[1] > 6.0:
		_note("Nothing answers beneath the flowers.")
		return
	if c.used:
		_note("Only the hollow remains.")
		return
	world.use_cache(c)
	audio.play("search", -18.0)
	G.search = 1.2
	if c.tincture:
		G.tincture += 1
		audio.play("find", -16.0)
		_note("You find one bitter tincture.")
	else:
		G.bread += 1
		audio.play("find", -16.0, 0.84)
		_note("You find bread wrapped in funeral cloth.")

func _bread() -> void:
	if G.mode != "play" or G.bread < 1:
		return
	G.bread -= 1
	audio.play("eat", -18.0)
	G.stam = clampf(G.stam + 38.0, 0, 100.0 - G.rot * 0.36)
	_note("You eat without stopping. The salt tastes old.")

func _tincture() -> void:
	if G.mode != "play" or G.tincture < 1:
		return
	G.tincture -= 1
	audio.play("tincture", -18.0)
	G.rot = clampf(G.rot - 20.0, 0, 100)
	_note("The tincture burns a clean path through you.")

func _finish(ok: bool) -> void:
	# the end screen owns the page: drop any story line still fading or waiting
	note_queue.clear()
	G.msgT = 0.0
	lbl_msg.modulate.a = 0.0
	if G.ended:
		return
	G.ended = true
	G.mode = "end"
	# blackletter capitals are unreadable; title case keeps the gothic face legible on a phone
	end_title.text = "The Tower Remembers You" if ok else "No Empire Outlives Its Rot"
	end_sub.text = "At the battlements, the reliquary becomes light. Beyond them: another red country." if ok else "The flowers take you gently. Your burden flowers before it touches the ground."
	get_tree().create_timer(0.8).timeout.connect(func(): endscr.visible = true)

func _input_move() -> Vector2:
	var m := Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	m += stick_vec
	if params.has("walk"):
		m += Vector2(0, -1)
	return m.limit_length(1.0)

func _held(act: String) -> bool:
	return Input.is_action_pressed(act) or btn_touch.values().has(act)

func _toggle_satchel() -> void:
	if G.mode != "play":
		return
	satchel.visible = not satchel.visible
	if satchel.visible:
		satchel.refresh(G)
		stick_vec = Vector2.ZERO
		stick_idx = -1
		btn_touch.clear()
		audio.play("search", -24.0, 1.4)

func _update(dt: float) -> void:
	if G.mode != "play" or satchel.visible:
		return
	G.t += dt
	var dense: float = World.field_density(G.prog)
	var m := _input_move()
	var running := _held("run") or params.has("run")
	var rest := _held("kneel")
	var vel := Vector3.ZERO
	if G.search > 0:
		G.search -= dt
		G.stam += 9.0 * dt
	elif rest:
		G.stam += 19.0 * dt
		G.rot += 0.007 * dt
	elif m.length() > 0.04 and G.stam > 0:
		var speed: float = (3.4 if running else 2.3) * (1.0 - G.rot * 0.0033)
		vel = Vector3(m.x, 0, m.y) * speed
		G.stam -= dt * (8.1 if running else 2.6) * (1.0 + dense * 0.35) * m.length()
		G.rot += dt * (0.014 + dense * 0.16 * (2.2 if running else 1.0)) * m.length()
		# running through blossoms stirs them: reckless sprinting is faster but feeds the rot
		if running and dense > 0.7 and not stir_told and G.msgT <= 0.0:
			stir_told = true
			_note("The blossoms stir as you run.")
	else:
		G.stam += 7.0 * dt
	var p: Vector3 = G.pos + vel * dt
	p.z = clampf(p.z, -PATH_LEN, 0.0)
	var px := World.path_x(p.z)
	p.x = clampf(p.x, px - 13.0, px + 13.0)
	G.pos = p
	G.vel = vel
	G.prog = -p.z
	G.stam = clampf(G.stam, 0, 100.0 - G.rot * 0.36)
	G.rot = clampf(G.rot, 0, 100)
	var mi := int(floor(G.prog * 10.0 / 1650.0))
	if mi > G.milestone and mi < LINES.size():
		G.milestone = mi
		_note(LINES[mi])
		audio.play("bell", -15.0)
	if G.rot >= 100:
		_finish(false)
	if G.prog >= PATH_LEN - 0.5:
		_finish(true)
	bearer.animate(dt, vel, running, rest, G.search > 0, G.rot)
	var st := int(floor(bearer.phase))
	if st != last_step and vel.length() > 0.1:
		last_step = st
		audio.play("step_road" if absf(G.pos.x - World.path_x(G.pos.z)) < 2.2 else "step", -22.0 + (2.0 if running else 0.0), randf_range(0.85, 1.1))
	audio.set_mood(smoothstep(900.0, 1150.0, G.prog), running)
	if G.rot > 60.0:
		heart_t -= dt
		if heart_t <= 0.0:
			heart_t = lerpf(1.3, 0.7, (G.rot - 60.0) / 40.0)
			audio.play("heart", lerpf(-26.0, -16.0, (G.rot - 60.0) / 40.0))

func _process(dt: float) -> void:
	dt = minf(dt, 0.1)
	frame += 1
	if G.msgT > 0:
		G.msgT -= dt
		lbl_msg.modulate.a = clampf(G.msgT / 0.8, 0, 1)
	elif not note_queue.is_empty() and G.mode == "play":
		_note(note_queue.pop_front())
	_update(dt)
	bearer.position = G.pos
	world.update_around(PATH_LEN - 20.0 if G.mode == "title" else G.prog, G.pos)
	_camera(dt)
	post.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
	_sync()
	if params.has("capture") and frame == int(params.get("frames", "90")):
		var img := get_viewport().get_texture().get_image()
		img.save_png(params.capture)
		get_tree().quit()

func _camera(dt: float) -> void:
	var target: Vector3
	var offset: Vector3
	if G.mode == "title":
		# slow drift over the tower field
		var tz := -PATH_LEN + 18.0 - sin(G.t * 0.05) * 6.0
		G.t += dt
		target = Vector3(World.path_x(-PATH_LEN - 14.0) + sin(G.t * 0.07) * 3.0, 0, -PATH_LEN - 4.0)
		offset = Vector3(-5.0, 60.0, 30.0)
	else:
		target = G.pos + Vector3(0, 0.8, -5.0)
		offset = Vector3(0, 19.5, 9.5)
	var want := target + offset
	if cam_pos == Vector3.ZERO:
		cam_pos = want
	# delayed camera drift behind the burden
	cam_pos = cam_pos.lerp(want, clampf(dt * 1.6, 0, 1))
	cam.position = cam_pos
	cam.look_at(cam_pos - offset, Vector3.UP)

func _sync() -> void:
	if G.is_empty():
		return
	lbl_dist.text = "THE FAR TOWER  ·  %d%%" % int(G.prog / PATH_LEN * 100.0)
	var fs: ColorRect = bar_stam.get_meta("fill")
	fs.size = Vector2(5, bar_h * G.stam / 100.0)
	fs.position = Vector2(0, bar_h - fs.size.y)
	var fr: ColorRect = bar_rot.get_meta("fill")
	fr.size = Vector2(5, bar_h * G.rot / 100.0)
	fr.position = Vector2(0, bar_h - fr.size.y)
	var nc = _near_cache()
	var near: bool = G.mode == "play" and not nc[0].used and nc[1] <= 9.0
	lbl_inv.text = ("CACHE NEAR · SEARCH  ·  " if near else "") + "BREAD %d  ·  TINCTURE %d" % [G.bread, G.tincture]
	buttons.bread.get_meta("label").text = "BREAD %d" % G.bread
	buttons.tincture.get_meta("label").text = "TINCT %d" % G.tincture
	var sb: StyleBoxFlat = buttons.search.get_theme_stylebox("panel")
	sb.border_color = SCARLET if near else Color(PAPER, 0.75)
	var playing: bool = G.mode == "play"
	for k in [lbl_dist, lbl_inv, bar_stam, bar_rot]:
		k.visible = playing
	touch_ui.visible = playing and (params.has("touch") or DisplayServer.is_touchscreen_available())

func _unhandled_input(ev: InputEvent) -> void:
	if ev.is_action_pressed("start") and G.mode != "play":
		_start()
	if ev.is_action_pressed("satchel"):
		_toggle_satchel()
		return
	if satchel.visible:
		if ev.is_action_pressed("left"):
			satchel.cycle(-1)
		elif ev.is_action_pressed("right"):
			satchel.cycle(1)
		elif ev.is_action_pressed("up") or ev.is_action_pressed("down"):
			satchel.tab = 1 - satchel.tab
			satchel.queue_redraw()
		return
	if G.mode == "play":
		if ev.is_action_pressed("search"):
			_search()
		elif ev.is_action_pressed("bread"):
			_bread()
		elif ev.is_action_pressed("tincture"):
			_tincture()

func _input(ev: InputEvent) -> void:
	if ev is InputEventScreenTouch:
		if ev.pressed:
			if G.mode != "play":
				_start()
				get_viewport().set_input_as_handled()
				return
			if satchel.visible:
				if satchel.tap(ev.position) == "close":
					_toggle_satchel()
				get_viewport().set_input_as_handled()
				return
			var hit := ""
			for k in buttons:
				if buttons[k].get_global_rect().has_point(ev.position):
					hit = k
			if hit != "":
				btn_touch[ev.index] = hit
				if hit == "search":
					_search()
				elif hit == "bread":
					_bread()
				elif hit == "tincture":
					_tincture()
				elif hit == "satchel":
					btn_touch.erase(ev.index)
					_toggle_satchel()
			elif ev.position.x < _frame_rect().get_center().x and stick_idx == -1:
				stick_idx = ev.index
				stick_base = ev.position
				stick_vec = Vector2.ZERO
		else:
			btn_touch.erase(ev.index)
			if ev.index == stick_idx:
				stick_idx = -1
				stick_vec = Vector2.ZERO
				_layout()
		touch_ui.queue_redraw()
	elif ev is InputEventScreenDrag and ev.index == stick_idx:
		stick_vec = ((ev.position - stick_base) / 48.0).limit_length(1.0)
		touch_ui.queue_redraw()

func _apply_params() -> void:
	if params.has("shot") or params.has("play"):
		var s: String = params.get("shot", "play")
		if s != "title":
			_start()
			var z := -float(params.get("z", "0"))
			G.pos = Vector3(World.path_x(z) + float(params.get("x", "0")), 0, z)
			G.prog = -z
			G.milestone = int(floor(G.prog * 10.0 / 1650.0)) - 1
			G.rot = float(params.get("rot", "4"))
			G.stam = float(params.get("stam", "100"))
			bearer.position = G.pos
			if params.has("face"):
				bearer.facing = float(params.face)
			if params.has("satchel"):
				G.bread = 2
				G.tincture = 1
				_toggle_satchel()
				satchel.tab = 1 if params.satchel == "hand" else 0
				satchel.queue_redraw()
			if s == "end_ok":
				_finish(true)
			elif s == "end_fail":
				_finish(false)
