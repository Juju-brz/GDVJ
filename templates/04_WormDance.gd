extends Node2D
class_name WormDance

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
@export var SPIRAL_SPEED: float = 2.0

# --- BACKGROUND COLORS ---
@onready var backsquare = $ColorRect 
const COLOR_PALETTE: Array[Color] = [
	Color("050505"), # Nearly Black
	Color("1a000d"), # Deep Dark Red
	Color("001a1a")  # Deep Dark Teal
]

# --- SPRITE MANAGEMENT ---
var trail_sprites: Array[Sprite2D] = []
var trail_positions: Array[Vector2] = []
var trail_velocities: Array[Vector2] = []

# ---------------------------------------------------------
# VARIABLES: UI & CONTROLS
# ---------------------------------------------------------

@onready var control = $Control
@onready var BG = $BG_For_Controls
@onready var btn_change_image = $Control/VBoxContainer/Btn_Change_Image
@onready var dialogue_change_image = $Control/VBoxContainer/Dlg_Change_Image
@onready var original_sprite = $Square  
@onready var next_tpt = $Control/VBoxContainer/HBoxContainer/Btn_Switch_algorythme
const NEXT_SCENE_PATH = "res://templates/02_BeautifulChaos.tscn" 

var hide_ui :bool = false

#############################################################
# Quantique VARIABLES
#############################################################
var output: Array = []
var quantum_call_timer: float = 0.0

# --- FAST INTERVALS ---
const QUANTUM_CALL_INTERVAL: float = 0.5 
var lerp_time: float = 0.0
const LERP_DURATION: float = 0.5      

var lerp_a: float = 0.0 
var lerp_b: float = 0.0 
var lerp_c: float = 0.0 # Raw 0-16

var last_entangled_result: String = "N/A"

# --- THREAD VARIABLES ---
var quantum_thread: Thread = null
var thread_mutex: Mutex = Mutex.new()
var thread_data_ready: bool = false
var thread_output: Array = []

# ----------------------------------------------------------------------
# 1. Configuration 
# ----------------------------------------------------------------------
var base_dir: String = ""
var QUANTUM_EXE_PATH: String = ""

func _init():
	if OS.has_feature("editor"):
		base_dir = ProjectSettings.globalize_path("res://")
	else:
		base_dir = OS.get_executable_path().get_base_dir()
	
	QUANTUM_EXE_PATH = base_dir.path_join("QuantiqueTest.exe")
	
#############################################################

# ---------------------------------------------------------
# LIFECYCLE FUNCTIONS
# ---------------------------------------------------------

func _ready() -> void:
	lerp_c = lerp_a 
	quantum_call_timer = QUANTUM_CALL_INTERVAL 
	print("Quantum Executable Path configured as:", QUANTUM_EXE_PATH)
	
	# 1. HIDE THE FIXED ORIGINAL IMAGE
	if original_sprite:
		original_sprite.hide() 
	
	if backsquare: backsquare.show()
	
	# 2. SPAWN TRAIL AT CENTER OF SCREEN
	var viewport_center = get_viewport_rect().size / 2.0
	
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
	update_background(delta)
	
	# --- THREAD DATA HANDLING ---
	thread_mutex.lock()
	if thread_data_ready:
		var json_result = thread_output[0]
		var json_data = JSON.parse_string(json_result)
		if json_data != null and typeof(json_data) == TYPE_DICTIONARY:
			_handle_new_quantum_data(json_data) 
		else:
			print("JSON Error:", json_result)
		thread_data_ready = false
		thread_output.clear()
	thread_mutex.unlock()
	
	# --- LERP SMOOTHING ---
	if lerp_time < LERP_DURATION:
		lerp_time += delta
		var t = clamp(lerp_time / LERP_DURATION, 0.0, 1.0) 
		lerp_c = lerp(lerp_a, lerp_b, t)
		chaos_level = clamp(lerp_c / 16.0, 0.0, 1.0)

	# --- CALL TIMER ---
	quantum_call_timer += delta
	if quantum_call_timer >= QUANTUM_CALL_INTERVAL:
		if quantum_thread == null or not quantum_thread.is_started():
			get_quantum_random()
			quantum_call_timer = 0.0 
	
	# UPDATE VISUALS
	update_trail_physics(delta)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("hide_all_ctrl"):
		if hide_ui: control.show(); BG.show(); hide_ui = false
		else: control.hide(); BG.hide(); hide_ui = true
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()


