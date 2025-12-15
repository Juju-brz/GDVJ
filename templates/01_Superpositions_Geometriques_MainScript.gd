extends mainScript
class_name StarGridRandomRotate

# ---------------------------------------------------------
# VARIABLES: VISUAL SETTINGS
# ---------------------------------------------------------

# --- GRID SETTINGS ---
@export var GRID_COLUMNS: int = 10 
@export var GRID_ROWS: int = 9 
@export var CELL_SIZE: float = 100.0 

# --- RANDOM MOVEMENT SETTINGS ---
var time_passed: float = 0.0
@export var JITTER_SPEED: float = 1.5      
@export var JITTER_HEIGHT: float = 20.0    

# --- ROTATION SETTINGS ---
var overall_rotation: float = 0.0      # Rotates the "Active" sprite
var group_rotation: float = 0.0        # Rotates the WHOLE GROUP
@export var ROTATION_SPEED: float = deg_to_rad(10.0)
@export var GROUP_ROTATION_SPEED: float = deg_to_rad(5.0) 

var stamp_angles: Array[float] = []

# --- BACKGROUND GRADIENT ---
@onready var backsquare = $ColorRect 

var current_color_time: float = 0.0
var current_gradient_angle: float = 0.0
@export var GRADIENT_SPEED: float = 0.1
@export var GRADIENT_ANGLE_SPEED: float = 10.0

# --- RANDOMNESS (Not quantum related, existing logic) ---
var cycle_timer: float = 0.0
const CYCLE_INTERVAL: float = 10.0 
var rand_val_a: float = 0.0
var rand_val_b: float = 0.0
var smooth_random_value: float = 0.0 

# --- SPRITE MANAGEMENT ---
var duplicated_spriteslist: Array = []

# ---------------------------------------------------------
# VARIABLES: UI & CONTROLS
# ---------------------------------------------------------


var output: Array = []

# Timer for calling the Python script
var quantum_call_timer: float = 0.0
const QUANTUM_CALL_INTERVAL: float = 3.0 

# Timer for the smooth interpolation (5 seconds)
var lerp_time: float = 0.0
const LERP_DURATION: float = 5.0      # Time taken for the smooth transition

# --- LERP STATE VARIABLES ---
#var lerp_a: float = 0.0 
#var lerp_b: float = 0.0 
#var lerp_c: float = 0.0 

# Global variables to store the last result (for debugging)
var last_entangled_result: String = "N/A"
var last_qubit_count: int = 0
var last_quantum_state: String = "Idle"

# --- THREAD VARIABLES (NON-BLOCKING EXECUTION) ---
#var quantum_thread: Thread = null
#var thread_mutex: Mutex = Mutex.new()
#var thread_data_ready: bool = false
#var thread_output: Array = []

# ----------------------------------------------------------------------
# 1. Configuration 
# ----------------------------------------------------------------------
var base_dir: String = ""



# --- ROTATION STOP VARIABLES (Element-based) ---
const TOTAL_CELLS : int= 90 # 10 columns * 9 rows
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

# ---------------------------------------------------------
# LIFECYCLE FUNCTIONS
# ---------------------------------------------------------

func _ready() -> void:
	NEXT_SCENE_PATH = "res://templates/04_WormDance.tscn" 

	# Initialize element-based rotation arrays
	cell_rotation_timer.resize(TOTAL_CELLS)
	cell_rotation_timer.fill(RESTART_DURATION) # Initialize as fully restarted
	
	cell_rotation_target.resize(TOTAL_CELLS)
	cell_rotation_target.fill(1.0) # Target is 1.0 (full speed)
	
	# 1. SETUP VISUALS
	original_sprite.hide()
	if backsquare:
		backsquare.hide()
	
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

	rand_val_a = randf()
	rand_val_b = randf()

	# 2. SETUP UI
	control.hide()
	BG.hide()
	dialogue_change_image.hide()
	hide_ui = true
	
	# 3. CONNECT SIGNALS
	if not btn_change_image.pressed.is_connected(open_dialog):
		btn_change_image.pressed.connect(open_dialog)
	
	if not dialogue_change_image.file_selected.is_connected(_on_file_selected):
		dialogue_change_image.file_selected.connect(_on_file_selected)
	
	if not dialogue_change_image.canceled.is_connected(_close_all_ui):
		dialogue_change_image.canceled.connect(_close_all_ui)
		
	if not next_tpt.pressed.is_connected(_on_next_tpt_pressed):
		next_tpt.pressed.connect(_on_next_tpt_pressed)
		


func _process(delta: float) -> void:
	# 1. Update Timers
	time_passed += delta * JITTER_SPEED  
	
	
	# Rotation and Background updates
	overall_rotation += ROTATION_SPEED * delta
	group_rotation += GROUP_ROTATION_SPEED * delta
	current_color_time += GRADIENT_SPEED * delta
	current_gradient_angle += GRADIENT_ANGLE_SPEED * delta
	
	queue_redraw()
	clear_board()
	if mouse_activation == true:
		draw_board()



func clear_board():
	for sprite in duplicated_spriteslist:
		sprite.queue_free()
	duplicated_spriteslist.clear()


func mouse_control():
	var viewport_rect = get_viewport_rect()
	#var mouse_pos = get_viewport().get_mouse_position()
	
	var norm_x = clamp(getmouse().x / viewport_rect.size.x, 0.0, 1.0)
	var norm_y = clamp(getmouse().y / viewport_rect.size.y, 0.0, 1.0)
	return Vector2(norm_x, norm_y)

