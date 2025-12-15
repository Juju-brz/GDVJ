extends Node2D
class_name  mainScript

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
