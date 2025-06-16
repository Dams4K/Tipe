shader_type spatial;
//render_mode vertex_lighting;

uniform float max_height = 1.0;
uniform sampler2D height_map: hint_default_black, filter_nearest;

float getHeight(vec2 vertex) {
	ivec2 size = textureSize(height_map, 0);

	vec2 position = (vertex + vec2(size)/2.0) / vec2(size);
	return textureLod(height_map, position, 0).y * max_height;
}

void vertex() {
	float c_height = getHeight(VERTEX.xz);
	VERTEX.y = c_height;

	vec3 C = vec3(VERTEX.x, c_height, VERTEX.z);
	vec3 B = vec3(VERTEX.x+1.0, 0.0, VERTEX.z);
	B.y = getHeight(B.xz);
	vec3 A = vec3(VERTEX.x+1.0, 0.0, VERTEX.z+1.0);
	A.y = getHeight(A.xz);

	NORMAL = normalize(cross(B - A, C - A));
}

void fragment() {
	//ALBEDO = vec3(getHeight(UV + offset));
	//ALBEDO = vec3(VERTEX.xy, 1.0);
}