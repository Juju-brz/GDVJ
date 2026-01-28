extends mainScript

#### VARIABLES ####

# --- WAVE & GRID SETTINGS ---
var SPACING: float = 60.0 
var GRID_COLUMNS: int = 15 
var time_passed: float = 0.0 
#var speed: float = 5.0 

# --- MOUSE INTERACTION SETTINGS ---
var overall_rotation: float = 0.0
var ROTATION_SPEED: float = deg_to_rad(10.0)

# --- DATA ARRAYS ---
var array_points: Array[Vector2] = []


#const NEXT_SCENE_PATH = "res://templates/03-Spiral.tscn" # <-- CHANGE THIS PATH!
# Trackers

#var duplicated_spriteslist = []
#@onready var old_slider_val_int: int = int(slider.value)
#@onready var old_slider_spacing_val: float = slider_spacing.value

# --- BACKGROUND GRADIENT VARIABLES ---
@onready var backsquare = $ColorRect 


var current_color_time: float = 0.0
var current_gradient_angle: float = 0.0
var GRADIENT_SPEED: float = 0.1
var GRADIENT_ANGLE_SPEED: float = 10.0


#### FUNCTIONS ####

func _ready() -> void:
	super._ready()
	
	speed = 5.0 
	NEXT_SCENE_PATH = "res://templates/03-Spiral.tscn"

	if not next_tpt.pressed.is_connected(_on_next_tpt_pressed):
		next_tpt.pressed.connect(_on_next_tpt_pressed)
		
	# 2. Hide original setup elements
	original_sprite.hide()
	if backsquare: backsquare.hide()
	
	

	# 5. FORCE SLIDER START
	# Force the slider to 50 so we definitely spawn items
	slider_duplication.max_value = 300 
	slider_duplication.value = 50 
	old_slider_val_int = 0 # Reset tracker so the logic below triggers
	
	# 6. Spawn Initial Sprites
	var start_count = int(slider_duplication.value)
	for i in range(start_count):
		increment()
	
	print("Created ", duplicated_spriteslist.size(), " items.")


func _process(delta: float) -> void:
	super._process(delta)
	# 1. UPDATE TIMERS
	time_passed += delta * speed
	overall_rotation += ROTATION_SPEED * delta 
	SPACING = slider_radius.value 
	
	# 2. UPDATE BACKGROUND
	current_color_time += GRADIENT_SPEED * delta
	current_gradient_angle += GRADIENT_ANGLE_SPEED * delta
	queue_redraw() 

	# 3. HANDLE ADDING/REMOVING SPRITES
	#handle_slider_logic()
	
	# 4. MOVE & SCALE SPRITES
	update_sprites_transform(delta)




func update_sprites_transform(delta):
	# --- A. MOUSE INFLUENCE ---
	var viewport_rect = get_viewport_rect()
	
	var mouse_norm
	if GLOBAL.mouse_activation == true:
		mouse_norm = mouse_control() # .x & .y
	if GLOBAL.mouse_activation == false:
		mouse_norm = joystick_control(delta)
		
	var target_scale = lerp(0.2, 1.5, mouse_norm.x) 
	
	# --- B. CENTER GRID ON SCREEN ---
	# Instead of using original_sprite.position, we calculate the screen center
	var screen_center = viewport_rect.size * 0.5
	
	# Calculate total grid size to center it perfectly
	var total_sprites = duplicated_spriteslist.size()
	if total_sprites == 0: return # Prevent crash if empty
	
	var rows = ceil(total_sprites / float(GRID_COLUMNS))
	var grid_width = GRID_COLUMNS * SPACING
	var grid_height = rows * SPACING
	
	# Determine top-left start point based on center
	var start_x = screen_center.x - (grid_width * 0.5)
	var start_y = screen_center.y - (grid_height * 0.5)
	
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
			var rotation_influence = lerp(1.0, 5.0, mouse_norm.y) 
			sprite.rotation = overall_rotation + (col * 0.1) * rotation_influence





#func toggle_ui():
	#if hide_ui:
		#control.show(); BG.show(); hide_ui = false
	#else:
		#control.hide(); BG.hide(); hide_ui = true




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
	
