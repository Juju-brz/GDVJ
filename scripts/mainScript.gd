extends Node2D
class_name  mainScript


#### 		VARIABLES 		####

### CONTROLS ###
@onready var control = $Control
@onready var BG = $BG_For_Controls
#slider
@onready var slider_duplication = $Control/VBoxContainer/HSlider_duplication
@onready var slider_radius = $Control/VBoxContainer/HSlider_radius
@onready var slider_speed = $Control/VBoxContainer/HSlider_speed
#slider old value
@onready var old_slider_val_int: int = int(slider_duplication.value)
@onready var old_slider_radius_val = int(slider_radius.value)
@onready var old_slider_speed_val = int(slider_speed.value)
#change scene
@onready var next_tpt = $Control/VBoxContainer/HBoxContainer/Btn_Switch_algorithm
#change geo
@onready var btn_change_image = $Control/VBoxContainer/Btn_Change_Image

@onready var dialogue_change_image = $Control/VBoxContainer/Dlg_Change_Image
@onready var original_sprite = $Square  
var hide_ui :bool = false


#CHANGE SCENE
var NEXT_SCENE_PATH : String = ""

#joy
var joy_pos := Vector2(0.5, 0.5) # position virtuelle normalisée
var joy_speed : float= 0.8

## duplication ##
var duplicated_spriteslist :Array = []
var duplication_count = 0
var old_duplication_count = 0

## Slider Variables ##
var SPEED : float = 1.0
var RADIUS: float = 100.0 


#### 		FUNCTIONS 		####


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

#Button for change Scene
func _on_next_tpt_pressed() -> void:
	
	var error = get_tree().change_scene_to_file(NEXT_SCENE_PATH)

	if error != OK:
		# Handle the error if the scene file wasn.t found
		print("mainScript : SCENE SWITCH ERROR: Could not load scene file: ", NEXT_SCENE_PATH)
	print("mainScript : Error code: ", error)

### CONTROL INPUT ###
func get_mouse() -> Vector2:
	var mouse_pos = get_viewport().get_mouse_position()
	return mouse_pos

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

	if Input.is_action_just_pressed("mouse"):
		GLOBAL.mouse_activation = !GLOBAL.mouse_activation
	if Input.is_action_just_pressed("change_scene"):
		_on_next_tpt_pressed()


#CREATE MOUSE CONTROL
func mouse_control():
	var viewport_rect = get_viewport_rect()
	#var mouse_pos = get_viewport().get_mouse_position()
	
	var norm_x = clamp(get_mouse().x / viewport_rect.size.x, 0.0, 1.0)
	var norm_y = clamp(get_mouse().y / viewport_rect.size.y, 0.0, 1.0)
	return Vector2(norm_x, norm_y)

#CREATE joystick and Controler CONTROL
func joystick_control(delta: float) -> Vector2:
	var x = Input.get_action_strength("joy_right") - Input.get_action_strength("joy_left")
	var y = Input.get_action_strength("joy_down") - Input.get_action_strength("joy_up")

	var dir = Vector2(x, y)

	if dir.length() > 0.1:
		joy_pos += dir * joy_speed * delta
		joy_pos = joy_pos.clamp(Vector2.ZERO, Vector2.ONE)

	return joy_pos

func control_norm(delta):
	var control_norm
	if GLOBAL.mouse_activation == true:
		control_norm = mouse_control() # .x & .y
	if GLOBAL.mouse_activation == false:
		control_norm = joystick_control(delta)
	return control_norm


## SLIDER FUNCTION ##

#CREATE ANOTHER GEO
func increment(): 
	if duplicated_spriteslist.size() >= 200.0:
		pass
	else:
		#print(duplicated_spriteslist.size())
		if not original_sprite: return
		var new_sprite = original_sprite.duplicate()
		new_sprite.visible = true 
		add_child(new_sprite)
		duplicated_spriteslist.append(new_sprite)


#DESTROY  LAST GEO
func decrement(): 
	if duplicated_spriteslist.size() <= 0:
		pass
	else:
		if duplicated_spriteslist.size() > 0:
			var last_sprite = duplicated_spriteslist.pop_back()
			if is_instance_valid(last_sprite):
				last_sprite.queue_free()

func Radius_Incr():
	RADIUS = RADIUS + 1.0 
	old_slider_radius_val = RADIUS

func Radius_Decr():
	RADIUS = RADIUS - 1.0
	old_slider_radius_val = RADIUS

func Speed_Incr():
	SPEED = SPEED + 1.0
	old_slider_speed_val = SPEED

func Speed_Decr():
	SPEED = SPEED - 1.0
	old_slider_speed_val = SPEED

#func slider_visual_update(a, b, slider):
	#if a != b:
		#a = b
		#slider.value = a
	#if a < b:
		#decrement()

## READY & PROCESS ##
func _ready() -> void:
	duplication_count = duplicated_spriteslist.size()
	old_duplication_count = duplication_count
	control.hide()
	BG.hide()
	dialogue_change_image.hide()
	hide_ui = true
	
	#SPEED = slider_speed.value
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
	#slider_visual_update(duplication_count, duplicated_spriteslist.size(), slider)
	if slider_duplication.value > duplicated_spriteslist.size():
		increment()
	if slider_duplication.value < duplicated_spriteslist.size():
		decrement()
	
	
	if slider_radius.value > old_slider_radius_val:
		Radius_Incr()

	if slider_radius.value < old_slider_radius_val:
		Radius_Decr()

	if slider_speed.value > old_slider_speed_val:
		Speed_Incr()

	if slider_speed.value < old_slider_speed_val:
		Speed_Decr()
	
	## CONTROLS ##
	if Input.is_action_pressed("joy_increment"):
		#increment()
		slider_duplication.value += 1


	if Input.is_action_pressed("joy_decrement"):
		#decrement()
		slider_duplication.value -= 1
	
	if Input.is_action_pressed("joy_speed_down"):
		slider_speed.value -= 0.5

	if Input.is_action_pressed("joy_speed_up"):
		slider_speed.value += 0.5

	
	if Input.is_action_pressed("joy_radius_incr"):
		slider_radius.value += 1
	
	if Input.is_action_pressed("joy_radius_decr"):
		slider_radius.value -= 1
