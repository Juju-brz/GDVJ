extends Node

var score: int = 0
var scriptFragShader = "shader_type canvas_item;

void fragment() {


	vec3 color1 = vec3(1.0, 0.5, 0.0); //orange
	vec3 color2 = vec3(0.3, 0.4, 0.7); //blue
	vec3 color3 = vec3(0.3, 1.0, 0.3); // green
	vec2 uv = UV;

	vec3 color = mix(color3, color2, uv.x + sin(TIME *0.5));
	COLOR = vec4(color, 0.5);
}
"

#var scriptFragShader: Shader = null

func add_score(value: int):
	score += value
	print("Score:", score)


func update_script(shader):
	scriptFragShader = shader
	print("hooyooo")
	#return scriptFragShader
