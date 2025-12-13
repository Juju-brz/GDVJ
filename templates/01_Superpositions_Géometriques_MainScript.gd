extends Node2D
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
@export var GROUP_ROTATION_SPEED: float = deg_to_rad(5.0) # <--- SLOWER (Was 20.0)

var stamp_angles: Array[float] = []

# --- BACKGROUND GRADIENT ---
@onready var backsquare = $ColorRect 
const COLOR_PALETTE: Array[Color] = [
	Color("000033"), # Dark Blue
	Color("330033"), # Dark Magenta
	Color("003333"), # Dark Cyan
	Color("000000")  # Black
]
var current_color_time: float = 0.0
var current_gradient_angle: float = 0.0
@export var GRADIENT_SPEED: float = 0.1
@export var GRADIENT_ANGLE_SPEED: float = 10.0

# --- RANDOMNESS ---
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

@onready var control = $Control
@onready var BG = $BG_For_Controls
@onready var btn_change_image = $Control/VBoxContainer/Btn_Change_Image
@onready var dialogue_change_image = $Control/VBoxContainer/Dlg_Change_Image
@onready var original_sprite = $Square  

var hide_ui :bool = false


# ---------------------------------------------------------
# LIFECYCLE FUNCTIONS
# ---------------------------------------------------------

func _ready() -> void:
	# 1. SETUP VISUALS
	original_sprite.hide()
	if backsquare:
		backsquare.hide()
	
	# Generate Stamps
	var current_angle = 45.0
	var add_small_step = true 
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

	print("!!! SCRIPT READY: Slower + Random Directions !!!")


func _process(delta: float) -> void:
	# 1. Update Timers
	time_passed += delta * JITTER_SPEED  
	
	process_random_cycle(delta)
	
	# Rotate the "Duplicator"
	overall_rotation += ROTATION_SPEED * delta 
	
	# Rotate the "Whole Group"
	group_rotation += GROUP_ROTATION_SPEED * delta
	
	# Background
	current_color_time += GRADIENT_SPEED * delta
	current_gradient_angle += GRADIENT_ANGLE_SPEED * delta
	
	queue_redraw() 

	# 2. Rebuild the Grid (Visual Loop)
	clear_board()
	draw_board()


func _input(event: InputEvent) -> void:
	# Toggle UI
	if Input.is_action_just_pressed("hide_all_ctrl"):
		if hide_ui:
			control.show(); BG.show(); hide_ui = false
		else:
			control.hide(); BG.hide(); hide_ui = true
			
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()


# ---------------------------------------------------------
# VISUAL LOGIC
# ---------------------------------------------------------

func clear_board():
	for sprite in duplicated_spriteslist:
		sprite.queue_free()
	duplicated_spriteslist.clear()

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
	var viewport_rect = get_viewport_rect()
	var mouse_pos = get_viewport().get_mouse_position()
	
	var norm_x = clamp(mouse_pos.x / viewport_rect.size.x, 0.0, 1.0)
	var norm_y = clamp(mouse_pos.y / viewport_rect.size.y, 0.0, 1.0)
	
	var current_scale_outer = lerp(0.2, 0.8, norm_x) 
	var current_scale_inner = lerp(0.1, 0.4, norm_y)
	var current_scale_ghost = lerp(0.0, 0.15, norm_y)

	# 2. Grid Calculations
	var screen_center = viewport_rect.size / 2.0
	var step = CELL_SIZE * 2.0
	var total_width = GRID_COLUMNS * step
	var total_height = GRID_ROWS * step
	
	var start_x = -(total_width / 2.0) + (step / 2.0)
	var start_y = -(total_height / 2.0) + (step / 2.0)

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
			# Use the same seeds to decide Left (-1) or Right (1)
			# Modulo 2 gives us 0 or 1.
			var dir_seed = (col * 7 + row * 3) % 2 
			var rot_direction = 1.0
			if dir_seed == 0:
				rot_direction = -1.0
			
			# Draw the star stack passing the direction
			draw_star_pattern(star_pos, active_stamps, current_scale_outer, current_scale_inner, current_scale_ghost, rot_direction)


func draw_star_pattern(location: Vector2, active_stamps_list: Array[float], scale_outer: float, scale_inner: float, scale_ghost: float, rot_dir: float):
	
	# Helper to create sprite
	# NOTE: We multiply group_rotation by 'rot_dir' (+1 or -1)
	var create_sprite = func(rot_angle_rad: float, sprite_scale: float):
		if sprite_scale <= 0.01: return
		var s = original_sprite.duplicate()
		add_child(s)
		s.position = location
		
		# --- APPLY RANDOM GROUP ROTATION HERE ---
		# rot_angle_rad is the internal spinning (duplication)
		# group_rotation * rot_dir is the slow group spinning (left or right)
		s.rotation = rot_angle_rad + (group_rotation * rot_dir)
		
		s.scale = Vector2(sprite_scale, sprite_scale)
		s.visible = true 
		s.show()
		duplicated_spriteslist.append(s)

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


# ---------------------------------------------------------
# IMAGE CHANGING LOGIC
# ---------------------------------------------------------

func open_dialog():
	dialogue_change_image.popup_centered()

func _on_file_selected(path: String):
	var image = Image.new()
	if image.load(path) != OK: return
	var new_tex = ImageTexture.create_from_image(image)
	
	if original_sprite:
		original_sprite.texture = new_tex
	
	_close_all_ui()

func _close_all_ui():
	control.hide(); BG.hide(); dialogue_change_image.hide(); hide_ui = true


# ---------------------------------------------------------
# HELPERS
# ---------------------------------------------------------

func process_random_cycle(delta: float):
	cycle_timer += delta
	if cycle_timer >= CYCLE_INTERVAL:
		cycle_timer = 0.0
		rand_val_a = rand_val_b
		rand_val_b = randf()
	var t = cycle_timer / CYCLE_INTERVAL
	smooth_random_value = lerp(rand_val_a, rand_val_b, t)

func get_gradient_color(time_val: float) -> Color:
	var size = COLOR_PALETTE.size()
	var idx = int(time_val) % size
	var next_idx = (idx + 1) % size
	var t = time_val - float(int(time_val))
	return COLOR_PALETTE[idx].lerp(COLOR_PALETTE[next_idx], t)

func _draw():
	var viewport_size = Vector2(1000, 1000)
	if backsquare: viewport_size = backsquare.size
	var center = viewport_size / 2.0
	
	var color_a = get_gradient_color(current_color_time)
	var color_b = get_gradient_color(current_color_time + 1.0)
	var radius = viewport_size.length() 
	var angle = deg_to_rad(current_gradient_angle)
	
	var tl = center + Vector2(-radius, -radius).rotated(angle)
	var tr = center + Vector2(radius, -radius).rotated(angle)
	var br = center + Vector2(radius, radius).rotated(angle)
	var bl = center + Vector2(-radius, radius).rotated(angle)
	
	draw_polygon(PackedVector2Array([tl, tr, br, bl]), PackedColorArray([color_a, color_b, color_b, color_a]))
