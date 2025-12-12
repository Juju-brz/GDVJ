extends Node2D

func _ready():
	var output := []
	var python_path = "res://ve/venv/Scripts"

	# Note: res:// doesn't work for executables, so use ABSOLUTE PATH:
	python_path = "D:/00 - ATI - Semestre03/00-Python-Quantique/00-Projet/Interactive_Pattern_Generator/ve/venv/Scripts/python.exe"

	OS.execute(python_path, ["QuantiqueTest.py"], output, true)
	
	if output.size() > 0:
		print("Python output:", output[0])
	else:
		print("No output")
