extends Node2D

#### VARIABLES ####
@export var RADIUS: float = 50.0         # Radius of each circle
@export var SPACING: float = 50.0        # Angular spacing between sprites
@export var NB_DUPLICATES: int = 6       # Number of sprites per circle
@export var NB_GROUPS: int = 1           # Number of duplicated groups
@export var GROUP_OFFSET_MULT: float = 3.0  # Multiplier for offset distance

### CONTROLS ###
@onready var control = $Control
var hide: bool = false

@onready var slider = $Control/VBoxContainer/HSlider               # Number of sprites per circle
@onready var slider_spacing = $Control/VBoxContainer/HSlider_spacing  # Spacing
@onready var slider_nb_groups = $Control/VBoxContainer/HSlider_nb_groups
@onready var slider_group_offset = $Control/VBoxContainer/HSlider_group_offset

var duplicated_spriteslist: Array = []

#### FUNCTION ####
func clear_board():
	for sprite in duplicated_spriteslist:
		sprite.queue_free()
	duplicated_spriteslist.clear()

func draw_board():
	var center = get_local_mouse_position()
	var original_sprite = $Square
	if not original_sprite:
		print("No Sprite2D found")
		return
	
	# Compute offsets for groups
	var group_offsets: Array = []
	group_offsets.append(Vector2(0, 0)) # main group
	var offset_distance = RADIUS * GROUP_OFFSET_MULT
	
	# create other groups in +/- directions
	for i in range(1, NB_GROUPS + 1):
		group_offsets.append(Vector2(offset_distance * i, offset_distance * i))
		group_offsets.append(Vector2(-offset_distance * i, offset_distance * i))
		group_offsets.append(Vector2(offset_distance * i, -offset_distance * i))
		group_offsets.append(Vector2(-offset_distance * i, -offset_distance * i))
	
	# Draw each group
	for group_offset in group_offsets:
		for i in range(NB_DUPLICATES):
			var angle = i * SPACING
			var duplicated_sprite = original_sprite.duplicate()
			add_child(duplicated_sprite)
			duplicated_sprite.position = center + group_offset + Vector2(cos(angle), sin(angle)) * RADIUS
			duplicated_sprite.rotation = angle
			duplicated_sprite.show()
			duplicated_spriteslist.append(duplicated_sprite)

func _ready() -> void:
	NB_DUPLICATES = clamp(NB_DUPLICATES, 0, 100)
	$Square.hide()  # hide the original sprite

func _process(delta: float) -> void:
	# Update sliders
	NB_DUPLICATES = int(slider.value)
	SPACING = slider_spacing.value
	NB_GROUPS = int(slider_nb_groups.value)
	GROUP_OFFSET_MULT = slider_group_offset.value
	
	# Redraw every frame
	clear_board()
	draw_board()
	
	# Hide / Show Con
