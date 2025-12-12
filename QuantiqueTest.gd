extends Node

func _ready() -> void:
	run_python_quantum()

func run_python_quantum():
	var output = []
	var _exit_code = OS.execute("C:/Users/Alika/AppData/Local/Programs/Python/Python313/python.exe", ["QuantiqueTest.py"], output, true)

	print("Exit code:", _exit_code)
	print("Raw output:", output)

	if output.size() == 0:
		print("⚠ Python printed nothing!")
		return

	var parsed = JSON.parse_string(output[0])
	print("Parsed JSON:", parsed)

	print("Measurement:", parsed.result)
	print("myvar:", parsed.myvar)
