extends Node2D

const NB_DUPLICATES: int = 5
const SPACING: float = 50.0

@export var angle = 0.0
@onready var hud = $"/root/Node2D/HUD"  # Chemin absolu vers ton HUD
func _ready():
	var original_sprite = $Square  
	if not original_sprite:
		print("No Sprint2D found")
		return

	for i in range(NB_DUPLICATES):
		var duplicated_sprite = original_sprite.duplicate()
		add_child(duplicated_sprite)

		#duplicated_sprite.position = Vector2(
			#original_sprite.position.x + (i + 1) * SPACING,
			#original_sprite.position.y
			#
		#)
		angle = (i + 1) * SPACING
		duplicated_sprite.position = Vector2(
			original_sprite.position.x + cos(angle) * 100,
			original_sprite.position.y + sin(angle) * 100
		)
		duplicated_sprite.rotation = angle
