shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec4 color_light = vec4(227.0, 239.0, 223.0, 255.0);
uniform vec4 color_light_mid = vec4(165.0, 206.0, 187.0, 255.0);
uniform vec4 color_dark_mid = vec4(87.0, 158.0, 148.0, 255.0);
uniform vec4 color_dark = vec4(35.0, 76.0, 89.0, 255.0);

// Which color you want to change
uniform vec4 u_color_key : source_color = vec4(35.0, 76.0, 89.0, 255.0);
// Which color to replace it with
uniform vec4 u_new_color : source_color = vec4(227.0, 239.0, 223.0, 255.0);
// How much tolerance for the replacement color (between 0 and 1)
uniform float u_tolerance = 0.5;

void fragment() {
	// Get color from the sprite texture at the current pixel we are rendering
	//vec4 original_color = vec4(texture(SCREEN_TEXTURE, SCREEN_UV).rgb, texture(TEXTURE, UV).a);
	vec4 original_color = texture(TEXTURE, UV);
	vec3 color = original_color.rgb;

	// Get a rough degree of difference between the texture color and the color key
	vec3 diff3 = color - u_color_key.rgb;
	float m = max(max(abs(diff3.r), abs(diff3.g)), abs(diff3.b));

	// Change color of pixels below tolerance threshold, while keeping shades if any (a bit naive, there may better ways)
	float brightness = length(color);
	color = mix(color, u_new_color.rgb * brightness, step(m, u_tolerance));

	// Assign final color for the pixel, and preserve transparency
	COLOR = vec4(color.rgb, original_color.a);
}

/*
void vertex() {
	// Called for every vertex the material is visible on.
}
*/

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
