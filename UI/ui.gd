extends Control

### CONTROLS ###
@onready var control = self
@onready var BG = $BG_For_Controls
@onready var slider = $Control/VBoxContainer/HSlider
@onready var slider_spacing = $VBoxContainer
@onready var btn_change_image = $VBoxContainer/Btn_Change_Image
@onready var dialogue_change_image = $VBoxContainer/Dlg_Change_Image
@onready var original_sprite = $Square  
@onready var next_tpt = $VBoxContainer/HBoxContainer/Btn_Switch_algorithm

var hide_ui :bool = false
var mouse_activation = true
@onready var NEXT_SCENE_PATH = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#if not btn_change_image.pressed.is_connected(open_dialog):
		#btn_change_image.pressed.connect(open_dialog)
	#
	#if not dialogue_change_image.file_selected.is_connected(_on_file_selected):
		#dialogue_change_image.file_selected.connect(_on_file_selected)
	#
	#if not dialogue_change_image.canceled.is_connected(_close_all_ui):
		#dialogue_change_image.canceled.connect(_close_all_ui)
		#
	#if not next_tpt.pressed.is_connected(_on_next_tpt_pressed):
		#next_tpt.pressed.connect(_on_next_tpt_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func _on_next_tpt_pressed() -> void:
	# 1. Close the external Python thread cleanly (important!)
	# We don't want the thread trying to write back to the old, closing scene.

	# 2. Get the SceneTree and change the scene
	var error = get_tree().change_scene_to_file(Global.NEXT_SCENE_PATH)

	if error != OK:
		# Handle the error if the scene file wasn.t found
		print("SCENE SWITCH ERROR: Could not load scene file: ", Global.NEXT_SCENE_PATH)
	print("Error code: ", error)
	
func _close_all_ui():
	control.hide(); BG.hide(); dialogue_change_image.hide(); hide_ui = true

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
		mouse_activation = !mouse_activation
	if Input.is_action_just_pressed("change_scene"):
		#_on_next_tpt_pressed()
		_on_btn_change_image_pressed()

func open_dialog():
	dialogue_change_image.popup_centered()

func _on_file_selected(path: String):
	var image = Image.new()
	if image.load(path) != OK: return
	var new_tex = ImageTexture.create_from_image(image)
	
	if original_sprite:
		original_sprite.texture = new_tex
	
	_close_all_ui()


func _on_btn_change_image_pressed() -> void:
	open_dialog()
	var error = get_tree().change_scene_to_file(NEXT_SCENE_PATH)

	if error != OK:
		# Handle the error if the scene file wasn.t found
		print("SCENE SWITCH ERROR: Could not load scene file: ", NEXT_SCENE_PATH)
	print("Error code: ", error)


func _on_btn_switch_algorithm_pressed() -> void:
	_on_next_tpt_pressed()
	pass # Replace with function body.
