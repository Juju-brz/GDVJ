extends Node2D

#### VARIABLES ####
# Rotation variables
var overall_rotation: float = 0.0
@export var ROTATION_SPEED: float = deg_to_rad(10.0) # Very slow rotation

# This array will hold the generated angles: 45, 67.5, 112.5, 135, 180...
var stamp_angles: Array[float] = []

# Gradient Variables
@export var GRADIENT_SPEED: float = 0.1         
@export var GRADIENT_ANGLE_SPEED: float = 5.0   
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
	
	# --- GENERATE THE PATTERN AUTOMATICALLY ---
	# We start at 45 degrees
	var current_angle = 45.0
	
	# We want to toggle between adding 22.5 and 45.0
	# Pattern: 45 -> (+22.5) -> 67.5 -> (+45) -> 112.5 -> (+22.5) -> 135 ...
	var add_small_step = true 
	
	# Generate angles for a long time (e.g., up to 3600 degrees / 10 laps)
	while current_angle < 3600.0:
		stamp_angles.append(deg_to_rad(current_angle))
		
		if add_small_step:
			current_angle += 22.5
		else:
			current_angle += 45.0
			
		# Flip the toggle for the next step
		add_small_step = not add_small_step

	draw_board()
	queue_redraw() 

func _draw():
	# --- Draw Rotating Gradient Background (UNCHANGED) ---
	var viewport_size = get_viewport_rect().size
	var center = viewport_size / 2.0
	
	# Color Cycling
	var palette_size = COLOR_PALETTE.size()
	var cycle_index = int(current_color_time) % palette_size
	var next_cycle_index = (cycle_index + 1) % palette_size
	var lerp_factor = current_color_time - float(int(current_color_time))
	var current_color = COLOR_PALETTE[cycle_index].lerp(COLOR_PALETTE[next_cycle_index], lerp_factor)
	
	# Gradient Orientation
	var angle_rad = deg_to_rad(current_gradient_angle)
	var line_length = viewport_size.length() 
	var gradient_start_pos = center + Vector2.RIGHT.rotated(angle_rad) * line_length
	var gradient_end_pos = center + Vector2.LEFT.rotated(angle_rad) * line_length

	# Draw Background
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color.BLACK, true)
	draw_line(gradient_start_pos, gradient_end_pos, current_color, line_length * 2.0, true)

func clear_board():
	for sprite in duplicated_spriteslist:
		sprite.queue_free()
	duplicated_spriteslist.clear()

# --- EXACT SAME LOGIC, BUT USING THE LIST ---
func draw_board():
	var center = get_local_mouse_position()
	var original_sprite = $Square
	
	if not original_sprite:
		return

	# Helper to create a sprite quickly
	var create_sprite = func(rot_angle_rad: float):
		var s = original_sprite.duplicate()
		add_child(s)
		s.position = center
		s.rotation = rot_angle_rad
		s.show()
		duplicated_spriteslist.append(s)

	# 1. SQUARE A (Static Base at 0)
	create_sprite.call(0.0)
	
	# 2. CHECK ALL STAMPS
	# This replaces the manual "if current_deg > ANGLE_C" lines
	# It loops through the generated list and draws every stamp passed so far.
	for target_angle in stamp_angles:
		if overall_rotation >= target_angle:
			create_sprite.call(target_angle)
		else:
			# Optimization: Since the list is sorted, if we haven't reached this one,
			# we haven't reached the rest either.
			break
		
	# 3. SQUARE B (The Active Rotator)
	create_sprite.call(overall_rotation)

func _process(delta: float) -> void:
	# Update Rotation
	overall_rotation += ROTATION_SPEED * delta
	
	# Update Gradient
	current_color_time += GRADIENT_SPEED * delta
	current_gradient_angle += GRADIENT_ANGLE_SPEED * delta
	queue_redraw() 

	# Redraw Sprites
	clear_board()
	draw_board()
