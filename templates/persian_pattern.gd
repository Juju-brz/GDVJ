extends mainScript


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RADIUS = 50


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#super._process(delta)
	increment() 
	#print(delta)
	RADIUS = RADIUS + 1
	print(RADIUS)
