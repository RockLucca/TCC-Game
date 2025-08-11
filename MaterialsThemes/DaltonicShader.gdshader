shader_type canvas_item;
render_mode blend_mix;

uniform int filter_type : hint_range(0, 3) = 0; 
// 0 = normal, 1 = protanopia, 2 = deuteranopia, 3 = tritanopia

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (filter_type == 1) { // Protanopia
		mat3 protanopia = mat3(
			vec3(0.567, 0.433, 0.0),
			vec3(0.558, 0.442, 0.0),
			vec3(0.0,   0.242, 0.758)
		);
		color.rgb = protanopia * color.rgb;
	}
	else if (filter_type == 2) { // Deuteranopia
		mat3 deuteranopia = mat3(
			vec3(0.625, 0.375, 0.0),
			vec3(0.7,   0.3,   0.0),
			vec3(0.0,   0.3,   0.7)
		);
		color.rgb = deuteranopia * color.rgb;
	}
	else if (filter_type == 3) { // Tritanopia
		mat3 tritanopia = mat3(
			vec3(0.95,  0.05,  0.0),
			vec3(0.0,   0.433, 0.567),
			vec3(0.0,   0.475, 0.525)
		);
		color.rgb = tritanopia * color.rgb;
	}
	color.a *= COLOR.a;
	COLOR = color;
	
}