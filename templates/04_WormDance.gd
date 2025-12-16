extends mainScript

# ---------------------------------------------------------
# VARIABLES: VISUAL SETTINGS
# ---------------------------------------------------------

# --- TRAIL SETTINGS ---
const TRAIL_LENGTH: int = 60 
var target_segment_dist: float = 15.0 

# --- QUANTUM INFLUENCE VARIABLES ---
var chaos_level: float = 0.0 

# --- ROTATION & TIME ---
var time_passed: float = 0.0
var SPIRAL_SPEED: float = 2.0

# --- BACKGROUND COLORS ---
@onready var backsquare = $ColorRect 


# --- SPRITE MANAGEMENT ---
var trail_sprites: Array[Sprite2D] = []
var trail_positions: Array[Vector2] = []
var trail_velocities: Array[Vector2] = []

# ---------------------------------------------------------
# VARIABLES: UI & CONTROLS
# ---------------------------------------------------------


func _ready() -> void:
	##print("Quantum Executable Path configured as:", QUANTUM_EXE_PATH)
	NEXT_SCENE_PATH = "res://templates/02_BeautifulChaos.tscn" 
	# 1. HIDE THE FIXED ORIGINAL IMAGE
	if original_sprite:
		original_sprite.hide() 
	
	if backsquare: backsquare.show()
	
	# 2. SPAWN TRAIL AT CENTER OF SCREEN
	var viewport_center = get_viewport_rect().size * 0.5
	
	for i in range(TRAIL_LENGTH):
		var s = original_sprite.duplicate()
		add_child(s)
		s.visible = true 
		s.position = viewport_center 
		trail_sprites.append(s)
		trail_positions.append(viewport_center)
		trail_velocities.append(Vector2.ZERO)
	
	# UI Setup
	control.hide()
	BG.hide()
	hide_ui = true
	
	# Signals
	if not btn_change_image.pressed.is_connected(open_dialog):
		btn_change_image.pressed.connect(open_dialog)
	if not dialogue_change_image.file_selected.is_connected(_on_file_selected):
		dialogue_change_image.file_selected.connect(_on_file_selected)
	if not dialogue_change_image.canceled.is_connected(_close_all_ui):
		dialogue_change_image.canceled.connect(_close_all_ui)
	if not next_tpt.pressed.is_connected(_on_next_tpt_pressed):
		next_tpt.pressed.connect(_on_next_tpt_pressed)
		
	print("!!! SCRIPT READY: Center Spawn + Mirror Movement + Invisible Head !!!")


func _process(delta: float) -> void:
	time_passed += delta
	
	update_trail_physics(delta)


func update_trail_physics(delta: float):
	var viewport_center = get_viewport_rect().size * 0.5  
	#var mouse_pos = get_global_mouse_position()
	
	##Off or On##
	var mouse_pos
	if mouse_activation == true:
		mouse_pos = get_mouse() # .x & .y
	if mouse_activation == false:
		mouse_pos = joystick_control(delta) * viewport_center * 2.0
	
	
	var offset_from_center = mouse_pos - viewport_center
	var mirror_target = viewport_center - offset_from_center
	
	# --- 2. UPDATE HEAD ---
	var head_lag = lerp(0.1, 0.02, chaos_level) 
	trail_positions[0] = trail_positions[0].lerp(mirror_target, head_lag)
	
	# --- 3. UPDATE BODY ---
	for i in range(0, TRAIL_LENGTH): # Iterate from 0 to handle the head too!
		
		# Move body segments (indices 1+)
		if i > 0:
			var target = trail_positions[i - 1]
			var current = trail_positions[i]
			var dist = current.distance_to(target)
			var move_speed = lerp(10.0, 60.0, chaos_level) * delta
			
			if dist > target_segment_dist:
				trail_positions[i] = current.lerp(target, move_speed * 0.5)
			
		# UPDATE SPRITE
		var s = trail_sprites[i]
		s.position = trail_positions[i]
		
		# Rotation Logic
		var spiral_rot = (float(i) * 0.1) + (time_passed * SPIRAL_SPEED)
		var glitch_rot = 0.0
		if chaos_level > 0.5 and randf() < 0.1:
			glitch_rot = deg_to_rad(90.0 * (randi() % 4))
		
		s.rotation = spiral_rot + glitch_rot
		
		# Scale Logic
		var pulse = sin(time_passed * 3.0 + (i * 0.2))
		var chaos_scale = 1.0
		if chaos_level > 0.3:
			chaos_scale = lerp(1.0, randf_range(0.5, 2.5), chaos_level * 0.5)
			
		var base_scale = lerp(0.8, 0.2, float(i)/float(TRAIL_LENGTH))
		var final_scale = base_scale * (1.0 + (pulse * 0.2)) * chaos_scale
		
		s.scale = Vector2(final_scale, final_scale)
		
		# --- ALPHA LOGIC (The Fix) ---
		if i == 0:
			# Hide the head completely!
			s.modulate.a = 0.0 
		else:
			# Fade out tail normally
			s.modulate.a = lerp(1.0, 0.0, float(i)/float(TRAIL_LENGTH))


func _on_file_selected(path: String):
	var image = Image.new()
	if image.load(path) != OK: return
	var new_tex = ImageTexture.create_from_image(image)
	if original_sprite: original_sprite.texture = new_tex
	for s in trail_sprites:
		s.texture = new_tex
	_close_all_ui()
