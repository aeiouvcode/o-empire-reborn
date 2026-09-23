# Procedural pilgrimage road: field chunks, settlements, landmarks, blossoms, caches, tower.
extends Node3D

const PATH_LEN := 1170.0
const CHUNK := 40.0
const CACHE_COUNT := 8

var chunks := {}
var caches: Array = []
var ground: MeshInstance3D
var mats := {}
var flower_mesh: Mesh
var smoke: CPUParticles3D
var ash: CPUParticles3D

static func path_x(z: float) -> float:
	return sin(z * 0.012) * 6.0 + sin(z * 0.031) * 2.0

# Web build's density curve, in web units (1 m = 10 units), with the tower field swelling at the end.
static func field_density(prog: float) -> float:
	var x := prog * 10.0
	var d := 0.2 + 0.8 * pow((sin(x * 0.0037) + sin(x * 0.0081 + 2.0) + 2.0) / 4.0, 1.5)
	return d * (1.0 + 2.6 * smoothstep(930.0, 1120.0, prog))

func _mat(key: String, v: float, extra := {}) -> StandardMaterial3D:
	if mats.has(key):
		return mats[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(v, v, v * 0.98)
	if key.begins_with("roof"):
		# roofs face away from the key light on the overhead camera; lift them so tiles read as pale planes like the reference
		m.emission_enabled = true
		var e := 0.62 + 0.08 * float(key.trim_prefix("roof").to_int())
		m.emission = Color(e, e, e * 0.98)
	m.roughness = 1.0
	m.metallic_specular = 0.0
	for k in extra:
		m.set(k, extra[k])
	mats[key] = m
	return m

func _ready() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.86, 0.85, 0.8)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.78, 0.76, 0.78)
	e.ambient_light_energy = 0.55
	e.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.environment = e
	add_child(env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-34, -128, 0)
	sun.light_energy = 1.05
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = 70.0
	sun.shadow_bias = 0.06
	sun.shadow_opacity = 0.85
	add_child(sun)

	ground = MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(140, 140)
	pm.subdivide_width = 1
	pm.subdivide_depth = 1
	ground.mesh = pm
	var gm := ShaderMaterial.new()
	gm.shader = load("res://shaders/ground.gdshader")
	ground.material_override = gm
	ground.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(ground)

	var sm := SphereMesh.new()
	sm.radius = 0.27
	sm.height = 0.3
	sm.radial_segments = 6
	sm.rings = 2
	var fm := StandardMaterial3D.new()
	fm.vertex_color_use_as_albedo = true
	fm.albedo_color = Color(1, 1, 1)
	fm.roughness = 1.0
	fm.emission_enabled = true
	fm.emission = Color(0.35, 0.02, 0.02)
	sm.material = fm
	flower_mesh = sm

	_build_caches()
	_build_tower()
	_build_ash()

func _build_ash() -> void:
	ash = CPUParticles3D.new()
	ash.amount = 90
	ash.lifetime = 7.0
	ash.preprocess = 7.0
	ash.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	ash.emission_box_extents = Vector3(16, 1, 24)
	ash.direction = Vector3(0.3, -1, 0.1)
	ash.spread = 20.0
	ash.gravity = Vector3(0.4, -0.6, 0)
	ash.initial_velocity_min = 0.4
	ash.initial_velocity_max = 1.0
	var q := QuadMesh.new()
	q.size = Vector2(0.14, 0.14)
	var am := StandardMaterial3D.new()
	am.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	am.albedo_color = Color(0.97, 0.95, 0.88)
	am.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	q.material = am
	ash.mesh = q
	ash.local_coords = false
	add_child(ash)

