extends CodeEdit
class_name  ShaderCode
var hide = false
@onready var code = self
#var shader_path = "res://shaders/shaderEmpty.gdshader"
var shader_path = "res://shaders/mainShader.gdshader"
@onready var colorRect = get_node("../../../../ColorRect2")

func _ready():
	var execute = $Execute
	execute.pressed.connect(_on_execute_pressed)
	if colorRect == null:
		print("Error: colorRect is null.")
	
	code.text = GLOBAL.ShaderFrag


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("hide_Code"):
		self.visible = !self.visible
		hide = !self.visible
	
	if Input.is_action_just_pressed("execute_shader"):
		_on_execute_pressed()



func _on_execute_pressed() -> void:
	var user_code = self.text
	

	var mat = colorRect.material
	if mat is ShaderMaterial:
		var shader = mat.shader
		if shader:
			shader.code = user_code 
			GLOBAL.ShaderFrag = user_code
