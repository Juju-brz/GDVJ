
class_name QuantiqueTest

# The array to hold the raw output from the external process
var output: Array = []

# Timer for calling the Python script (5 seconds)
var quantum_call_timer: float = 0.0
const QUANTUM_CALL_INTERVAL: float = 10.0  # <--- Changed to 10 seconds per your request

# Timer for the smooth interpolation (5 seconds)
var lerp_time: float = 0.0
const LERP_DURATION: float = 5.0      # Time taken for the smooth transition

# --- LERP STATE VARIABLES (NEW) ---
var lerp_a: float = 0.0 # Start value of the current interpolation
var lerp_b: float = 0.0 # Target value (derived from the latest quantum result)
var lerp_c: float = 0.0 # Current smoothed result (the output of the lerp)


# Global variables to store the last result (for debugging)
var last_entangled_result: String = "N/A"
var last_qubit_count: int = 0
var last_quantum_state: String = "Idle"

# ----------------------------------------------------------------------
# 1. Configuration 
# ----------------------------------------------------------------------
const PYTHON_SCRIPT_RESOURCE_PATH = "res://QuantiqueTest.py"
const VENV_PYTHON_RELATIVE_PATH = "ve/venv/Scripts/python.exe"


func _get_venv_python_path() -> String:
	var project_root_path = ProjectSettings.globalize_path("res://")
	return project_root_path.path_join(VENV_PYTHON_RELATIVE_PATH)


func _convert_quantum_result_to_float(result_string: String) -> float:
	# Convert the quantum result string (e.g., "00" or "11") into a float (0.0 or 1.0)
	# Assuming a 2-qubit Bell state where only "00" or "11" are expected.
	match result_string:
		"00":
			return 0.0
		"11":
			return 1.0
		_: # Fallback for unexpected or single qubit results ("0" or "1")
			if result_string.is_valid_float():
				return result_string.to_float()
			return 0.5 # Default to a midpoint if the string is invalid


func _handle_new_quantum_data(data: Dictionary):
	# 1. Update debug variables
	last_entangled_result = str(data.get("entangled_result", "Error"))
	last_qubit_count = int(data.get("qubit_count", 0))
	last_quantum_state = str(data.get("state", "Unknown"))
	
	# 2. Convert the quantum result to the target float value (0.0 or 1.0)
	var new_target_value = _convert_quantum_result_to_float(last_entangled_result)

	# 3. --- LERP LOGIC STARTS HERE ---
	# The previous target (lerp_b) becomes the new start (lerp_a)
	lerp_a = lerp_b
	
	# The new quantum result becomes the new target (lerp_b)
	lerp_b = new_target_value
	
	# Reset the timer to start the 5-second interpolation
	lerp_time = 0.0
	# ----------------------------------

	# Print final result
	print("--- New Quantum Target Set ---")
	print("New Target (B): ", lerp_b)
	print("Old Start (A): ", lerp_a)
	print("Qubit Result: ", last_entangled_result)


func get_quantum_random():
	var python_executable_path = _get_venv_python_path()
	var absolute_script_path = ProjectSettings.globalize_path(PYTHON_SCRIPT_RESOURCE_PATH)
	
	output.clear()  
	var exit_code = OS.execute(python_executable_path, [absolute_script_path], output, true)
	
	if exit_code == 0:
		if output.size() > 0:
			var json_result = output[0]
			var json_data = JSON.parse_string(json_result)
			
			if json_data != null and typeof(json_data) == TYPE_DICTIONARY:
				_handle_new_quantum_data(json_data) # Call handler function
			else:
				print("JSON Parse Error or Invalid Data (Check Python print): ", json_result)
		else:
			print("Python script ran, but returned no output.")
	else:
		print("--- PYTHON EXECUTION ERROR (VENV FAILED) ---")
		print("Exit Code: ", exit_code)
		# Removed other print statements for cleaner console output


func _ready():
	# Initialize the first target value (B) to 0.0 so the first lerp starts correctly
	# This ensures A and B are ready for the first quantum result.
	lerp_b = 0.0 
	
	print("VENV Path constructed:", _get_venv_python_path())
	pass

func _process(delta):
	
	# --- 1. LERP SMOOTHING (Happens every frame) ---
	if lerp_time < LERP_DURATION:
		lerp_time += delta
		var t = clamp(lerp_time / LERP_DURATION, 0.0, 1.0)
		
		# Update the smooth result (C)
		lerp_c = lerp(lerp_a, lerp_b, t)
		
		# Debug: See the smooth value change
		# print("C: ", lerp_c)

	# --- 2. QUANTUM CALL TIMER (Happens every 10 seconds) ---
	quantum_call_timer += delta
	
	if quantum_call_timer >= QUANTUM_CALL_INTERVAL:
		get_quantum_random()
		quantum_call_timer = 0.0  # Reset timer
