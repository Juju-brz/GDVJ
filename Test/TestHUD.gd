extends Control

@onready var slider = $HSlider  # Assure-toi que le nom du Slider est correct
@onready var color_rect = get_parent().get_node("ColorRect")  # Chemin vers le ColorRect

func _ready():
	# Vérifie que le Slider et le ColorRect existent
	if slider and color_rect:
		slider.value_changed.connect(_on_slider_changed)
	else:
		print("Erreur : Slider ou ColorRect non trouvé !")

func _on_slider_changed(value):
	# Vérifie que le ColorRect a un ShaderMaterial
	#if color_rect.material is ShaderMaterial:
		#var shader_material = color_rect.material as ShaderMaterial
		#shader_material.set_shader_parameter("angle", valeur)
		#print("Nouvelle valeur de l'angle : ", valeur)  # Pour déboguer
	#else:
		#print("Erreur : Le ColorRect n'a pas de ShaderMaterial !")
	if color_rect:
		color_rect.position.x = value * 10
