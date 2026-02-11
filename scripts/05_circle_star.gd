extends mainScript

#### VARIABLES ####


var ANGLE_STEP: float = 0.5 

var time_passed: float = 0.0 
#var speed: float = 2.0 

# --- MOUSE INTERACTION ---
var overall_rotation: float = 0.0
var ROTATION_SPEED: float = deg_to_rad(10.0)



#### FUNCTIONS ####

func _ready() -> void:
	super._ready()
	NEXT_SCENE_PATH = "res://templates/06_Pentacle.tscn"
	# 1. SAFETY: Create placeholder if needed
	if original_sprite.texture == null:
		var placeholder = PlaceholderTexture2D.new()
		placeholder.size = Vector2(64, 64)
		original_sprite.texture = placeholder
	
	# 2. Hide setup elements
	original_sprite.hide()

	

	
	# 5. INITIALIZE SLIDERS
	slider_duplication.max_value = 200 
	slider_duplication.value = 100
	old_slider_val_int = 0 
	
	# 6. Spawn Initial Sprites
	var start_count = int(slider_duplication.value)
	for i in range(start_count):
		increment()

func _process(delta: float) -> void:
	super._process(delta)

	# 1. UPDATE TIMERS
	time_passed += delta * SPEED
	overall_rotation += ROTATION_SPEED * delta * SPEED 

	update_sprites_transform(delta)

#### THE LOGIC (SPIRAL RESTORED) ####

func update_sprites_transform(delta):
	var viewport_rect = get_viewport_rect()
	var screen_center = viewport_rect.size * 0.5
	
	
	var mouse_norm
	if GLOBAL.mouse_activation == true:
		mouse_norm = mouse_control() # .x & .y
	if GLOBAL.mouse_activation == false:
		mouse_norm = joystick_control(delta)

	var target_scale = lerp(0.5, 1.2, mouse_norm.x) # Mouse X controls size
	
	# --- LOOP THROUGH SPRITES ---
	for i in range(duplicated_spriteslist.size()):
		var sprite = duplicated_spriteslist[i]
		#overall_rotation += 0.2 #* delta
		if is_instance_valid(sprite):
			sprite.visible = true
			
			# --- SPIRAL MATH (Like Original Script) ---
			# Angle increases with index 'i'
			var angle = i * ANGLE_STEP

			var current_radius = RADIUS # Use static radius
			
			# Calculate Position based on Angle and Radius
			var x_pos = screen_center.x + cos(angle) * current_radius *10.2
			var y_pos = screen_center.y + cos(angle) * current_radius 
			
			sprite.position = Vector2(x_pos, y_pos)
			
			# --- ROTATION & SCALE ---
			# Restore the rotation logic: rotation = angle
			sprite.rotation = angle + overall_rotation * SPEED
			sprite.scale = Vector2(target_scale, target_scale)
			
			sprite.skew = SHEAR

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
	
