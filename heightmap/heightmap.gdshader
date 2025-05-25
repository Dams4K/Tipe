shader_type spatial;
//render_mode vertex_lighting;

uniform float max_height = 1.0;
uniform sampler2D height_map: hint_default_black, filter_nearest;
uniform vec2 offset = vec2(0.0, 0.0);
uniform vec2 resolution = vec2(16.0, 16.0);

float getHeight(vec2 uv) {
	return textureLod(height_map, uv, 0).y * max_height;
}
void vertex() {

	vec2 vertex_step = vec2(1.0) / resolution;

	vec3 b = vec3(UV.x + offset.x, getHeight(UV + offset), UV.y + offset.y);
	vec3 a = vec3(UV.x + vertex_step.x + offset.x, getHeight(UV + vec2(vertex_step.x, 0.0) + offset), UV.y + offset.y);
	vec3 c = vec3(UV.x + offset.x, getHeight(UV + vec2(0.0, vertex_step.x) + offset), UV.y + vertex_step.y + offset.y);

	float height = getHeight(VERTEX.xy * vertex_step + vec2(0.5));
	VERTEX.y = height;

	NORMAL = normalize(cross(b - a, c - a));
}
