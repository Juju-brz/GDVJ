extends Node
class_name  truc


#### VARIABLES ####

### CONTROLS ###
@onready var control = $Control
@onready var BG = $BG_For_Controls
@onready var slider = $Control/VBoxContainer/HSlider
@onready var slider_spacing = $Control/VBoxContainer/HSlider_spacing
@onready var btn_change_image = $Control/VBoxContainer/Btn_Change_Image
@onready var dialogue_change_image = $Control/VBoxContainer/Dlg_Change_Image
@onready var original_sprite = $Square  
@onready var next_tpt = $Control/VBoxContainer/HBoxContainer/Btn_Switch_algorithm

var hide_ui :bool = false
var NEXT_SCENE_PATH = ""
#var mouse_activation = true

#joy
var joy_pos := Vector2(0.5, 0.5) # position virtuelle normalisée
var joy_speed := 1.2

var duplicated_spriteslist :Array= []

### TO DO
# add control speed
var speed : float = 2.0

#### FUNCTIONS ####
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

func _on_next_tpt_pressed() -> void:
	# 1. Close the external Python thread cleanly (important!)
	# We don't want the thread trying to write back to the old, closing scene.

	# 2. Get the SceneTree and change the scene
	var error = get_tree().change_scene_to_file(NEXT_SCENE_PATH)

	if error != OK:
		# Handle the error if the scene file wasn.t found
		print("SCENE SWITCH ERROR: Could not load scene file: ", NEXT_SCENE_PATH)
	print("Error code: ", error)

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
	
	#if Input.is_action_pressed("joy_increment"):
		#increment()
	##if Input.act("joy_increment"):
		##increment()
	#if Input.is_action_pressed("joy_decrement"):
		#decrement()

#func mouse_control():
	#var viewport_rect = get_viewport_rect()
	##var mouse_pos = get_viewport().get_mouse_position()
	#
	#var norm_x = clamp(get_mouse().x / viewport_rect.size.x, 0.0, 1.0)
	#var norm_y = clamp(get_mouse().y / viewport_rect.size.y, 0.0, 1.0)
	#return Vector2(norm_x, norm_y)


func joystick_control(delta: float) -> Vector2:
	var x = Input.get_action_strength("joy_right") - Input.get_action_strength("joy_left")
	var y = Input.get_action_strength("joy_down") - Input.get_action_strength("joy_up")

	var dir = Vector2(x, y)

	if dir.length() > 0.1:
		joy_pos += dir * joy_speed * delta
		joy_pos = joy_pos.clamp(Vector2.ZERO, Vector2.ONE)

	return joy_pos
#
#func control_norm(delta):
	#var control_norm
	#if GLOBAL.mouse_activation == true:
		#control_norm = mouse_control() # .x & .y
	#if GLOBAL.mouse_activation == false:
		#control_norm = joystick_control(delta)
	#return control_norm

func increment(): 
	if not original_sprite: return
	var new_sprite = original_sprite.duplicate()
	new_sprite.visible = true 
	add_child(new_sprite)
	duplicated_spriteslist.append(new_sprite)

func decrement(): 
	if duplicated_spriteslist.size() <= 0:
		pass
	else:
		if duplicated_spriteslist.size() > 0:
			var last_sprite = duplicated_spriteslist.pop_back()
			if is_instance_valid(last_sprite):
				last_sprite.queue_free()

#func speed_up():
	#speed +=1

func _ready() -> void:
	
	control.hide()
	#BG.hide()
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
	if Input.is_action_pressed("joy_increment"):
		increment()

	if Input.is_action_pressed("joy_decrement"):
		decrement()

	if Input.is_action_pressed("joy_speed_down"):
		if speed <= 1:
			pass
		else:
			speed -= 1.0
			print(speed)
	if Input.is_action_pressed("joy_speed_up"):
		if speed >= 20.0:
			pass
		else:
			speed += 1.0
			print(speed)
