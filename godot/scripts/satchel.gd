# Satchel screen in the manner of the reference's Inventory / Hand view:
# dark sheet, two framed tabs, a halftone-dotted subject, a named item and a short line.
extends Control

const PAPER := Color(0.945, 0.918, 0.835)
const INK := Color(0.16, 0.145, 0.16)
const SCARLET := Color(0.87, 0.2, 0.19)

var tab := 0            # 0 inventory, 1 hand
var sel := 0
var items: Array = []   # [{name, sub, text, count, icon}]
var rot := 0.0
var font: Font
var gothic: Font
var tab_rects := [Rect2(), Rect2()]
var item_rects: Array = []
var close_rect := Rect2()

func setup(f: Font, g: Font = null) -> void:
	font = f
	gothic = g if g else f
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func refresh(g: Dictionary) -> void:
	rot = g.rot
	items = [
		{"name": "Reliquary", "sub": "Strapped to the spine", "text": "It is heavier than when you set out. Something inside turns toward the flowers.", "count": 1, "icon": "reliq"},
		{"name": "Bread", "sub": "Wrapped in funeral cloth", "text": "Restores breath. The salt tastes old.", "count": g.bread, "icon": "bread"},
		{"name": "Tincture", "sub": "Bitter, clean", "text": "Burns a path back through the rot.", "count": g.tincture, "icon": "tinct"},
	]
	sel = clampi(sel, 0, items.size() - 1)
	queue_redraw()

func _frame(r: Rect2, on: bool) -> void:
	var c := Color(PAPER, 0.9 if on else 0.4)
	draw_rect(r, Color(1, 1, 1, 0.04 if on else 0.0))
	# dotted border with solid corner ticks
	var x := r.position.x
	while x < r.end.x:
		draw_rect(Rect2(x, r.position.y, 1, 1), c)
		draw_rect(Rect2(x, r.end.y - 1, 1, 1), c)
		x += 3.0
	var y := r.position.y
	while y < r.end.y:
		draw_rect(Rect2(r.position.x, y, 1, 1), c)
		draw_rect(Rect2(r.end.x - 1, y, 1, 1), c)
		y += 3.0
	for p in [r.position, Vector2(r.end.x - 5, r.position.y), Vector2(r.position.x, r.end.y - 5), r.end - Vector2(5, 5)]:
		draw_rect(Rect2(p, Vector2(5, 5)), c, false, 1.0)

func _text(s: String, pos: Vector2, size: int, col: Color, w := -1.0, align := HORIZONTAL_ALIGNMENT_LEFT, f: Font = null) -> void:
	draw_string(f if f else font, pos, s, align, w, size, col)

func _para(s: String, pos: Vector2, w: float, size: int, col: Color) -> void:
	draw_multiline_string(font, pos, s, HORIZONTAL_ALIGNMENT_CENTER, w, size, -1, col)

# fill a polygon with halftone dots whose size follows a light direction
func _dots(poly: PackedVector2Array, bounds: Rect2, pitch: float, base: float, red_frac := 0.0, seed := 1) -> void:
	var ol := poly.duplicate()
	ol.append(poly[0])
	draw_polyline(ol, Color(PAPER, 0.4), 1.0, true)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var y := bounds.position.y
	while y < bounds.end.y:
		var x := bounds.position.x
		while x < bounds.end.x:
			var p := Vector2(x, y)
			if Geometry2D.is_point_in_polygon(p, poly):
				var shade := base + (p.x - bounds.position.x) / bounds.size.x * 0.35 - (p.y - bounds.position.y) / bounds.size.y * 0.15
				var r := clampf(shade, 0.12, 0.95) * pitch * 0.55
				var col := PAPER
				if red_frac > 0.0 and rng.randf() < red_frac * 0.5:
					col = SCARLET
					r = pitch * 0.55
				draw_circle(p, r, col)
			x += pitch
		y += pitch

func _hand_poly(c: Vector2, s: float) -> PackedVector2Array:
	# open left hand, palm facing out, drawn as one outline
	var pts := [
		[-0.55, 1.0], [-0.6, 0.45], [-0.95, 0.05], [-1.05, -0.12], [-0.92, -0.2], [-0.55, 0.05],
		[-0.5, -0.55], [-0.48, -1.05], [-0.36, -1.1], [-0.3, -0.6],
		[-0.22, -0.62], [-0.16, -1.25], [-0.02, -1.28], [0.04, -0.65],
		[0.12, -0.64], [0.2, -1.18], [0.34, -1.15], [0.34, -0.58],
		[0.42, -0.5], [0.52, -0.9], [0.64, -0.86], [0.6, -0.3], [0.55, 0.3], [0.45, 1.0],
	]
	var out := PackedVector2Array()
	for p in pts:
		out.append(c + Vector2(p[0], p[1]) * s)
	# Chaikin smoothing: rounds knuckles and fingertips so the hand reads drawn, not cut from card
	for it in 2:
		var sm := PackedVector2Array()
		for i in out.size():
			var a := out[i]
			var b := out[(i + 1) % out.size()]
			sm.append(a.lerp(b, 0.25))
			sm.append(a.lerp(b, 0.75))
		out = sm
	return out

