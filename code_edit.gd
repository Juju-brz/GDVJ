extends CodeEdit

func _ready():
	var button = $Button
	button.pressed.connect(_on_button_pressed)
	#self.text = ""  

func _on_button_pressed():
	var user_code = self.text
	print("truc")
	print(user_code)
