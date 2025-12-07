extends Node2D

#var NB_DUPLICATES: int = 1.0
const SPACING: float = 50.0
#var original_sprite = $Square  

@export var angle = 0.0

@onready var slider = $Control/HSlider
@onready var old_value: float = slider.value  # Stocke l'ancienne valeur


#### FUNCTION ####
func transform():
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
			original_sprite.position.x + cos(angle) * 0,
			original_sprite.position.y + sin(angle) * 0
		)
		duplicated_sprite.rotation = angle

var nb_duplicates: float = 1.0
var NB_DUPLICATES: int = 1

var old_nb: float = NB_DUPLICATES

func Inputcontrol(slider): # I must making Input to have variable of control inside
	slider = $HSlider
	print(slider) 
	slider = nb_duplicates


func _ready() -> void:
	NB_DUPLICATES = clamp(NB_DUPLICATES, 0, 5)
	#slider = $Control/HSlider


func _process(delta: float) -> void:
	nb_duplicates += delta *1.0           # float qui s'incrémente
	NB_DUPLICATES = int(nb_duplicates)    # conversion propre2.0
	#print(NB_DUPLICATES, " NB_DUPLICATES")
	#if NB_DUPLICATES < 6:
		#if NB_DUPLICATES > old_nb:
			#print("La valeur augmente :", NB_DUPLICATES)
			#transform()
	
	# Met à jour l’ancienne valeur pour la frame suivante
	old_nb = NB_DUPLICATES
	# INPUT
	var slider = $Control/HSlider
	#if slider == 1 : #so for the scene input change for be good whatetever scene
		#print(slider)
	#$Control/HSlider.value
	#print($Control/HSlider.value)
	#print(slider.value)
	#if slider.value_changed:
		#print(slider.value)
		#transform()
	if slider.value != old_value:
		
		print("pouet!")
		transform()
		

func _on_h_slider_value_changed(value: float, slider) -> void:
	transform()
