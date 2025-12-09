extends Node

func _ready():
	# Connecte le signal "pressed" du bouton à la fonction d'exécution
	var button = $Button
	#button.pressed.connect(_on_button_pressed)
	button.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	print("truc")
	# Récupère le texte du CodeEdit
	
