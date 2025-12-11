extends mainScript


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#SPACING = SPACING + 800.0
	SPACING = 50.0
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	increment()
	#print(delta)
	#SPACING = SPACING + 40.0
	#print(SPACING)