func _hand_detail(c: Vector2, s: float, poly: PackedVector2Array) -> void:
	# anatomy in ink over the dot plate: knuckle creases, palm lines, a worn iron ring
	var ink := Color(0.13, 0.115, 0.13, 1.0)
	var fingers := [[Vector2(-0.39, -0.58), Vector2(-0.42, -1.05)], [Vector2(-0.09, -0.63), Vector2(-0.09, -1.25)], [Vector2(0.27, -0.6), Vector2(0.27, -1.15)], [Vector2(0.57, -0.42), Vector2(0.58, -0.86)]]
	for f in fingers:
		for t in [0.34, 0.66]:
			var m: Vector2 = c + (f[0] as Vector2).lerp(f[1], t) * s
			draw_line(m - Vector2(0.075 * s, 0), m + Vector2(0.075 * s, 0), ink, maxf(1.5, s * 0.018))
	# palm lines: heart line, head line, life line round the thumb
	var curves := [
		[Vector2(0.58, -0.28), Vector2(0.25, -0.36), Vector2(-0.1, -0.33), Vector2(-0.36, -0.42)],
		[Vector2(0.5, -0.08), Vector2(0.15, -0.12), Vector2(-0.2, -0.1), Vector2(-0.52, -0.02)],
		[Vector2(-0.46, -0.12), Vector2(-0.34, 0.2), Vector2(-0.3, 0.5), Vector2(-0.34, 0.8)],
	]
	for cv in curves:
		var pts := PackedVector2Array()
		for q in cv:
			pts.append(c + (q as Vector2) * s)
		draw_polyline(pts, ink, maxf(1.5, s * 0.02), true)
	# outline in pale ink so the silhouette reads on the dark page
	var ol := poly.duplicate()
	ol.append(poly[0])
	draw_polyline(ol, Color(PAPER, 0.55), 1.2, true)
	# iron ring on the ring finger
	var rc: Vector2 = c + Vector2(0.27, -0.72) * s
	draw_rect(Rect2(rc - Vector2(0.095, 0.035) * s, Vector2(0.19, 0.07) * s), PAPER)
	draw_rect(Rect2(rc - Vector2(0.095, 0.035) * s + Vector2(0, 0.045 * s), Vector2(0.19, 0.02) * s), Color(0.55, 0.52, 0.5))

func _icon(kind: String, c: Vector2, s: float) -> void:
	match kind:
		"reliq":
			var body := PackedVector2Array([c + Vector2(-0.6, -0.5) * s, c + Vector2(0.6, -0.5) * s, c + Vector2(0.6, 0.9) * s, c + Vector2(-0.6, 0.9) * s])
			var cap := PackedVector2Array([c + Vector2(-0.72, -0.5) * s, c + Vector2(0, -1.1) * s, c + Vector2(0.72, -0.5) * s])
			_dots(body, Rect2(c - Vector2(0.7, 0.6) * s, Vector2(1.4, 1.6) * s), 3.6, 0.55, rot / 100.0, 3)
			_dots(cap, Rect2(c - Vector2(0.8, 1.2) * s, Vector2(1.6, 0.8) * s), 3.6, 0.75)
			draw_rect(Rect2(c + Vector2(-0.62, -0.05) * s, Vector2(1.24, 0.1) * s), INK)
			draw_rect(Rect2(c + Vector2(-0.62, 0.45) * s, Vector2(1.24, 0.1) * s), INK)
		"bread":
			var loaf := PackedVector2Array()
			for k in 20:
				var a := PI + k * PI / 19.0
				loaf.append(c + Vector2(cos(a) * 0.9, sin(a) * 0.55 + 0.25) * s)
			loaf.append(c + Vector2(0.9, 0.45) * s)
			loaf.append(c + Vector2(-0.9, 0.45) * s)
			_dots(loaf, Rect2(c - Vector2(1.0, 0.4) * s, Vector2(2.0, 0.9) * s), 3.6, 0.6)
		"tinct":
			var vial := PackedVector2Array([c + Vector2(-0.18, -0.9) * s, c + Vector2(0.18, -0.9) * s, c + Vector2(0.18, -0.45) * s, c + Vector2(0.55, 0.0) * s, c + Vector2(0.55, 0.8) * s, c + Vector2(-0.55, 0.8) * s, c + Vector2(-0.55, 0.0) * s, c + Vector2(-0.18, -0.45) * s])
			_dots(vial, Rect2(c - Vector2(0.6, 1.0) * s, Vector2(1.2, 1.9) * s), 3.6, 0.7)
			draw_rect(Rect2(c + Vector2(-0.24, -1.05) * s, Vector2(0.48, 0.16) * s), SCARLET)

