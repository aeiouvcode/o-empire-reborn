// Print-plate halftone: every low-res scene pixel becomes one dot cell on warm paper.
// Greys are posterised to six plate tones and ordered-dithered between neighbours;
// saturated reds survive as a separate scarlet plate, slightly misregistered.
shader_type canvas_item;

uniform sampler2D scene : filter_nearest;
uniform vec2 cells = vec2(132.0, 286.0);
uniform float time = 0.0;
uniform float fade = 0.0;
uniform float tone = 1.0;
uniform float exposure = 1.0;
uniform vec2 red_offset = vec2(0.18, -0.12);

const vec3 PAL[6] = vec3[](
	vec3(0.155, 0.137, 0.153),
	vec3(0.318, 0.286, 0.310),
	vec3(0.498, 0.463, 0.486),
	vec3(0.690, 0.659, 0.667),
	vec3(0.850, 0.827, 0.780),
	vec3(0.945, 0.918, 0.835)
);

float bayer4(vec2 p) {
	int x = int(mod(p.x, 4.0));
	int y = int(mod(p.y, 4.0));
	int i = x + y * 4;
	float m[16] = float[](0., 8., 2., 10., 12., 4., 14., 6., 3., 11., 1., 9., 15., 7., 13., 5.);
	return (m[i] + 0.5) / 16.0;
}

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

void fragment() {
	vec2 c = UV * cells;
	vec2 ci = floor(c);
	vec2 f = fract(c) - 0.5;
	float aa = max(fwidth(c.x), 0.02) * 0.9;
	vec3 col = texture(scene, (ci + 0.5) / cells).rgb;
	float L = pow(clamp(dot(col, vec3(0.299, 0.587, 0.114)) * exposure, 0.0, 1.0), tone);
	float v = pow(L, 0.95) * 5.0 + (bayer4(ci) - 0.5) * 0.9;
	float lo = clamp(floor(v), 0.0, 4.0);
	float t = clamp(v - lo, 0.0, 1.0);
	vec3 a = PAL[int(lo)];
	vec3 b = PAL[int(lo) + 1];
	float r = mix(0.2, 0.56, t);
	float d = length(f);
	vec3 o = mix(a, b, smoothstep(r + aa, r - aa, d));

	// scarlet plate: sampled with a small registration offset
	vec2 rc = c + red_offset;
	vec2 rci = floor(rc);
	vec2 rf = fract(rc) - 0.5;
	vec3 rcol = texture(scene, (rci + 0.5) / cells).rgb;
	float redness = clamp((rcol.r - max(rcol.g, rcol.b)) * 2.6 - 0.18, 0.0, 1.0);
	if (redness > 0.05) {
		float rl = clamp(dot(rcol, vec3(0.5, 0.3, 0.2)) * 2.0, 0.0, 1.0);
		vec3 red = mix(vec3(0.50, 0.08, 0.10), vec3(0.87, 0.20, 0.19), rl);
		float rr = 0.30 + 0.22 * redness;
		o = mix(o, red, smoothstep(rr + aa, rr - aa, length(rf)));
	}

	// paper grain
	float g = hash(floor(FRAGCOORD.xy) + floor(time * 6.0)) - 0.5;
	o += g * 0.035;

	// rounded viewfinder vignette like the reference frames
	vec2 q = abs(UV - 0.5) * 2.0;
	vec2 asp = vec2(1.0, cells.y / cells.x);
	vec2 qq = (q - (1.0 - 0.10 / asp)) * asp;
	float corner = length(max(qq, 0.0)) / 0.10;
	float edge = max(q.x, q.y);
	float vig = smoothstep(0.55, 1.05, edge) * 0.35 + smoothstep(0.55, 1.0, corner) * 0.9;
	o *= 1.0 - clamp(vig, 0.0, 1.0);
	o = mix(o, vec3(0.0), fade);
	COLOR = vec4(o, 1.0);
}
