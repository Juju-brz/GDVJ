shader_type canvas_item;

void fragment() {
	
	vec3 color1 = vec3(0.54, 0.13, 0.52); 
	vec3 color2 = vec3(0.94, 0.44, 0.42); 
	vec3 color3 = vec3(0.91, 0.25, 0.34); 
	vec2 uv = UV;
	float facteur = 0.4;  // Facteur de mélange (0.0 à 1.0)
	//uv += vec2(0.4, 0.4);
	//float valeur_melangee = mix(uv.x, facteur, 0.5);  // Mélange à 50%

	vec3 col = mix(color1, color2, uv.x + sin(TIME *0.5) *0.5);
	COLOR = vec4(col, 0.5);
}