func _build_caches() -> void:
	for i in CACHE_COUNT:
		var prog := 90.0 + 139.1 * i
		var z := -prog
		var side := -1.0 if i % 2 == 0 else 1.0
		var pos := Vector3(path_x(z) + side * 3.2, 0, z)
		var n := Node3D.new()
		n.position = pos
		add_child(n)
		# cairn of stones
		var rng := RandomNumberGenerator.new()
		rng.seed = 900 + i
		for s in 5:
			var b := MeshInstance3D.new()
			var bm := BoxMesh.new()
			var w := rng.randf_range(0.35, 0.7)
			bm.size = Vector3(w, rng.randf_range(0.25, 0.45), w * rng.randf_range(0.7, 1.1))
			b.mesh = bm
			b.material_override = _mat("stone", 0.52)
			b.position = Vector3(rng.randf_range(-0.5, 0.5), 0.15 + (0.3 if s > 2 else 0.0), rng.randf_range(-0.4, 0.4))
			b.rotation.y = rng.randf() * TAU
			n.add_child(b)
		# shrouded bundle (pale cloth) and a post with a red rag
		var sack := MeshInstance3D.new()
		var sp := SphereMesh.new()
		sp.radius = 0.38
		sp.height = 0.5
		sp.radial_segments = 8
		sp.rings = 4
		sack.mesh = sp
		sack.material_override = _mat("cloth", 0.93)
		sack.position = Vector3(0.55 * -side, 0.22, 0.3)
		n.add_child(sack)
		var post := MeshInstance3D.new()
		var pb := BoxMesh.new()
		pb.size = Vector3(0.1, 1.8, 0.1)
		post.mesh = pb
		post.material_override = _mat("wood", 0.22)
		post.position = Vector3(-0.2, 0.9, -0.3)
		n.add_child(post)
		var rag := MeshInstance3D.new()
		var rb := BoxMesh.new()
		rb.size = Vector3(0.45, 0.28, 0.04)
		rag.mesh = rb
		rag.material_override = _mat("rag", 0.0, {"albedo_color": Color(0.8, 0.07, 0.06)})
		rag.position = Vector3(0.05, 1.55, -0.3)
		n.add_child(rag)
		caches.append({"node": n, "pos": pos, "used": false, "prog": prog, "sack": sack, "tincture": _hash(prog * 10.0) > 0.42})

static func _hash(x: float) -> float:
	var s := sin(x * 12.9898) * 43758.5453
	return s - floor(s)

func use_cache(c: Dictionary) -> void:
	c["used"] = true
	c["sack"].visible = false

func _build_tower() -> void:
	var t := Node3D.new()
	var z := -PATH_LEN - 14.0
	t.position = Vector3(path_x(z), 0, z)
	add_child(t)
	var body := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 6.0
	cm.bottom_radius = 6.4
	cm.height = 34.0
	cm.radial_segments = 28
	body.mesh = cm
	body.material_override = _mat("tower", 0.62)
	body.position.y = 17.0
	t.add_child(body)
	for k in 16:
		var a := k * TAU / 16.0
		var m := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(1.4, 1.4, 1.2)
		m.mesh = bm
		m.material_override = _mat("tower", 0.62)
		m.position = Vector3(cos(a) * 5.7, 34.6, sin(a) * 5.7)
		m.rotation.y = -a
		t.add_child(m)
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	for k in 22:
		var a := rng.randf() * TAU
		var y := rng.randf_range(4.0, 31.0)
		var m := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.5, 1.6, 0.4)
		m.mesh = bm
		m.material_override = _mat("dark", 0.14)
		m.position = Vector3(cos(a) * 6.25, y, sin(a) * 6.25)
		m.rotation.y = -a
		t.add_child(m)

func _box(parent: Node3D, size: Vector3, pos: Vector3, rot_y: float, mat: Material) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	m.mesh = bm
	m.material_override = mat
	m.position = pos
	m.rotation.y = rot_y
	parent.add_child(m)
	return m

func _tree(parent: Node3D, pos: Vector3, s: float) -> void:
	var n := Node3D.new()
	n.position = pos
	parent.add_child(n)
	for k in 3:
		var m := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.0
		cm.bottom_radius = (1.1 - k * 0.28) * s
		cm.height = 1.5 * s
		cm.radial_segments = 7
		cm.rings = 1
		m.mesh = cm
		m.material_override = _mat("pine", 0.12)
		m.position.y = (0.9 + k * 0.85) * s
		n.add_child(m)

