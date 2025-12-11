shader_type canvas_item;

void fragment() {
	vec3 color1 = vec3(1.0, 0.5, 0.0); //orange
	vec3 color2 = vec3(0.3, 0.4, 0.7); //blue
	vec3 color3 = vec3(0.5, 1.0, 0.0); // green
	vec2 uv = UV;
	float facteur = 0.4;  // Facteur de mélange (0.0 à 1.0)
	uv += vec2(0.4, 0.4);
	//float valeur_melangee = mix(uv.x, facteur, 0.5);  // Mélange à 50%

	vec3 col = mix(color3, color2, uv.x + sin(TIME *0.5));
	COLOR = vec4(col, 0.5);
}
