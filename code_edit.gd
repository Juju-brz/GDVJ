extends CodeEdit

var hide = false
@onready var code = $CodeEdit
var shader_path = "res://shaders/shaderEmpty.gdshader"
@onready var colorRect = get_node("../../ColorRect2")  # Remonte de deux niveaux

func _ready():
	var button = $Button
	button.pressed.connect(_on_button_pressed)
	if colorRect == null:
		print("Error: colorRect is null.")

func _on_button_pressed():
	var user_code = self.text
	

	var mat = colorRect.material
	if mat is ShaderMaterial:
		var shader = mat.shader
		if shader:
			shader.code = user_code   # ✔️ Modifie directement le shader


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("hide_Code"):
		self.visible = !self.visible
		hide = !self.visible
	
	if Input.is_action_just_pressed("execute_shader"):
		_on_button_pressed()