func _house(parent: Node3D, pos: Vector3, rot_y: float, rng: RandomNumberGenerator, ruined := false) -> void:
	var n := Node3D.new()
	n.position = pos
	n.rotation.y = rot_y
	parent.add_child(n)
	var w := rng.randf_range(3.2, 4.6)
	var d := rng.randf_range(4.0, 6.0)
	var h := rng.randf_range(2.2, 3.0)
	_box(n, Vector3(w, h, d), Vector3(0, h * 0.5, 0), 0.0, _mat("wall", 0.2))
	# timber gable face: light plaster panels on the long side
	for k in 3:
		_box(n, Vector3(0.05, h * 0.45, d * 0.22), Vector3(w * 0.5 + 0.03, h * 0.45, (k - 1) * d * 0.3), 0.0, _mat("plaster", 0.86))
	if not ruined:
		var roof := MeshInstance3D.new()
		var pr := PrismMesh.new()
		pr.size = Vector3(w + 1.0, rng.randf_range(3.0, 4.0), d + 0.9)
		roof.mesh = pr
		roof.material_override = _mat("roof%d" % (int(absf(pos.z)) % 3), 0.86)
		roof.position = Vector3(0, h + pr.size.y * 0.5, 0)
		n.add_child(roof)
		_box(n, Vector3(0.18, 0.18, d + 1.1), Vector3(0, h + pr.size.y + 0.02, 0), 0.0, _mat("wall", 0.2))
		for sx in [-1.0, 1.0]:
			_box(n, Vector3(0.12, 0.12, d + 0.9), Vector3(sx * (w + 1.0) * 0.5, h + 0.05, 0), 0.0, _mat("wall", 0.2))
		# tile courses: dark lines along each slope, parallel to the ridge
		var rw := (w + 1.0) * 0.5
		var ang := atan2(pr.size.y, rw)
		for sx in [-1.0, 1.0]:
			for k in range(1, 5):
				var t := k / 5.0
				var b := _box(n, Vector3(0.07, 0.05, d + 0.9), Vector3(sx * rw * (1.0 - t) + sx * 0.03, h + pr.size.y * t + 0.03, 0), 0.0, _mat("wall", 0.2))
				b.rotation.z = -sx * ang
		_box(n, Vector3(0.5, 1.4, 0.5), Vector3(w * 0.25, h + pr.size.y * 0.55, d * 0.2), 0.0, _mat("wall", 0.2))
		# chimney smoke: a few pale puffs drifting off
		for k in 3:
			var puff := MeshInstance3D.new()
			var sp := SphereMesh.new()
			sp.radius = 0.5 + k * 0.3
			sp.height = sp.radius * 1.6
			sp.radial_segments = 8
			sp.rings = 4
			puff.mesh = sp
			puff.material_override = _mat("smoke", 0.62, {"transparency": BaseMaterial3D.TRANSPARENCY_ALPHA, "albedo_color": Color(0.62, 0.61, 0.6, 0.6), "shading_mode": BaseMaterial3D.SHADING_MODE_UNSHADED})
			puff.position = Vector3(w * 0.25 + k * 0.45, h + pr.size.y * 0.55 + 1.2 + k * 0.8, d * 0.2 - k * 0.3)
			puff.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			n.add_child(puff)
		# half-timbered gable ends: pale plaster triangle with dark beams, like the reference village
		for e in [-1.0, 1.0]:
			var g := MeshInstance3D.new()
			var gp := PrismMesh.new()
			gp.size = Vector3(w * 0.92, pr.size.y * 0.86, 0.06)
			g.mesh = gp
			g.material_override = _mat("plaster", 0.86)
			g.position = Vector3(0, h + gp.size.y * 0.5, e * (d * 0.5 + 0.04))
			n.add_child(g)
			_box(n, Vector3(0.1, gp.size.y * 0.8, 0.08), Vector3(0, h + gp.size.y * 0.4, e * (d * 0.5 + 0.08)), 0.0, _mat("wall", 0.2))
			_box(n, Vector3(w * 0.8, 0.1, 0.08), Vector3(0, h + 0.1, e * (d * 0.5 + 0.08)), 0.0, _mat("wall", 0.2))
			# lit door and windows on the facade
			_box(n, Vector3(0.7, 1.3, 0.08), Vector3(-w * 0.2, 0.65, e * (d * 0.5 + 0.04)), 0.0, _mat("plaster", 0.86))
			_box(n, Vector3(0.55, 0.5, 0.08), Vector3(w * 0.25, h * 0.6, e * (d * 0.5 + 0.04)), 0.0, _mat("plaster", 0.86))
	else:
		for k in 4:
			_box(n, Vector3(rng.randf_range(0.5, 1.2), 0.4, rng.randf_range(0.5, 1.2)), Vector3(rng.randf_range(-w, w) * 0.4, h + 0.1, rng.randf_range(-d, d) * 0.4), rng.randf() * TAU, _mat("roof%d" % (int(absf(pos.z)) % 3), 0.86))

