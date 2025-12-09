extends CodeEdit

var hide = false
@onready var code = $CodeEdit
var shader_path = "res://shaders/shaderEmpty.gdshader"
@onready var colorRect = get_node("../../ColorRect")  # Remonte de deux niveaux

func _ready():
	var button = $Button
	button.pressed.connect(_on_button_pressed)

	print("ColorRect trouvé ?", colorRect != null)
	if colorRect:
		print("Matériau du ColorRect :", colorRect.material)
	else:
		print("Erreur : ColorRect non trouvé !")

func _on_button_pressed():
	var user_code = self.text
	
	if not colorRect:
		print("ColorRect introuvable")
		return

	var mat = colorRect.material
	if mat is ShaderMaterial:
		var shader = mat.shader
		if shader:
			shader.code = user_code   # ✔️ Modifie directement le shader
			print("Shader modifié !")
		else:
			print("Ce ShaderMaterial n'a pas de shader !")
	else:
		print("Le matériau n'est pas un ShaderMaterial !")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("hide_Code"):
		self.visible = !self.visible
		hide = !self.visible
