shader_type canvas_item;

void fragment() {


	vec3 color1 = vec3(1.0, 0.5, 0.0); //orange
	vec3 color2 = vec3(0.3, 0.4, 0.7); //blue
	vec3 color3 = vec3(0.3, 1.0, 0.0); // green
	vec2 uv = UV;

	vec3 color = mix(color3, color2, uv.x + sin(TIME *0.5));
	COLOR = vec4(color, 0.5);
}
