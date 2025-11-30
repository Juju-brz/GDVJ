extends Node2D

# Nombre de duplicatas souhaités
const NB_DUPLICATES: int = 5
# Espacement entre chaque duplicata
const SPACING: float = 50.0

func _ready():
	var original_sprite = $Square  # Remplace par le chemin correct

	if not original_sprite:
		print("Erreur : Le nœud Sprite2D n'a pas été trouvé !")
		return

	for i in range(NB_DUPLICATES):
		var duplicated_sprite = original_sprite.duplicate()
		add_child(duplicated_sprite)

		# Positionne chaque duplicata à côté de l'original
		duplicated_sprite.position = Vector2(
			original_sprite.position.x + (i + 1) * SPACING,
			original_sprite.position.y
		)

		# Optionnel : Change la couleur pour les distinguer
		duplicated_sprite.modulate = Color(
			randf_range(0.5, 1.0),
			randf_range(0.5, 1.0),
			randf_range(0.5, 1.0)
		)
