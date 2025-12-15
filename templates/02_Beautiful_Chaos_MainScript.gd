extends mainScript
class_name BeautifulChaos

#### VARIABLES ####

# --- WAVE & GRID SETTINGS ---
var SPACING: float = 60.0 
var GRID_COLUMNS: int = 15 
var time_passed: float = 0.0 
var speed: float = 5.0 

# --- MOUSE INTERACTION SETTINGS ---
var overall_rotation: float = 0.0
var ROTATION_SPEED: float = deg_to_rad(10.0)

# --- DATA ARRAYS ---
var array_points: Array[Vector2] = []


#const NEXT_SCENE_PATH = "res://templates/03-Spiral.tscn" # <-- CHANGE THIS PATH!
# Trackers

var duplicated_spriteslist = []
@onready var old_slider_val_int: int = int(slider.value)
@onready var old_slider_spacing_val: float = slider_spacing.value

# --- BACKGROUND GRADIENT VARIABLES ---
@onready var backsquare = $ColorRect 


var current_color_time: float = 0.0
var current_gradient_angle: float = 0.0
var GRADIENT_SPEED: float = 0.1
var GRADIENT_ANGLE_SPEED: float = 10.0


#### LIFECYCLE ####

func _ready() -> void:
	print("--- SCRIPT STARTED ---")
	NEXT_SCENE_PATH = "res://templates/03-Spiral.tscn"
	# 1. SAFETY: Create a placeholder texture if missing
	# This ensures you see SOMETHING even if the sprite is empty
	if original_sprite.texture == null:
		print("No texture found! Creating placeholder.")
		var placeholder = PlaceholderTexture2D.new()
		placeholder.size = Vector2(64, 64)
		original_sprite.texture = placeholder
		original_sprite.modulate = Color(1, 0, 1) # Make it Pink so you see it
		
	if not next_tpt.pressed.is_connected(_on_next_tpt_pressed):
		next_tpt.pressed.connect(_on_next_tpt_pressed)
		
	# 2. Hide original setup elements
	original_sprite.hide()
	if backsquare: backsquare.hide()
	
	# 3. Setup UI
	control.hide()
	BG.hide()
	dialogue_change_image.hide()
	hide_ui = true
	
	# 4. Connect Signals
	if not btn_change_image.pressed.is_connected(func(): dialogue_change_image.popup_centered()):
		btn_change_image.pressed.connect(func(): dialogue_change_image.popup_centered())
		dialogue_change_image.file_selected.connect(_on_file_selected)
		dialogue_change_image.canceled.connect(_close_all_ui)
	
	# 5. FORCE SLIDER START
	# Force the slider to 50 so we definitely spawn items
	slider.max_value = 300 
	slider.value = 50 
	old_slider_val_int = 0 # Reset tracker so the logic below triggers
	
	# 6. Spawn Initial Sprites
	var start_count = int(slider.value)
	for i in range(start_count):
		increment()
	
	print("Created ", duplicated_spriteslist.size(), " items.")


func _process(delta: float) -> void:
	# 1. UPDATE TIMERS
	time_passed += delta * speed
	overall_rotation += ROTATION_SPEED * delta 
	SPACING = slider_spacing.value 
	
	# 2. UPDATE BACKGROUND
	current_color_time += GRADIENT_SPEED * delta
	current_gradient_angle += GRADIENT_ANGLE_SPEED * delta
	queue_redraw() 

	# 3. HANDLE ADDING/REMOVING SPRITES
	handle_slider_logic()
	
	# 4. MOVE & SCALE SPRITES
	update_sprites_transform()




