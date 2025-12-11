extends Node2D

#### VARIABLES ####
# Rotation variables
var overall_rotation: float = 0.0
@export var ROTATION_SPEED: float = deg_to_rad(10.0)

# Array for the pattern
var stamp_angles: Array[float] = []

# Gradient Variables
@export var GRADIENT_SPEED: float = 0.1
@export var GRADIENT_ANGLE_SPEED: float = 10.0 # Increased slightly for visibility

# We use the ColorRect only to know the size of the screen
@onready var backsquare = $ColorRect

var current_color_time: float = 0.0
var current_gradient_angle: float = 0.0

const COLOR_PALETTE: Array[Color] = [
	Color("000033"), # Dark Blue
	Color("330033"), # Dark Magenta
	Color("003333"), # Dark Cyan
	Color("000000")  # Black
]

var duplicated_spriteslist: Array = []

#### CORE FUNCTIONS ####

func _ready() -> void:
	$Square.hide()
	
	# HIDE the ColorRect so it doesn't block our custom drawing
	if backsquare:
		backsquare.hide()
	
	# --- GENERATE PATTERN ---
	var current_angle = 45.0
	var add_small_step = true 
	
	while current_angle < 3600.0:
		stamp_angles.append(deg_to_rad(current_angle))
		if add_small_step:
			current_angle += 22.5
		else:
			current_angle += 45.0
		add_small_step = not add_small_step

	draw_board()
	queue_redraw() 

# --- HELPER TO GET COLOR FROM PALETTE ---
func get_gradient_color(time_val: float) -> Color:
	var size = COLOR_PALETTE.size()
	var idx = int(time_val) % size
	var next_idx = (idx + 1) % size
	var t = time_val - float(int(time_val))
	return COLOR_PALETTE[idx].lerp(COLOR_PALETTE[next_idx], t)

func _draw():
	# 1. Determine Screen Size
	var viewport_size = Vector2(1000, 1000)
	if backsquare:
		viewport_size = backsquare.size
	var center = viewport_size / 2.0
	
	# 2. Calculate Gradient Colors
	# To make a gradient, we need TWO different colors at the same time.
	# Color A is the current time. Color B is the next color in the sequence (+1).
	var color_a = get_gradient_color(current_color_time)
	var color_b = get_gradient_color(current_color_time + 1.0) # Offset by 1 to get the next color
	
	# 3. Create a Giant Rotated Rectangle (Polygon)
	# We make it much larger than the screen so edges aren't seen when rotating
	var radius = viewport_size.length() 
	var angle = deg_to_rad(current_gradient_angle)
	
	# Calculate 4 corners rotated around the center
	# Top-Left, Top-Right, Bottom-Right, Bottom-Left
	var tl = center + Vector2(-radius, -radius).rotated(angle)
	var tr = center + Vector2(radius, -radius).rotated(angle)
	var br = center + Vector2(radius, radius).rotated(angle)
	var bl = center + Vector2(-radius, radius).rotated(angle)
	
	var points = PackedVector2Array([tl, tr, br, bl])
	
	# 4. Assign Colors to Vertices
	# Left side gets Color A, Right side gets Color B. Godot interpolates the middle.
	var colors = PackedColorArray([color_a, color_b, color_b, color_a])
	
	# Draw the gradient
	draw_polygon(points, colors)

func clear_board():
	for sprite in duplicated_spriteslist:
		sprite.queue_free()
	duplicated_spriteslist.clear()

func draw_board():
	var center = get_local_mouse_position()
	var original_sprite = $Square
	
	if not original_sprite:
		return

	var create_sprite = func(rot_angle_rad: float):
		var s = original_sprite.duplicate()
		add_child(s)
		s.position = center
		s.rotation = rot_angle_rad
		s.show()
		duplicated_spriteslist.append(s)

	create_sprite.call(0.0)
	
	for target_angle in stamp_angles:
		if overall_rotation >= target_angle:
			create_sprite.call(target_angle)
		else:
			break
		
	create_sprite.call(overall_rotation)

func _process(delta: float) -> void:
	overall_rotation += ROTATION_SPEED * delta
	
	current_color_time += GRADIENT_SPEED * delta
	current_gradient_angle += GRADIENT_ANGLE_SPEED * delta
	queue_redraw() 

	clear_board()
	draw_board()
