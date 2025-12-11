extends Node2D

#### VARIABLES ####

# --- GRID VARIABLES ---
@export var GRID_COLUMNS: int = 10    
@export var GRID_ROWS: int = 5        
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

# --- DRAW ONE STAR (Helper with Dynamic Scaling) ---
# Now accepts two specific scales: one for the outer squares, one for the inner
func draw_star_pattern(location: Vector2, scale_outer: float, scale_inner: float):
	var original_sprite = $Square
	
	# Helper creates a sprite with a specific scale
	var create_sprite = func(rot_angle_rad: float, sprite_scale: float):
		var s = original_sprite.duplicate()
		add_child(s)
		s.position = location
		s.rotation = rot_angle_rad
		s.scale = Vector2(sprite_scale, sprite_scale)
		s.show()
		duplicated_spriteslist.append(s)

	# 1. Base (Static) - Draw BOTH
	create_sprite.call(0.0, scale_outer)
	create_sprite.call(0.0, scale_inner)
	
	# 2. Stamps - Draw BOTH
	for target_angle in stamp_angles:
		if overall_rotation >= target_angle:
			create_sprite.call(target_angle, scale_outer)
			create_sprite.call(target_angle, scale_inner)
		else:
			break
	
	# 3. Active Rotator - Draw BOTH
	create_sprite.call(overall_rotation, scale_outer)
	create_sprite.call(overall_rotation, scale_inner)

# --- MAIN DRAW FUNCTION ---
func draw_board():
	var original_sprite = $Square
	if not original_sprite:
		return

	# --- 1. CALCULATE INTERACTIVE SCALES ---
	var viewport_rect = get_viewport_rect()
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Normalize mouse position (0.0 to 1.0) across the screen
	var norm_x = clamp(mouse_pos.x / viewport_rect.size.x, 0.0, 1.0)
	var norm_y = clamp(mouse_pos.y / viewport_rect.size.y, 0.0, 1.0)
	
	# HORIZONTAL (Outer Square): Base 0.4 -> Range [0.2, 0.8]
	var current_scale_outer = lerp(0.2, 0.8, norm_x)
	
	# VERTICAL (Inner Square): Base 0.2 -> Range [0.1, 0.4]
	# (Up/0 is smaller, Down/1 is bigger)
	var current_scale_inner = lerp(0.1, 0.4, norm_y)

	# --- 2. CENTER THE GRID (Static Position) ---
	var screen_center = viewport_rect.size / 2.0
	
	# Note: using CELL_SIZE * 2 as requested in previous code
	var step = CELL_SIZE * 2.0
	var total_width = GRID_COLUMNS * step
	var total_height = GRID_ROWS * step
	
	# Calculate top-left corner relative to screen center
	var start_x = -(total_width / 2.0) + (step / 2.0)
	var start_y = -(total_height / 2.0) + (step / 2.0)

	# --- 3. GRID LOOP ---
	for col in range(GRID_COLUMNS):
		for row in range(GRID_ROWS):
			
			var x_pos = start_x + (col * step)
			var y_pos = start_y + (row * step)
			
			# Position is now relative to screen center, not mouse
			var star_pos = screen_center + Vector2(x_pos, y_pos)
			
			draw_star_pattern(star_pos, current_scale_outer, current_scale_inner)

func _process(delta: float) -> void:
	overall_rotation += ROTATION_SPEED * delta
	
	current_color_time += GRADIENT_SPEED * delta
	current_gradient_angle += GRADIENT_ANGLE_SPEED * delta
	queue_redraw() 

	clear_board()
	draw_board()
