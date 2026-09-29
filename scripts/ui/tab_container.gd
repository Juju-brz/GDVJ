extends TabContainer
#@export var ma_scene = "res://UI/code_func.tscn"
var ma_scene = load("res://UI/code_func.tscn")

func _process(delta):
	if Input.is_action_just_pressed("test_add_func"):  # par exemple : score >= 10
		var instance = ma_scene.instantiate()
		add_child(instance)  # ajoute la scène comme enfant de ce node
