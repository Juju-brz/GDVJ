extends CodeEdit

var hide = false
@onready var code = $CodeEdit
var shader_path = "res://shaders/shaderEmpty.gdshader"
@onready var colorRect = get_node("../../ColorRect2")  # Remonte de deux niveaux

func _ready():
	var execute = $Execute
	execute.pressed.connect(_on_execute_pressed)
	if colorRect == null:
		print("Error: colorRect is null.")


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("hide_Code"):
		self.visible = !self.visible
		hide = !self.visible
	
	if Input.is_action_just_pressed("execute_shader"):
		_on_execute_pressed()


#func Fontlarge():
	#var font = code
	#if font:
		#font.font_size = 32  # Modifie la taille du Font
		#$CodeEdit.add_font_override("font", font)  # Applique le changement


func _on_execute_pressed() -> void:
	var user_code = self.text
	

	var mat = colorRect.material
	if mat is ShaderMaterial:
		var shader = mat.shader
		if shader:
			shader.code = user_code   # ✔️ Modifie directement le shader
			
