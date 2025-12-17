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


#var duplicated_spriteslist = []
@onready var old_slider_val_int: int = int(slider.value)


#### FUNCTIONS ####

func _ready() -> void:
	super._ready()
	Global.NEXT_SCENE_PATH = "res://templates/01_Superpositions_geometriques.tscn"
	# 1. SAFETY: Create placeholder if needed
	if original_sprite.texture == null:
		var placeholder = PlaceholderTexture2D.new()
		placeholder.size = Vector2(64, 64)
		original_sprite.texture = placeholder
	
	# 2. Hide setup elements
	original_sprite.hide()

	
	#if not next_tpt.pressed.is_connected(_on_next_tpt_pressed):
		#next_tpt.pressed.connect(_on_next_tpt_pressed)
		#
	## 4. Connect Signals
	#if not btn_change_image.pressed.is_connected(open_dialog):
		#btn_change_image.pressed.connect(open_dialog)
		#dialogue_change_image.file_selected.connect(_on_file_selected)
		#dialogue_change_image.canceled.connect(_close_all_ui)
	
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
	update_sprites_transform(delta)


#### THE LOGIC (SPIRAL RESTORED) ####

func update_sprites_transform(delta):
	var viewport_rect = get_viewport_rect()
	var screen_center = viewport_rect.size * 0.5
	
	
	var mouse_norm
	if mouse_activation == true:
		mouse_norm = mouse_control() # .x & .y
	if mouse_activation == false:
		mouse_norm = joystick_control(delta)

	var target_scale = lerp(0.5, 1.2, mouse_norm.x) # Mouse X controls size
	
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




#func _on_file_selected(path: String):
	#var image = Image.new()
	#if image.load(path) != OK: return
	#var new_tex = ImageTexture.create_from_image(image)
	#
	#if original_sprite: 
		#original_sprite.texture = new_tex
		#
	#for sp in duplicated_spriteslist: 
		#if is_instance_valid(sp): 
			#sp.texture = new_tex
			#
	#_close_all_ui()
	