func _draw() -> void:
	var r := get_rect()
	var w := r.size.x
	var h := r.size.y
	draw_rect(Rect2(Vector2.ZERO, r.size), Color(0.13, 0.115, 0.13, 1.0))
	var tw := minf(150.0, (w - 60.0) * 0.5)
	tab_rects[0] = Rect2(w * 0.5 - tw - 10, 30, tw, 44)
	tab_rects[1] = Rect2(w * 0.5 + 10, 30, tw, 44)
	for i in 2:
		_frame(tab_rects[i], tab == i)
		_text(["Inventory", "Hand"][i], tab_rects[i].position + Vector2(0, 28), 14, Color(PAPER, 1.0 if tab == i else 0.5), tab_rects[i].size.x, HORIZONTAL_ALIGNMENT_CENTER)
	close_rect = Rect2(w - 60, h - 66, 44, 44)  # 44 px minimum touch target
	item_rects.clear()
	if tab == 1:
		var c := Vector2(w * 0.5, h * 0.44)
		var s := minf(w, h) * 0.3
		var poly := _hand_poly(c, s)
		_dots(poly, Rect2(c - Vector2(1.1, 1.3) * s, Vector2(2.2, 2.4) * s), 3.6, 0.62, rot / 100.0 * 0.6, 11)
		_hand_detail(c, s, poly)
		var buds := int(round(rot / 100.0 * 12.0))
		_text("Bearer's Hand", Vector2(0, h * 0.44 + s * 1.3 + 42), 32, PAPER, w, HORIZONTAL_ALIGNMENT_CENTER, gothic)
		_text("Left, the one that carries", Vector2(0, h * 0.44 + s * 1.3 + 64), 13, Color(PAPER, 0.6), w, HORIZONTAL_ALIGNMENT_CENTER)
		var line := "An iron ring, worn thin. " + ("Clean skin. The rot has not reached it yet." if buds == 0 else (("The rot has opened one red head by the knuckles." if buds == 1 else "The rot has opened %d red heads along the knuckles." % buds) if rot < 70.0 else "It no longer feels like yours. It feels like a field."))
		_para(line, Vector2(30, h * 0.44 + s * 1.3 + 96), w - 60, 14, PAPER)
	else:
		var it: Dictionary = items[sel]
		var c := Vector2(w * 0.5, h * 0.36)
		_icon(it.icon, c, minf(w, h) * 0.2)
		_text(it.name + ("  x%d" % it.count if it.icon != "reliq" else ""), Vector2(0, h * 0.56), 32, PAPER, w, HORIZONTAL_ALIGNMENT_CENTER, gothic)
		_text(it.sub, Vector2(0, h * 0.56 + 24), 13, Color(PAPER, 0.6), w, HORIZONTAL_ALIGNMENT_CENTER)
		_para(it.text, Vector2(30, h * 0.56 + 56), w - 60, 14, PAPER)
		var cw := 92.0
		var x0 := w * 0.5 - (cw * items.size() + 8 * (items.size() - 1)) * 0.5
		for i in items.size():
			var rr := Rect2(x0 + i * (cw + 8), h - 130, cw, 44)
			item_rects.append(rr)
			_frame(rr, i == sel)
			_text("%s %s" % [items[i].name.to_upper().substr(0, 5), "" if items[i].icon == "reliq" else str(items[i].count)], rr.position + Vector2(0, 28), 12, Color(PAPER, 1.0 if i == sel else 0.55), cw, HORIZONTAL_ALIGNMENT_CENTER)
	_frame(close_rect, false)
	_text("X", close_rect.position + Vector2(0, 28), 16, PAPER, 44, HORIZONTAL_ALIGNMENT_CENTER)
	_text("I / TAB  CLOSE", Vector2(20, h - 38), 11, Color(PAPER, 0.45))

# returns "close" | "" ; handles tab / item picks
func tap(p: Vector2) -> String:
	p -= position
	if close_rect.has_point(p):
		return "close"
	for i in 2:
		if tab_rects[i].has_point(p):
			tab = i
	for i in item_rects.size():
		if item_rects[i].has_point(p):
			sel = i
	queue_redraw()
	return ""

func cycle(dir: int) -> void:
	if tab == 0:
		sel = wrapi(sel + dir, 0, items.size())
	queue_redraw()
