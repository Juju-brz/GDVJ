from qiskit import QuantumCircuit
from qiskit_aer import AerSimulator
import json

# --- SET NUMBER OF QUBITS ---
NUM_QUBITS = 4 

# Create a quantum circuit with 4 qubits and 4 classical bits
qc = QuantumCircuit(NUM_QUBITS, NUM_QUBITS)

# --- CREATE UNIFORM SUPERPOSITION ---
# Apply a Hadamard (H) gate to EVERY qubit.
for i in range(NUM_QUBITS):
    qc.h(i)

# Measure all 4 qubits into corresponding classical bits
for i in range(NUM_QUBITS):
    qc.measure(i, i)

# Run on simulator 
sim = AerSimulator()
# Using 1 shot ensures we get a single, random result from the 16 possibilities.
result = sim.run(qc, shots=1).result() 
counts = result.get_counts()

# --- CONVERSION STEP ---
# 1. Get the binary measurement key (e.g., '0110')
binary_measurement = list(counts.keys())[0]

# 2. Convert the binary string to a decimal integer (e.g., 6)
decimal_measurement = int(binary_measurement, 2)

output = {
    # The result is now an integer from 0 to 15
    "entangled_result": decimal_measurement,
    "qubit_count": NUM_QUBITS,
    "state": "Decimal Output (0-15)"  # <-- Updated state name for clarity
}

# Print the JSON output for Godot
print(json.dumps(output))