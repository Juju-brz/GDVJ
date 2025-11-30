extends Control

#@export var ma_variable: float = 0.0
#@onready var slider : HSlider = $HSlider
#
#signal valeur_slider_modifiee(nouvelle_valeur)
#
#func _ready():
	## Remplace "Slider" par le chemin correct
	#if slider:
		#slider.value = ma_variable
		#slider.connect("value_changed", _on_slider_value_changed)
	#else:
		#print("Erreur : Le nœud Slider n'a pas été trouvé !")
#
#func _on_slider_value_changed(valeur):
	#ma_variable = valeur
	#emit_signal("valeur_slider_modifiee", valeur)