func _flowers(parent: Node3D, z0: float, z1: float, rng: RandomNumberGenerator) -> void:
	var mid := -(z0 + z1) * 0.5
	var dens := field_density(mid)
	var count := int(dens * 560.0 * (1.0 + smoothstep(1000.0, 1150.0, mid)))
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = flower_mesh
	mm.instance_count = count
	var i := 0
	var tower_zone := smoothstep(930.0, 1120.0, mid)
	while i < count:
		var cz := rng.randf_range(z1, z0)
		var px := path_x(cz)
		var cx := px + rng.randf_range(-22.0, 22.0)
		# keep the road clearer, except in the tower field
		if abs(cx - px) < 1.6 and rng.randf() > 0.25 + tower_zone * 0.6:
			continue
		var n := rng.randi_range(6, 16)
		var rad := rng.randf_range(0.5, 1.4)
		for k in n:
			if i >= count:
				break
			var a := rng.randf() * TAU
			var r := sqrt(rng.randf()) * rad
			var s := rng.randf_range(0.7, 1.35)
			var tr := Transform3D(Basis().scaled(Vector3(s, s * 0.8, s)), Vector3(cx + cos(a) * r, 0.25 + rng.randf() * 0.25, cz + sin(a) * r))
			mm.set_instance_transform(i, tr)
			var v := rng.randf_range(0.55, 1.0)
			mm.set_instance_color(i, Color(0.92 * v, 0.06 * v, 0.06 * v))
			i += 1
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mmi)

