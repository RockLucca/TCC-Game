shader_type canvas_item;
render_mode blend_mix, unshaded;

// 0 = normal, 1 = protanopia, 2 = deuteranopia, 3 = tritanopia
uniform int filter_type : hint_range(0, 3) = 0;
uniform float intensity : hint_range(0.0, 1.0) = 1.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec3 filtered = color.rgb;
	
	if (filter_type == 1) { // Protanopia
		mat3 protanopia = mat3(
			vec3(0.567, 0.433, 0.0),
			vec3(0.558, 0.442, 0.0),
			vec3(0.0,   0.242, 0.758)
		);
		filtered = protanopia * color.rgb;
	}
	else if (filter_type == 2) { // Deuteranopia
		mat3 deuteranopia = mat3(
			vec3(0.625, 0.375, 0.0),
			vec3(0.7,   0.3,   0.0),
			vec3(0.0,   0.3,   0.7)
		);
		filtered = deuteranopia * color.rgb;
	}
	else if (filter_type == 3) { // Tritanopia
		mat3 tritanopia = mat3(
			vec3(0.95,  0.05,  0.0),
			vec3(0.0,   0.433, 0.567),
			vec3(0.0,   0.475, 0.525)
		);
		filtered = tritanopia * color.rgb;
	}
	
	color.rgb = mix(color.rgb, filtered, intensity);
	COLOR = color;
	
}