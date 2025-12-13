from qiskit import QuantumCircuit
from qiskit_aer import AerSimulator
import json

# --- SET NUMBER OF QUBITS ---
NUM_QUBITS = 2

# Create a quantum circuit with 2 qubits and 2 classical bits
qc = QuantumCircuit(NUM_QUBITS, NUM_QUBITS)

# --- CREATE ENTANGLEMENT (BELL STATE) ---
# 1. Apply Hadamard to qubit 0 (superposition)
qc.h(0)

# 2. Apply CNOT with control 0 and target 1
# This entangles qubit 0 and qubit 1. 
# Resulting states are |00> and |11> (50% each).
qc.cx(0, 1)

# Measure all qubits into corresponding classical bits
# The measurement results (counts) will only show '00' and '11'.
for i in range(NUM_QUBITS):
    qc.measure(i, i)

# Run on simulator (Use less shots since we only care about the result string)
sim = AerSimulator()
# Using 1 shot ensures we get a single, random, definite measurement result
result = sim.run(qc, shots=1).result() 
counts = result.get_counts()

# The measurement key will be a string like '00' or '11'
measurement = list(counts.keys())[0]

output = {
    # The entangled result of all qubits (e.g., "00" or "11")
    "entangled_result": measurement,
    "qubit_count": NUM_QUBITS,
    "state": "Bell State"
}

# Print the JSON output for Godot
print(json.dumps(output))