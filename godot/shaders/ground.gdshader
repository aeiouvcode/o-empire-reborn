// Field ground: pale paper grass with darker drifts, diagonal tuft strokes, and a worn road.
shader_type spatial;
render_mode diffuse_lambert, specular_disabled;

uniform float scorch_z = -330.0;
varying vec3 wp;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}
float path_x(float z) { return sin(z * 0.012) * 6.0 + sin(z * 0.031) * 2.0; }

void vertex() { wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }

void fragment() {
	vec2 p = wp.xz;
	float n = noise(p * 0.06) * 0.55 + noise(p * 0.21) * 0.3 + noise(p * 0.9) * 0.15;
	float base = mix(0.34, 0.76, smoothstep(0.30, 0.70, n));
	// tuft strokes, diagonal like the reference's grass dashes
	vec2 g = p * 1.5;
	vec2 gi = floor(g);
	vec2 gf = fract(g) - 0.5;
	float h = hash(gi);
	vec2 off = vec2(hash(gi + 7.0) - 0.5, hash(gi + 13.0) - 0.5) * 0.45;
	vec2 q = gf - off;
	vec2 rq = vec2(q.x * 0.8 + q.y * 0.6, -q.x * 0.6 + q.y * 0.8);
	float stroke = step(abs(rq.y), 0.06) * step(abs(rq.x), 0.24) * step(0.45, h);
	base *= 1.0 - stroke * 0.5;
	float road = smoothstep(1.3, 0.7, abs(p.x - path_x(p.y) + (noise(p * 0.7) - 0.5) * 0.8));
	base = mix(base, 0.74, road * 0.5);
	float sc = smoothstep(9.0, 3.0, length(p - vec2(path_x(scorch_z) + 7.0, scorch_z)));
	base = mix(base, 0.2 + noise(p * 2.0) * 0.15, sc);
	ALBEDO = vec3(base);
	ROUGHNESS = 1.0;
}