func update_sprites_transform():
	# --- A. MOUSE INFLUENCE ---
	var viewport_rect = get_viewport_rect()
	var mouse_pos = get_viewport().get_mouse_position()
	
	var norm_x = clamp(mouse_pos.x / viewport_rect.size.x, 0.0, 1.0)
	var norm_y = clamp(mouse_pos.y / viewport_rect.size.y, 0.0, 1.0)
	
	var target_scale = lerp(0.2, 1.5, norm_x) 
	
	# --- B. CENTER GRID ON SCREEN ---
	# Instead of using original_sprite.position, we calculate the screen center
	var screen_center = viewport_rect.size / 2.0
	
	# Calculate total grid size to center it perfectly
	var total_sprites = duplicated_spriteslist.size()
	if total_sprites == 0: return # Prevent crash if empty
	
	var rows = ceil(total_sprites / float(GRID_COLUMNS))
	var grid_width = GRID_COLUMNS * SPACING
	var grid_height = rows * SPACING
	
	# Determine top-left start point based on center
	var start_x = screen_center.x - (grid_width / 2.0)
	var start_y = screen_center.y - (grid_height / 2.0)
	
	# --- C. UPDATE LOOP ---
	for i in range(duplicated_spriteslist.size()):
		var sprite = duplicated_spriteslist[i]
		
		if is_instance_valid(sprite):
			# Force Visibility (Just in case)
			sprite.visible = true
			
			# 1. GRID MATH
			var col = i % GRID_COLUMNS
			var row = i / GRID_COLUMNS
			
			# 2. POSITION
			var x_pos = start_x + (col * SPACING)
			var wave_offset = sin(time_passed + (col * 0.5) + (row * 0.2)) * 30.0
			var y_pos = start_y + (row * SPACING) + wave_offset
			
			sprite.position = Vector2(x_pos, y_pos)
			
			# 3. SCALE & ROTATION
			sprite.scale = Vector2(target_scale, target_scale)
			var rotation_influence = lerp(1.0, 5.0, norm_y) 
			sprite.rotation = overall_rotation + (col * 0.1) * rotation_influence


#### HELPER FUNCTIONS ####

func handle_slider_logic():
	var current_slider_int = int(slider.value)
	if current_slider_int > old_slider_val_int:
		for i in range(current_slider_int - old_slider_val_int):
			increment()
		old_slider_val_int = current_slider_int
	elif current_slider_int < old_slider_val_int:
		for i in range(old_slider_val_int - current_slider_int):
			decrement()
		old_slider_val_int = current_slider_int

func increment(): 
	if not original_sprite: return
	
	var new_sprite = original_sprite.duplicate()
	new_sprite.visible = true # Explicitly Show!
	
	add_child(new_sprite)
	duplicated_spriteslist.append(new_sprite)

func decrement(): 
	if duplicated_spriteslist.size() > 0:
		var last_sprite = duplicated_spriteslist.pop_back()
		if is_instance_valid(last_sprite):
			last_sprite.queue_free()

func toggle_ui():
	if hide_ui:
		control.show(); BG.show(); hide_ui = false
	else:
		control.hide(); BG.hide(); hide_ui = true

func _close_all_ui():
	control.hide(); BG.hide(); dialogue_change_image.hide(); hide_ui = true

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("hide_all_ctrl"): toggle_ui()
	if Input.is_action_just_pressed("reset"): get_tree().reload_current_scene()
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()

func _on_file_selected(path: String):
	var image = Image.new()
	if image.load(path) != OK: return
	var new_tex = ImageTexture.create_from_image(image)
	
	# Apply to Original
	if original_sprite: 
		original_sprite.texture = new_tex
		original_sprite.modulate = Color(1,1,1) # Reset color from pink
		
	# Apply to Duplicates
	for sp in duplicated_spriteslist: 
		if is_instance_valid(sp): 
			sp.texture = new_tex
			sp.modulate = Color(1,1,1)
			
	_close_all_ui()
	
#func _on_next_tpt_pressed() -> void:
	## 1. Close the external Python thread cleanly (important!)
	## We don't want the thread trying to write back to the old, closing scene.
#
	## 2. Get the SceneTree and change the scene
	#var error = get_tree().change_scene_to_file(NEXT_SCENE_PATH)
#
	#if error != OK:
		## Handle the error if the scene file wasn.t found
		#print("SCENE SWITCH ERROR: Could not load scene file: ", NEXT_SCENE_PATH)
	#print("Error code: ", error)
