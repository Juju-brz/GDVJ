shader_type canvas_item;


uniform vec2 offset = vec2(50.0, 0.0);
uniform float speed = 1.0;

void vertex() {
	//UV.x = UV.x -0.2 * sin(TIME);
	//VERTEX += offset;
	//VERTEX -= vec2(0.5, 0.5);
	float angle = TIME * speed;
	
	float s = sin(angle);
	float c = cos(angle);
	
	mat2 rot = mat2(
		vec2(c, -s),
		vec2(s,  c));
	VERTEX = rot * VERTEX;
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
