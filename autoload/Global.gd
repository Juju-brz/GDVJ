extends Node

var ShaderFrag = "shader_type canvas_item;

void fragment() {


	vec3 color1 = vec3(1.0, 0.5, 0.0); //orange
	vec3 color2 = vec3(0.3, 0.4, 0.7); //blue
	vec3 color3 = vec3(0.3, 1.0, 0.3); // green
	vec2 uv = UV;

	vec3 color = mix(color3, color2, uv.x + sin(TIME *0.5));
	COLOR = vec4(color, 0.5);
}"
var ShaderVer = "shader_type canvas_item; 


void vertex() {
	vec2 uv = UV;
	
	vec3 red = vec3(1.0, 0.0, 0.0);
	vec3 green = vec3(0.0, 1.0, 0.0);
	vec3 blue = vec3(0.0, 0.0, 1.0);
	
	vec3 white =  vec3(1.0, 1.0, 1.0);
	vec3 black =  vec3(0.0, 0.0, 0.0);

	vec3 color =  vec3(1.0, 1.0, 1.0);
    COLOR =  vec4(color, 1.0);
	
	VERTEX;
}"

var mouse_activation = true
#var ShaderVer = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
