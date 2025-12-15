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