func _build_chunk(ci: int) -> Node3D:
	var root := Node3D.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 217 + ci * 7919
	var z0 := -ci * CHUNK
	var z1 := z0 - CHUNK
	var prog := ci * CHUNK + CHUNK * 0.5
	_flowers(root, z0, z1, rng)
	# scattered pines and stones
	var trees := rng.randi_range(3, 8)
	var forest := (prog < 90.0) or (prog > 790.0 and prog < 880.0)
	if forest:
		trees = 60
	for k in trees:
		var z := rng.randf_range(z1, z0)
		var side := -1.0 if rng.randf() < 0.5 else 1.0
		var off := rng.randf_range(5.0, 24.0)
		if forest:
			side = -1.0 if prog < 90.0 else side
			off = rng.randf_range(4.5, 26.0)
		_tree(root, Vector3(path_x(z) + side * off, 0, z), rng.randf_range(0.7, 1.3))
	for k in rng.randi_range(2, 6):
		var z := rng.randf_range(z1, z0)
		_box(root, Vector3(rng.randf_range(0.3, 0.9), rng.randf_range(0.2, 0.5), rng.randf_range(0.3, 0.9)), Vector3(path_x(z) + rng.randf_range(-14, 14), 0.15, z), rng.randf() * TAU, _mat("stone", 0.52))
	# settlements and landmarks by stretch of road
	var village := (prog > 190 and prog < 280) or (prog > 550 and prog < 640) or (prog > 940 and prog < 1010)
	if village:
		var ruined := prog > 900
		for k in rng.randi_range(5, 8):
			var z := rng.randf_range(z1 + 3, z0 - 3)
			var side := -1.0 if rng.randf() < 0.5 else 1.0
			var off := rng.randf_range(5.5, 18.0)
			_house(root, Vector3(path_x(z) + side * off, 0, z), rng.randf_range(-0.5, 0.5) + (PI * 0.5 if rng.randf() < 0.4 else 0.0), rng, ruined and rng.randf() < 0.6)
	if prog > 100 and prog < 140:
		# the monolith
		var z := -125.0
		_box(root, Vector3(2.4, 7.5, 1.4), Vector3(path_x(z) - 5.5, 3.75, z), 0.35, _mat("mono", 0.45))
	if prog > 310 and prog < 350:
		var z := -330.0
		var hn := Node3D.new()
		root.add_child(hn)
		_house(hn, Vector3(path_x(z) + 7.0, 0, z), 0.3, rng, true)
		smoke = CPUParticles3D.new()
		smoke.amount = 40
		smoke.lifetime = 6.0
		smoke.preprocess = 6.0
		smoke.position = Vector3(path_x(z) + 7.0, 2.5, z)
		smoke.direction = Vector3(0.2, 1, -0.5)
		smoke.spread = 18.0
		smoke.gravity = Vector3(0.3, 0.4, -0.6)
		smoke.initial_velocity_min = 0.6
		smoke.initial_velocity_max = 1.4
		smoke.scale_amount_min = 1.0
		smoke.scale_amount_max = 3.5
		var sm := SphereMesh.new()
		sm.radius = 0.8
		sm.height = 1.2
		sm.radial_segments = 6
		sm.rings = 3
		var smat := StandardMaterial3D.new()
		smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		smat.albedo_color = Color(0.16, 0.15, 0.16)
		sm.material = smat
		smoke.mesh = sm
		root.add_child(smoke)
	if prog > 400 and prog < 490:
		# broken canyon walls on both sides
		for k in 10:
			var z := rng.randf_range(z1, z0)
			var side := -1.0 if k % 2 == 0 else 1.0
			var h := rng.randf_range(4.0, 11.0)
			var w := rng.randf_range(4.0, 9.0)
			_box(root, Vector3(w, h, rng.randf_range(4, 9)), Vector3(path_x(z) + side * (w * 0.5 + rng.randf_range(4.5, 8.0)), h * 0.5, z), rng.randf_range(-0.4, 0.4), _mat("cliff", 0.5))
	if prog > 680 and prog < 760:
		# colonnade of a fallen cathedral
		for k in 7:
			var z := z0 - 3.0 - k * 5.2
			var h := 9.0 if (k + ci) % 3 != 0 else rng.randf_range(2.0, 5.0)
			_box(root, Vector3(1.4, h, 1.4), Vector3(path_x(z) + 9.0, h * 0.5, z), 0.0, _mat("column", 0.58))
		_box(root, Vector3(3.0, 1.2, CHUNK - 4.0), Vector3(path_x(z0 - CHUNK * 0.5) + 11.0, 9.6, z0 - CHUNK * 0.5), 0.0, _mat("column", 0.58))
	add_child(root)
	return root

func update_around(prog: float, at: Vector3) -> void:
	ground.position = Vector3(round(at.x / 10.0) * 10.0, 0, round(at.z / 10.0) * 10.0)
	ash.position = at + Vector3(0, 12, -6)
	var ci := int(floor(prog / CHUNK))
	var want := {}
	for k in range(ci - 2, ci + 4):
		if k < 0 or k * CHUNK > PATH_LEN + 40.0:
			continue
		want[k] = true
		if not chunks.has(k):
			chunks[k] = _build_chunk(k)
	for k in chunks.keys():
		if not want.has(k):
			chunks[k].queue_free()
			chunks.erase(k)
