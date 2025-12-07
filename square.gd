extends Node2D

#### VARIABLES ####
const SPACING: float = 50.0
#var original_sprite = $Square  
const RADIUS: float = 0.0
@export var angle = 0.0
@onready var slider = $Control/VBoxContainer/HSlider #Import Slider Input
@onready var old_slder_value: float = slider.value  # Stocke l'ancienne valeur
var nb_duplicates =  1
var NB_DUPLICATES: int = 1

var old_nb: float = NB_DUPLICATES
var duplicated_sprite
var duplicated_spriteslist = []
var last_sprite

#### FUNCTION ####
func increment():
	var original_sprite = $Square  
	if not original_sprite:
		print("No Sprint2D found")
		return

	var duplicated_sprite = original_sprite.duplicate()
	add_child(duplicated_sprite)
	var angle = duplicated_spriteslist.size() * SPACING
	duplicated_sprite.position = Vector2(
		original_sprite.position.x + cos(angle) * RADIUS,
		original_sprite.position.y + sin(angle) * RADIUS
	)
	duplicated_sprite.rotation = angle
	duplicated_spriteslist.append(duplicated_sprite)
	print(duplicated_spriteslist)

func decrement():
	#duplicated_sprite.queue_free()
	if duplicated_spriteslist.size() == 0:
		pass
	else:
		
		last_sprite = duplicated_spriteslist.pop_back()
		last_sprite.queue_free()
		#last_sprite.remove()
		print(duplicated_spriteslist)
		#NB_DUPLICATES -= 1

func _ready() -> void:
	NB_DUPLICATES = clamp(NB_DUPLICATES, 0, 5)
	#slider = $Control/HSlider


func _process(delta: float) -> void:
	#nb_duplicates = 1          # float qui s'incrémente
	NB_DUPLICATES = int(nb_duplicates)    # conversion propre2.0

	old_nb = NB_DUPLICATES
	# INPUT
	
	#THIS make the change of square
	if slider.value > old_slder_value:
		
		print("pouet!")
		increment()
		old_slder_value = slider.value
		nb_duplicates += 1
		
	if slider.value < old_slder_value:
		print("proute!")
		decrement()
		old_slder_value = slider.value
		nb_duplicates -= 1
		#last_sprite = duplicated_spriteslist.pop_back()
