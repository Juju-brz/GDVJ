from qiskit import QuantumCircuit
from qiskit_aer import AerSimulator
import json

# Create a quantum circuit with 1 qubit and 1 classical bit
qc = QuantumCircuit(1, 1)

# Apply Hadamard (superposition)
qc.h(0)

# Measure qubit 0 into classical bit 0
qc.measure(0, 0)

# Run on simulator
sim = AerSimulator()
result = sim.run(qc).result()
counts = result.get_counts()

# Extract measurement result (0 or 1)
# Just pick the most frequent result
measurement = max(counts, key=counts.get)

output = {
    "result": measurement,
    "myvar": "myVariable23456"
}

print(json.dumps(output))