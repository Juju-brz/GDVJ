extends mainScript

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	#SPACING = SPACING + 800.0
	RADIUS = 50.0
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#super._process(delta)
	increment()
	RADIUS += 1.0 * delta
	print(RADIUS)
