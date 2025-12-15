extends mainScript
class_name Spiral

#### VARIABLES ####

# --- VISUAL SETTINGS ---
# In your original script, SPACING was the angle step. 
# 0.5 radians is about 30 degrees, creating a nice spiral.
var ANGLE_STEP: float = 0.5 

# We use the slider to control the Radius (Distance from center)
var RADIUS: float = 100.0 

var time_passed: float = 0.0 
var speed: float = 2.0 

# --- MOUSE INTERACTION ---
var overall_rotation: float = 0.0
var ROTATION_SPEED: float = deg_to_rad(10.0)

### CONTROLS ###
#@onready var control = $Control
#@onready var BG = $BG_For_Controls
#@onready var slider = $Control/VBoxContainer/HSlider
#@onready var slider_spacing = $Control/VBoxContainer/HSlider_spacing
#@onready var btn_change_image = $Control/VBoxContainer/Btn_Change_Image
#@onready var dialogue_change_image = $Control/VBoxContainer/Dlg_Change_Image
#@onready var original_sprite = $Square  
#@onready var next_tpt = $Control/VBoxContainer/HBoxContainer/Btn_Switch_algorythme
const NEXT_SCENE_PATH = "res://templates/01_Superpositions_geometriques.tscn"
# Trackers
#var hide_ui :bool = false
var duplicated_spriteslist = []
@onready var old_slider_val_int: int = int(slider.value)


#### LIFECYCLE ####

func _ready() -> void:
	
	# 1. SAFETY: Create placeholder if needed
	if original_sprite.texture == null:
		var placeholder = PlaceholderTexture2D.new()
		placeholder.size = Vector2(64, 64)
		original_sprite.texture = placeholder
	
	# 2. Hide setup elements
	original_sprite.hide()
	
	# 3. Setup UI
	control.hide()
	BG.hide()
	dialogue_change_image.hide()
	hide_ui = true
	
	if not next_tpt.pressed.is_connected(_on_next_tpt_pressed):
		next_tpt.pressed.connect(_on_next_tpt_pressed)
		
	# 4. Connect Signals
	if not btn_change_image.pressed.is_connected(open_dialog):
		btn_change_image.pressed.connect(open_dialog)
		dialogue_change_image.file_selected.connect(_on_file_selected)
		dialogue_change_image.canceled.connect(_close_all_ui)
	
	# 5. INITIALIZE SLIDERS
	slider.max_value = 200 
	slider.value = 50   # Start with 50 items
	old_slider_val_int = 0 
	
	# 6. Spawn Initial Sprites
	var start_count = int(slider.value)
	for i in range(start_count):
		increment()



func _process(delta: float) -> void:
	# 1. UPDATE TIMERS
	time_passed += delta * speed
	overall_rotation += ROTATION_SPEED * delta 
	
	# 2. UPDATE RADIUS FROM SLIDER
	# In original script, slider_spacing controlled Radius
	RADIUS = slider_spacing.value 
	
	# 3. HANDLE ADDING/REMOVING SPRITES
	handle_slider_logic()
	
	# 4. MOVE SPRITES (The Spiral Logic)
	update_sprites_transform()


#### THE LOGIC (SPIRAL RESTORED) ####

func update_sprites_transform():
	var viewport_rect = get_viewport_rect()
	var screen_center = viewport_rect.size / 2.0
	
	# --- MOUSE SCALE (Optional - Keeps it feeling "Beautiful") ---
	var mouse_pos = get_viewport().get_mouse_position()
	var norm_x = clamp(mouse_pos.x / viewport_rect.size.x, 0.0, 1.0)
	var target_scale = lerp(0.5, 1.2, norm_x) # Mouse X controls size
	
	# --- LOOP THROUGH SPRITES ---
	for i in range(duplicated_spriteslist.size()):
		var sprite = duplicated_spriteslist[i]
		
		if is_instance_valid(sprite):
			sprite.visible = true
			
			# --- SPIRAL MATH (Like Original Script) ---
			# Angle increases with index 'i'
			var angle = i * ANGLE_STEP
			
			# --- WAVE FUNCTION (COMMENTED OUT AS REQUESTED) ---
			# var wave_offset = sin(time_passed + (i * 0.2)) * 20.0
			# var current_radius = RADIUS + wave_offset
			var current_radius = RADIUS # Use static radius
			
			# Calculate Position based on Angle and Radius
			var x_pos = screen_center.x + cos(angle) * current_radius
			var y_pos = screen_center.y + sin(angle) * current_radius
			
			sprite.position = Vector2(x_pos, y_pos)
			
			# --- ROTATION & SCALE ---
			# Restore the rotation logic: rotation = angle
			sprite.rotation = angle + overall_rotation
			sprite.scale = Vector2(target_scale, target_scale)


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
	new_sprite.visible = true 
	add_child(new_sprite)
	duplicated_spriteslist.append(new_sprite)

func decrement(): 
	if duplicated_spriteslist.size() > 0:
		var last_sprite = duplicated_spriteslist.pop_back()
		if is_instance_valid(last_sprite):
			last_sprite.queue_free()

func _close_all_ui():
	control.hide(); BG.hide(); dialogue_change_image.hide(); hide_ui = true

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("hide_all_ctrl"):
		hide_ui = !hide_ui
		control.visible = !hide_ui
		BG.visible = !hide_ui
	
	if Input.is_action_just_pressed("reset"): get_tree().reload_current_scene()
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()

func _on_file_selected(path: String):
	var image = Image.new()
	if image.load(path) != OK: return
	var new_tex = ImageTexture.create_from_image(image)
	
	if original_sprite: 
		original_sprite.texture = new_tex
		
	for sp in duplicated_spriteslist: 
		if is_instance_valid(sp): 
			sp.texture = new_tex
			
	_close_all_ui()
	
func _on_next_tpt_pressed() -> void:
	# 1. Close the external Python thread cleanly (important!)
	# We don't want the thread trying to write back to the old, closing scene.

	# 2. Get the SceneTree and change the scene
	var error = get_tree().change_scene_to_file(NEXT_SCENE_PATH)

	if error != OK:
		# Handle the error if the scene file wasn.t found
		print("SCENE SWITCH ERROR: Could not load scene file: ", NEXT_SCENE_PATH)
	print("Error code: ", error)
