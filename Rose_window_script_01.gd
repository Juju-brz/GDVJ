extends Node2D

#### VARIABLES ####
@export var RADIUS: float = 30.0	# Radius of each circle
@export var SPACING: float = 50.0	# Angular spacing between sprites
@export var NB_DUPLICATES: int = 6	# Number of sprites per circle
# New variables for Grid Control:
@export var GRID_WIDTH: int = 5         # Number of groups horizontally
@export var GRID_HEIGHT: int = 4        # Number of groups vertically
@export var GRID_SPACING_MULT: float = 5.0 # Multiplier for distance between grid centers
# Removed NB_GROUPS and GROUP_OFFSET_MULT as they are replaced by the grid variables

@export var Angle_rotation:float = 15.0 

### ROTATION VARIABLES ###
var group_data: Array = [] 
var base_rotation_speed: float = 0.5 
var overall_rotation: float = 0.0 
var overall_rotation_speed: float = deg_to_rad(10.0) 

### CONTROLS ###
@onready var control = $Control
var hide: bool = false

@onready var slider = $Control/VBoxContainer/HSlider
@onready var slider_spacing = $Control/VBoxContainer/HSlider_spacing
# Assuming you will now use sliders to control GRID_WIDTH/HEIGHT instead of NB_GROUPS/GROUP_OFFSET
@onready var slider_grid_width = $Control/VBoxContainer/HSlider_grid_width # You'll need to update your scene
@onready var slider_grid_height = $Control/VBoxContainer/HSlider_grid_height # You'll need to update your scene

var duplicated_spriteslist: Array = []

#### FUNCTION ####
func clear_board():
	for sprite in duplicated_spriteslist:
		sprite.queue_free()
	duplicated_spriteslist.clear()

# --- MODIFIED: Uses GRID_WIDTH/HEIGHT for brick pattern ---
func setup_group_data():
	group_data.clear()
	
	# Compute offsets for groups (center points of each brick/cell)
	var group_offsets: Array = []
	var cell_width = RADIUS * GRID_SPACING_MULT
	var cell_height = RADIUS * GRID_SPACING_MULT * sqrt(3.0) / 2.0
	
	var row_offset_x_final = 0.0 # **<-- FIX 1: Declare outside the main loop**
	
	for row in range(GRID_HEIGHT):
		# Determine the horizontal offset for the staggered effect
		var row_offset_x = 0.0
		if row % 2 != 0: # Every second row is offset (the "stagger")
			row_offset_x = cell_width / 2.0
		
		# **<-- FIX 2: Store the offset of the last row for centering**
		if row == GRID_HEIGHT - 1:
			row_offset_x_final = row_offset_x
			
		for col in range(GRID_WIDTH):
			var x = col * cell_width + row_offset_x
			var y = row * cell_height
			
			group_offsets.append(Vector2(x, y))
	
	# Center the entire grid
	# Use the value stored from the last row (or calculated before)
	var total_width = (GRID_WIDTH - 1) * cell_width + row_offset_x_final
	var total_height = (GRID_HEIGHT - 1) * cell_height
	var center_offset = Vector2(total_width / 2.0, total_height / 2.0)
	
	# Assign unique rotation speed and center the group offsets
	var rotation_speeds = [
		base_rotation_speed * 1.0, 
		base_rotation_speed * 1.2,  
		-base_rotation_speed * 0.8, 
		-base_rotation_speed * 1.5, 
		base_rotation_speed * 0.9,
		-base_rotation_speed * 1.1,
	]
	
	for i in range(group_offsets.size()):
		var speed = rotation_speeds[i % rotation_speeds.size()]
		group_data.append({
			"offset": group_offsets[i] - center_offset, # Apply centering here
			"rotation_speed": speed,
			"current_rotation": 0.0
		})

func draw_board():
	var center = get_local_mouse_position()
	var original_sprite = $Square
	if not original_sprite:
		print("No Sprite2D found")
		return
	
	# Redraw based on group_data
	for group in group_data:
		var group_offset = group.offset
		var current_group_rotation = group.current_rotation
		
		# 1. Apply the overall board rotation to the group's offset
		var rotated_group_offset = group_offset.rotated(overall_rotation) 
		
		for i in range(NB_DUPLICATES):
			var angle = deg_to_rad(i * SPACING)
			
			# 2. Calculate the sprite's position relative to its group center (local rotation)
			var radius_vector = Vector2(cos(angle), sin(angle)) * RADIUS
			var rotated_radius_vector = radius_vector.rotated(current_group_rotation)
			
			var duplicated_sprite = original_sprite.duplicate()
			add_child(duplicated_sprite)
			
			# 3. Final Position Calculation: Main Center + Rotated Group Offset + Rotated Radius Vector
			duplicated_sprite.position = center + rotated_group_offset + rotated_radius_vector
			
			duplicated_sprite.rotation = angle
			duplicated_sprite.show()
			duplicated_spriteslist.append(duplicated_sprite)

func _ready() -> void:
	NB_DUPLICATES = clamp(NB_DUPLICATES, 0, 100)
	$Square.hide()
	setup_group_data()

func _process(delta: float) -> void:
	
	# --- Update Overall Board Rotation ---
	overall_rotation += overall_rotation_speed * delta 
	
	# Check if group structure has changed
	var new_grid_width = int(slider_grid_width.value)
	var new_grid_height = int(slider_grid_height.value)

	if new_grid_width != GRID_WIDTH or new_grid_height != GRID_HEIGHT:
		GRID_WIDTH = new_grid_width
		GRID_HEIGHT = new_grid_height
		setup_group_data() # Re-setup the groups if their number changes

	# Update other sliders
	NB_DUPLICATES = int(slider.value)
	SPACING = slider_spacing.value
	
	# Update Rotation of each individual group
	for group in group_data:
		group.current_rotation += group.rotation_speed * delta

	# Redraw
	clear_board()
	draw_board()