func draw_board():
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
	
	# --------------------------------------------------

	# 1. Interactive Scales (Mouse)
	#var viewport_rect = get_viewport_rect()
	##var mouse_pos = get_viewport().get_mouse_position()
	var mouse_norm = mouse_control() # .x & .y
	#var norm_x = clamp(getmouse().x / viewport_rect.size.x, 0.0, 1.0)
	#var norm_y = clamp(getmouse().y / viewport_rect.size.y, 0.0, 1.0)
	
	var current_scale_outer = lerp(0.2, 0.8, mouse_norm.x) 
	var current_scale_inner = lerp(0.1, 0.4, mouse_norm.y)
	var current_scale_ghost = lerp(0.0, 0.15, mouse_norm.y)

	# 2. Grid Calculations
	var screen_center = get_viewport_rect().size * 0.5
	var step = CELL_SIZE * 2.0
	var total_width = GRID_COLUMNS * step
	var total_height = GRID_ROWS * step
	
	var start_x = -(total_width * 0.5) + (step * 0.5)
	var start_y = -(total_height * 0.5) + (step * 0.5)

	# 3. Loop with 30% CHANCE LOGIC
	for col in range(GRID_COLUMNS):
		for row in range(GRID_ROWS):
			
			var x_pos = start_x + (col * step)
			var base_y = start_y + (row * step)
			
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
			var cell_index = (row * GRID_COLUMNS) + col
			
			# Draw the star stack passing the unique cell index
			draw_star_pattern(star_pos, active_stamps, current_scale_outer, current_scale_inner, current_scale_ghost, rot_direction, cell_index)


func draw_star_pattern(location: Vector2, active_stamps_list: Array[float], scale_outer: float, scale_inner: float, scale_ghost: float, rot_dir: float, cell_index: int):
	
	# ------------------ ANIMATED ROTATION LOOKUP ------------------
	var current_rotation_speed = 1.0 # Default (full speed)
	
	if cell_index < TOTAL_CELLS:
		var target = cell_rotation_target[cell_index]
		var current_time = cell_rotation_timer[cell_index]
		
		if target == 0.0: # STOPPING PHASE (1.0 speed -> 0.0 speed, Ease Out)
			var t = clamp(current_time / STOP_DURATION, 0.0, 1.0)
			var ease_t = 1.0 - pow(1.0 - t, 3) # Cubic Ease Out
			current_rotation_speed = lerp(1.0, target, ease_t)
			
		elif target == 1.0: # RESTARTING PHASE (0.0 speed -> 1.0 speed, Ease In)
			var t = clamp(current_time / RESTART_DURATION, 0.0, 1.0)
			var ease_t = pow(t, 3) # Cubic Ease In
			current_rotation_speed = lerp(0.0, target, ease_t)
			
	# The final speed multiplier for this cell's rotation
	var final_rotation_multiplier = current_rotation_speed 

	# Helper to create sprite
	var create_sprite = func(rot_angle_rad: float, sprite_scale: float):
		if sprite_scale <= 0.01: return
		var s = original_sprite.duplicate()
		add_child(s)
		s.position = location
		
		# APPLY ROTATION SPEED MULTIPLIER HERE
		# We multiply the group rotation by the cell's speed multiplier
		s.rotation = rot_angle_rad + (group_rotation * rot_dir * final_rotation_multiplier)
		
		s.scale = Vector2(sprite_scale, sprite_scale)
		s.visible = true 
		s.modulate.a = 1.0
		s.show()
		duplicated_spriteslist.append(s)
	# --------------------------------------------------------

	# 1. Base Layers
	create_sprite.call(0.0, scale_outer)
	create_sprite.call(0.0, scale_inner)
	create_sprite.call(0.0, scale_ghost) 
	
	# 2. Stamps (Trails relative to group)
	for target_angle in active_stamps_list:
		create_sprite.call(target_angle, scale_outer)
		create_sprite.call(target_angle, scale_inner)
		create_sprite.call(target_angle, scale_ghost) 
	
	# 3. Active Rotator (Moving relative to group)
	create_sprite.call(overall_rotation, scale_outer)
	create_sprite.call(overall_rotation, scale_inner)
	create_sprite.call(overall_rotation, scale_ghost)



func update_rotation_state():
	
	# 1. Count how many cells are currently animating (stopping or restarting)
	var currently_animating = 0
	for i in range(TOTAL_CELLS):
		# A cell is animating if it's currently stopping (target 0.0) 
		# OR if it's restarting (target 1.0 but hasn't finished the RESTART_DURATION time yet)
		if cell_rotation_target[i] == 0.0 or cell_rotation_timer[i] < RESTART_DURATION:
			currently_animating += 1

	# 2. If the current animation count is below the quantum-driven target count, 
	#    find a random idle cell and start its stop rotation animation.
	if currently_animating < target_active_count:
		
		# Find all cells that are currently idle (target 1.0 AND finished restarting)
		var idle_indices = []
		for i in range(TOTAL_CELLS):
			if cell_rotation_target[i] == 1.0 and cell_rotation_timer[i] >= RESTART_DURATION:
				idle_indices.append(i)
		
		# If there are idle cells, randomly select one to stop
		if idle_indices.size() > 0:
			var cell_index = idle_indices.pick_random()
			cell_rotation_target[cell_index] = 0.0 # Stop target
			cell_rotation_timer[cell_index] = 0.0 # Start timer for STOP_DURATION
