extends Node2D
class_name  mainScript
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

func getmouse() -> Vector2:
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