# ---------------------------------------------------------
# VISUAL LOGIC: CENTERED MIRROR MOVEMENT
# ---------------------------------------------------------

func update_trail_physics(delta: float):
	var viewport_center = get_viewport_rect().size / 2.0
	var mouse_pos = get_global_mouse_position()
	
	# --- 1. CALCULATE OPPOSITE (MIRROR) POSITION ---
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
		
		# Glitch Color Overrides
		if chaos_level > 0.8 and randf() < 0.05 and i > 0:
			s.modulate = Color(1, 0, 0, 0.8)
		elif i > 0:
			# Reset color but keep alpha calculated above
			s.modulate = Color(1, 1, 1, s.modulate.a)


func update_background(delta: float):
	if !backsquare: return
	var target_col = COLOR_PALETTE[0]
	if chaos_level > 0.6:
		target_col = COLOR_PALETTE[1] 
	backsquare.color = backsquare.color.lerp(target_col, delta * 2.0)


# ---------------------------------------------------------
# IMAGE LOGIC
# ---------------------------------------------------------

func open_dialog(): dialogue_change_image.popup_centered()

func _on_file_selected(path: String):
	var image = Image.new()
	if image.load(path) != OK: return
	var new_tex = ImageTexture.create_from_image(image)
	if original_sprite: original_sprite.texture = new_tex
	for s in trail_sprites:
		s.texture = new_tex
	_close_all_ui()

func _close_all_ui():
	control.hide(); BG.hide(); dialogue_change_image.hide(); hide_ui = true


# ---------------------------------------------------------
# QUANTUM LOGIC
# ---------------------------------------------------------

func _run_quantum_in_thread(): 
	var executable_path = QUANTUM_EXE_PATH
	var output_buffer: Array = []
	
	if not FileAccess.file_exists(executable_path):
		thread_mutex.lock()
		thread_output = ["FATAL ERROR: Quantum Executable not found at: " + executable_path]
		thread_data_ready = true
		thread_mutex.unlock()
		return 
	
	var exit_code = OS.execute(executable_path, [], output_buffer, true)
	
	thread_mutex.lock()
	if exit_code == 0 and output_buffer.size() > 0:
		thread_output = output_buffer
		thread_data_ready = true
	else:
		var error_msg = "QUANTUM EXECUTION FAILED.\n"
		if output_buffer.size() > 0: error_msg += "Output: " + output_buffer[0]
		thread_output = [error_msg]
		thread_data_ready = true
	thread_mutex.unlock()

func get_quantum_random():
	if quantum_thread != null and quantum_thread.is_started(): return
	quantum_thread = Thread.new()
	quantum_thread.start(self._run_quantum_in_thread)

func _convert_quantum_result_to_float(result_string: String) -> float:
	return float(int(result_string))

func _handle_new_quantum_data(data: Dictionary):
	last_entangled_result = str(data.get("entangled_result", "0"))
	var new_target = _convert_quantum_result_to_float(last_entangled_result)

	lerp_a = lerp_c 
	lerp_b = new_target
	lerp_time = 0.0

	print("--- Bio-Spiral Update ---")
	print("Raw Lerp Target: ", lerp_b)

func _on_next_tpt_pressed() -> void:
	if quantum_thread != null and quantum_thread.is_started():
		quantum_thread.wait_to_finish() 
		quantum_thread = null
	var error = get_tree().change_scene_to_file(NEXT_SCENE_PATH)
	if error != OK: print("SCENE ERROR: ", error)
