extends mainScript


# --- GRID SETTINGS ---
var GRID_COLUMNS: int = 10 
var GRID_ROWS: int = 9 
var CELL_SIZE: float = 100.0 

# --- RANDOM MOVEMENT SETTINGS ---
var time_passed: float = 0.0
var JITTER_SPEED: float = 1.5      
var JITTER_HEIGHT: float = 20.0    

# --- ROTATION SETTINGS ---
var overall_rotation: float = 0.0      # Rotates the "Active" sprite
var group_rotation: float = 0.0        # Rotates the WHOLE GROUP
var ROTATION_SPEED: float = deg_to_rad(10.0)
var GROUP_ROTATION_SPEED: float = deg_to_rad(5.0) 

var stamp_angles: Array[float] = []

var current_gradient_angle: float = 0.0
var GRADIENT_SPEED: float = 0.1
var GRADIENT_ANGLE_SPEED: float = 10.0


var output: Array = []


# --- ROTATION STOP VARIABLES (Element-based) ---
const TOTAL_CELLS : int = 90 # 10 columns * 9 rows
# Max time to stop rotation (1.0 speed -> 0.0 speed, Ease Out)
const STOP_DURATION: float = 0.4 
# Max time to restart rotation (0.0 speed -> 1.0 speed, Ease In)
const RESTART_DURATION: float = 3.0

# Tracks the current animation progress/state for all 90 cells.
var cell_rotation_timer: Array[float] = [] 
# Tracks the final rotation target (0.0=stop, 1.0=start)
var cell_rotation_target: Array[float] = [] 
# Tracks the current number of active cells to avoid repeated activation
var target_active_count: int = 0


#### FUNCTIONS ####

func _ready() -> void:
	super._ready()
	NEXT_SCENE_PATH = "res://templates/04_WormDance.tscn" 

	# Initialize element-based rotation arrays
	cell_rotation_timer.resize(TOTAL_CELLS)
	cell_rotation_timer.fill(RESTART_DURATION) # Initialize as fully restarted
	
	cell_rotation_target.resize(TOTAL_CELLS)
	cell_rotation_target.fill(1.0) # Target is 1.0 (full speed)
	
	# 1. SETUP VISUALS
	original_sprite.hide()

	# Generate Stamps
	var current_angle : float = 45.0
	var add_small_step : bool = true 
	while current_angle < 3600.0:
		stamp_angles.append(deg_to_rad(current_angle))
		if add_small_step:
			current_angle += 22.5
		else:
			current_angle += 45.0
		add_small_step = not add_small_step


func _process(delta: float) -> void:
	super._process(delta)
	# 1. Update Timers
	time_passed += delta * JITTER_SPEED  
	
	
	# Rotation and Background updates
	overall_rotation += ROTATION_SPEED * delta
	group_rotation += GROUP_ROTATION_SPEED * delta * speed
	#current_color_time += GRADIENT_SPEED * delta
	current_gradient_angle += GRADIENT_ANGLE_SPEED * delta
	#print(time_passed)
	#if  time_passed > 6.0:
		#pass
	#else:
	queue_redraw()
	clear_board()
	draw_board(delta)



func clear_board():
	for sprite in duplicated_spriteslist:
		sprite.queue_free()
	duplicated_spriteslist.clear()

func draw_board(delta):
	if not original_sprite: return
	# --- OPTIMIZATION: CALCULATE ACTIVE STAMPS ONCE ---
	var active_stamps: Array[float] = []
	var passed_count = 0
	for angle in stamp_angles:
		if overall_rotation >= angle:
			passed_count += 1
		else:
			break
	
	# Get last 8 stamps only
	var start_index = max(0, passed_count - 8)
	for i in range(start_index, passed_count):
		active_stamps.append(stamp_angles[i])
	
	
	var current_scale_outer = lerp(0.2, 0.8, control_norm(delta).x) 
	var current_scale_inner = lerp(0.1, 0.4, control_norm(delta).y)
	var current_scale_ghost = lerp(0.0, 0.15, control_norm(delta).y)

	# 2. Grid Calculations
	var screen_center = get_viewport_rect().size * 0.5
	var step = CELL_SIZE * 2.0
	var total_width = GRID_COLUMNS * step
	var total_height = GRID_ROWS * step
	
	var start_x = -(total_width * 0.5) + (step * 0.5)
	var start_y = -(total_height * 0.5) + (step * 0.5)
	#var  max_loop = 100
	#if time_passed >= 3.0:
		#clear_board()
		#time_passed = 0.0
		#pass
	#else: 
	var current_rotation_speed = 1.0
	loop(start_x, start_y, step, screen_center, current_scale_outer, current_scale_inner, current_scale_ghost,current_rotation_speed)

	var current_rotation_speed1 = 4.0
	loop(start_x, start_y, step, screen_center, current_scale_outer, current_scale_inner, current_scale_ghost,current_rotation_speed1)
func loop(start_x, start_y, step, screen_center, current_scale_outer, current_scale_inner, current_scale_ghost, current_rotation_speed):
	#var loop_count = 0
	for col in range(GRID_COLUMNS):
		for row in range(GRID_ROWS):
			#if max_loop != null and loop_count >= max_loop:
				#return
				
			var x_pos = start_x + (col * step)
			var base_y = start_y + (row * step)
			#print(loop_count)
			# Deterministic Random Jitter
			var random_seed = (col * 11 + row * 17) % 100
			var y_offset = 0.0
			
			if random_seed < 30:
				y_offset = sin(time_passed + random_seed) * JITTER_HEIGHT
			else:
				y_offset = 0.0
			
			var y_pos = base_y + y_offset
			var star_pos = screen_center + Vector2(x_pos, y_pos)
			
			# --- NEW: RANDOM ROTATION DIRECTION ---
			var dir_seed = (col * 7 + row * 3) % 2 
			var rot_direction = 1.0
			if dir_seed == 0:
				rot_direction = -1.0
			
			# --- CALCULATE UNIQUE CELL INDEX ---
			#var cell_index = (row * GRID_COLUMNS) + col
			
			# Draw the star stack passing the unique cell index
			draw_star_pattern(star_pos, current_scale_outer, current_scale_inner, current_scale_ghost, rot_direction, current_rotation_speed)
			#loop_count += 1
			#print(loop_count)

func draw_star_pattern(location: Vector2, scale_outer: float, scale_inner: float, scale_ghost: float, rot_dir: float, current_rotation_speed):
	# ------------------ ANIMATED ROTATION LOOKUP ------------------
	#var current_rotation_speed = 1.0 # Default (full speed)

			
	# The final speed multiplier for this cell's rotation
	var final_rotation_multiplier = current_rotation_speed 

	# Helper to create sprite
	var create_sprite = func(rot_angle_rad: float, sprite_scale: float):
		if sprite_scale <= 0.01: return
		var s = original_sprite.duplicate()
		add_child(s)
		s.position = location
		
		s.rotation = rot_angle_rad + (group_rotation * rot_dir * final_rotation_multiplier)
		
		s.scale = Vector2(sprite_scale, sprite_scale)
		s.visible = true 
		s.modulate.a = 1.0
		s.show()
		duplicated_spriteslist.append(s)

	# 1. Base Layers
	create_sprite.call(0.0, scale_outer)
	create_sprite.call(0.0, scale_inner)
	create_sprite.call(0.0, scale_ghost) 
	
