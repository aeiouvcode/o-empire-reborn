# The bearer: a small hooded walker with a pale reliquary strapped to the back.
# Poses are held and stepped (low-frame gait) rather than smoothly interpolated.
extends Node3D

var body: Node3D
var leg_l: Node3D
var leg_r: Node3D
var arm_l: Node3D
var reliq: Node3D
var head: MeshInstance3D
var blooms: Array = []
var phase := 0.0
var held := 0.0
var facing := PI
var kneel := 0.0

func _m(v: float, red := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.85, 0.07, 0.06) if red else Color(v, v, v)
	m.roughness = 1.0
	return m

func _part(parent: Node3D, mesh: Mesh, pos: Vector3, mat: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = mat
	parent.add_child(mi)
	return mi

func _ready() -> void:
	var dark := _m(0.07)
	var cloth := _m(0.16)
	body = Node3D.new()
	add_child(body)
	for side in [-1, 1]:
		var leg := Node3D.new()
		leg.position = Vector3(0.11 * side, 0.82, 0)
		body.add_child(leg)
		var lb := BoxMesh.new()
		lb.size = Vector3(0.13, 0.82, 0.14)
		_part(leg, lb, Vector3(0, -0.41, 0), dark)
		if side < 0:
			leg_l = leg
		else:
			leg_r = leg
	var cloak := CylinderMesh.new()
	cloak.top_radius = 0.17
	cloak.bottom_radius = 0.34
	cloak.height = 0.95
	cloak.radial_segments = 8
	_part(body, cloak, Vector3(0, 1.18, 0), cloth)
	var hs := SphereMesh.new()
	hs.radius = 0.15
	hs.height = 0.32
	hs.radial_segments = 8
	hs.rings = 4
	head = _part(body, hs, Vector3(0, 1.78, -0.06), dark)
	arm_l = Node3D.new()
	arm_l.position = Vector3(-0.26, 1.55, 0)
	body.add_child(arm_l)
	var ab := BoxMesh.new()
	ab.size = Vector3(0.1, 0.6, 0.1)
	_part(arm_l, ab, Vector3(0, -0.3, 0), cloth)
	# reliquary on the back (+z is behind when facing -z)
	reliq = Node3D.new()
	reliq.position = Vector3(0, 1.42, 0.3)
	body.add_child(reliq)
	var rb := BoxMesh.new()
	rb.size = Vector3(0.56, 0.72, 0.36)
	_part(reliq, rb, Vector3.ZERO, _m(0.9))
	var band := BoxMesh.new()
	band.size = Vector3(0.6, 0.08, 0.4)
	_part(reliq, band, Vector3(0, 0.18, 0), dark)
	_part(reliq, band, Vector3(0, -0.2, 0), dark)
	var cap := PrismMesh.new()
	cap.size = Vector3(0.62, 0.28, 0.4)
	_part(reliq, cap, Vector3(0, 0.5, 0), _m(0.9))
	# flowering rot: scarlet buds that appear on cloak and reliquary as rot climbs
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var bud := SphereMesh.new()
	bud.radius = 0.07
	bud.height = 0.12
	bud.radial_segments = 5
	bud.rings = 2
	var redm := _m(0, true)
	for k in 18:
		var p: Vector3
		var parent: Node3D = body
		if k % 3 == 0:
			parent = reliq
			p = Vector3(rng.randf_range(-0.3, 0.3), rng.randf_range(-0.35, 0.6), rng.randf_range(0.1, 0.22))
		else:
			var a := rng.randf_range(-2.4, 2.4) + PI * 0.5
			var y := rng.randf_range(0.75, 1.6)
			var r := lerpf(0.34, 0.17, (y - 0.7) / 0.95) + 0.02
			p = Vector3(cos(a) * r, y, sin(a) * r)
		var b := _part(parent, bud, p, redm)
		b.visible = false
		b.scale = Vector3.ONE * rng.randf_range(0.8, 1.6)
		blooms.append(b)

# move: planar velocity; rest: kneel amount target; rot: 0..100
func animate(dt: float, vel: Vector3, running: bool, rest: bool, searching: bool, rot: float) -> void:
	var sp := vel.length()
	if sp > 0.2:
		facing = lerp_angle(facing, atan2(-vel.x, -vel.z), clampf(dt * 6.0, 0, 1))
	rotation.y = facing
	var kt := 1.0 if (rest or searching) else 0.0
	kneel = move_toward(kneel, kt, dt * 3.0)
	phase += sp * dt * (1.9 if running else 2.3)
	# held poses: sample the gait at ~7 poses per second
	held += dt
	if held >= 0.14 or sp < 0.1:
		held = 0.0
		var s := sin(phase * PI)
		var stride := clampf(sp / 2.3, 0.0, 1.4) * (1.0 - kneel)
		leg_l.rotation.x = s * 0.55 * stride
		leg_r.rotation.x = -s * 0.55 * stride
		arm_l.rotation.x = -s * 0.4 * stride
		body.position.y = -abs(s) * 0.05 * stride
		reliq.position.y = 1.42 + abs(cos(phase * PI)) * 0.04 * stride
	var lean := 0.12 + (0.1 if running else 0.0) + rot * 0.0018
	body.rotation.x = -lean - kneel * 0.35
	body.position.y = lerpf(body.position.y, -0.42, kneel)
	if kneel > 0.01:
		leg_l.rotation.x = lerpf(leg_l.rotation.x, 1.4, kneel)
		leg_r.rotation.x = lerpf(leg_r.rotation.x, -0.2, kneel)
	var n := int(round(rot / 100.0 * blooms.size()))
	for k in blooms.size():
		blooms[k].visible = k < n
