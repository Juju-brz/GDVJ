extends Node2D

#### VARIABLES ####

# --- GRID VARIABLES ---
@export var GRID_COLUMNS: int = 10    # Horizontal count
@export var GRID_ROWS: int = 5        # Vertical count

# Set this to the exact width of your square texture
@export var CELL_SIZE: float = 100.0  

# --- ROTATION VARIABLES ---
var overall_rotation: float = 0.0
@export var ROTATION_SPEED: float = deg_to_rad(10.0)

# Array for the star pattern angles
var stamp_angles: Array[float] = []

# --- GRADIENT VARIABLES ---
@export var GRADIENT_SPEED: float = 0.1
@export var GRADIENT_ANGLE_SPEED: float = 10.0
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
	if backsquare:
		backsquare.hide()
	
	# --- GENERATE PATTERN ANGLES ---
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

# --- HELPER: GRADIENT COLOR ---
func get_gradient_color(time_val: float) -> Color:
	var size = COLOR_PALETTE.size()
	var idx = int(time_val) % size
	var next_idx = (idx + 1) % size
	var t = time_val - float(int(time_val))
	return COLOR_PALETTE[idx].lerp(COLOR_PALETTE[next_idx], t)

# --- BACKGROUND DRAWING ---
func _draw():
	var viewport_size = Vector2(1000, 1000)
	if backsquare:
		viewport_size = backsquare.size
	var center = viewport_size / 2.0
	
	var color_a = get_gradient_color(current_color_time)
	var color_b = get_gradient_color(current_color_time + 1.0)
	
	var radius = viewport_size.length() 
	var angle = deg_to_rad(current_gradient_angle)
	
	var tl = center + Vector2(-radius, -radius).rotated(angle)
	var tr = center + Vector2(radius, -radius).rotated(angle)
	var br = center + Vector2(radius, radius).rotated(angle)
	var bl = center + Vector2(-radius, radius).rotated(angle)
	
	var points = PackedVector2Array([tl, tr, br, bl])
	var colors = PackedColorArray([color_a, color_b, color_b, color_a])
	
	draw_polygon(points, colors)

func clear_board():
	for sprite in duplicated_spriteslist:
		sprite.queue_free()
	duplicated_spriteslist.clear()

# --- DRAW ONE STAR (Helper) ---
func draw_star_pattern(location: Vector2):
	var original_sprite = $Square
	
	# Define your scales here
	var main_scale = 0.4
	var half_scale = 0.2
	
	# This helper creates a sprite with a specific rotation AND scale
	var create_sprite = func(rot_angle_rad: float, sprite_scale: float):
		var s = original_sprite.duplicate()
		add_child(s)
		s.position = location
		s.rotation = rot_angle_rad
		s.scale = Vector2(sprite_scale, sprite_scale) # Set scale on the duplicate
		s.show()
		duplicated_spriteslist.append(s)

	# 1. Base (Static) - Draw BOTH sizes
	create_sprite.call(0.0, main_scale)
	create_sprite.call(0.0, half_scale)
	
	# 2. Stamps - Draw BOTH sizes
	for target_angle in stamp_angles:
		if overall_rotation >= target_angle:
			create_sprite.call(target_angle, main_scale)
			create_sprite.call(target_angle, half_scale)
		else:
			break
	
	# 3. Active Rotator - Draw BOTH sizes
	create_sprite.call(overall_rotation, main_scale)
	create_sprite.call(overall_rotation, half_scale)

# --- MAIN DRAW FUNCTION ---
func draw_board():
	var mouse_pos = get_local_mouse_position()
	var original_sprite = $Square
	
	if not original_sprite:
		return

	# --- CALCULATE GRID OFFSET TO CENTER ON MOUSE ---
	# Note: using CELL_SIZE * 2 as requested in your code for wider spacing
	var step = CELL_SIZE * 2.0
	var total_width = GRID_COLUMNS * step
	var total_height = GRID_ROWS * step
	
	var start_x = -(total_width / 2.0) + (step / 2.0)
	var start_y = -(total_height / 2.0) + (step / 2.0)

	# --- GRID LOOP ---
	for col in range(GRID_COLUMNS):
		for row in range(GRID_ROWS):
			
			var x_pos = start_x + (col * step)
			var y_pos = start_y + (row * step)
			
			var star_pos = mouse_pos + Vector2(x_pos, y_pos)
			
			draw_star_pattern(star_pos)

func _process(delta: float) -> void:
	overall_rotation += ROTATION_SPEED * delta
	
	current_color_time += GRADIENT_SPEED * delta
	current_gradient_angle += GRADIENT_ANGLE_SPEED * delta
	queue_redraw() 

	clear_board()
	draw_board()
