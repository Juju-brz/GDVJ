extends Node2D
class_name  mainScript

#### VARIABLES ####
var SPACING: float = 50.0
#var original_sprite = $Square  
@export var RADIUS: float = 0.0
@export var angle = 0.0

### CONTROLES ###
@onready var control = $Control
var hide :bool = false
@onready var slider = $Control/VBoxContainer/HSlider #Import Slider Input
@onready var old_slder_value: float = slider.value  

@onready var slider_spacing = $Control/VBoxContainer/HSlider_spacing
@onready var old_slider_spacing_value = slider_spacing.value

var nb_duplicates =  1
var NB_DUPLICATES: int = 1

var old_nb: float = NB_DUPLICATES
var duplicated_sprite
var duplicated_spriteslist = []
var last_sprite
@onready var original_sprite = $Square  


#### FUNCTION ####
func increment(): #ADD SQUARE
	
	if not original_sprite:
		print("No Sprint2D found")
		return

	duplicated_sprite = original_sprite.duplicate()
	add_child(duplicated_sprite)
	angle = duplicated_spriteslist.size() * SPACING
	duplicated_sprite.position = Vector2(
		original_sprite.position.x + cos(angle) * RADIUS,
		original_sprite.position.y + sin(angle) * RADIUS
	)
	duplicated_sprite.rotation = angle
	duplicated_spriteslist.append(duplicated_sprite)
	#print(duplicated_spriteslist)
	#slider_spacing.value = RADIUS


func decrement(): #delete Shape
	if duplicated_spriteslist.size() == 0:
		pass
	else:
		
		last_sprite = duplicated_spriteslist.pop_back()
		last_sprite.queue_free()
		#last_sprite.remove()
		#print(duplicated_spriteslist)
		#NB_DUPLICATES -= 1

func _ready() -> void:
	NB_DUPLICATES = clamp(NB_DUPLICATES, 0, 5)
	control.hide()
	hide = true

func _process(delta: float) -> void:
	#nb_duplicates = 1          # float qui s'incrémente
	NB_DUPLICATES = int(nb_duplicates)    # conversion propre2.0

	old_nb = NB_DUPLICATES
	# INPUT #
	
	#THIS make the change of shape
	if slider.value > old_slder_value:
		
		print("increment!")
		increment()
		old_slder_value = slider.value # for modify value again
		nb_duplicates += 1
		
	if slider.value < old_slder_value:
		print("decrement!")
		decrement()
		old_slder_value = slider.value  # for modify value again
		nb_duplicates -= 1
		#last_sprite = duplicated_spriteslist.pop_back()
	
	if slider_spacing.value > old_slider_spacing_value:
		RADIUS = RADIUS + 1
		print(RADIUS)
		old_slider_spacing_value = slider_spacing.value
	
	if slider_spacing.value < old_slider_spacing_value:
		RADIUS = RADIUS - 1
		print(RADIUS)
		old_slider_spacing_value = slider_spacing.value
	
	


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("hide_all_ctrl"):

		if hide:
			control.show()
			hide = false
		else:
			control.hide()
			hide = true
			

	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
