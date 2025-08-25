import os
import re
import numpy as np


# Define the directories containing the files
dirs = ['AL-data']


def extract_index(filename):
    match = re.search(r'_(\d+)\.cfg$', filename)  # Adjust for your file extension
    return int(match.group(1)) if match else float('inf')  # Use infinity if no numeric part is found

# Function to compute the L2 norm of the forces
def compute_force_norm(atom_data_lines):
    total_norm = 0
    for line in atom_data_lines:
        components = line.split()
        if len(components) == 8:  # Ensure it's an atom data line
            fx, fy, fz = map(float, components[-3:])
        total_norm += fx**2 + fy**2 + fz**2 
    return np.sqrt(total_norm)

# Process each directory
for dir in dirs:
    directory = os.path.join(os.getcwd(), dir)
    output_file = os.path.join(os.getcwd(), f"EFS-output-{dir}.txt")
    
    # Prepare a list to hold filename and result pairs
    results = []
    
    # Loop through each file in the directory
    for filename in os.listdir(directory):
        # Construct the full file path
        filepath = os.path.join(directory, filename)
        
        
        if not os.path.exists(filepath):
            continue  # Skip if the file doesn't exist

        with open(filepath, "r") as file:
            lines = file.readlines()

            # Variables to hold extracted data
            energy = None
            stress = None
            atom_data_lines = []

            # Parse the file
            inside_atom_data = False
            for idx, line in enumerate(lines):
                line = line.strip()
                if line.startswith("Energy"):
                    energy = float(lines[idx + 1].strip())
                elif line.startswith("PlusStress:"):
                    stress_state = list(map(float, lines[idx + 1].strip().split()))
                    stress_state = np.asarray(stress_state)/10
                    stress_tensor = np.array([[stress_state[0], stress_state[5], stress_state[4]], [stress_state[5], stress_state[1], stress_state[3]], [stress_state[4], stress_state[3], stress_state[2]]])
                    stress = np.mean(np.linalg.eigvalsh(stress_tensor))
                    #stress = float(np.sqrt(1/2*((stress_state[0]-stress_state[1])**2+(stress_state[1]-stress_state[2])**2+(stress_state[2]-stress_state[0])**2+3*(stress_state[3]**2+stress_state[4]**2+stress_state[5]**2))))
                elif line.startswith("AtomData"):
                    inside_atom_data = True
                elif line.startswith("END_CFG"):
                    inside_atom_data = False
                elif inside_atom_data:
                    atom_data_lines.append(line)

            # Compute force norm
            force_norm = compute_force_norm(atom_data_lines)
            # Write the extracted values to the output file
            results.append(f"{filename} "+ f"{energy:.6f}    "+ f"{force_norm:.6f}  " +f"{stress:.6f}")
            
    
    # Sort results based on the numeric index extracted from filenames
    results.sort(key=lambda x: extract_index(x.split(' ')[0]))
    
    # Write sorted results to the output file
    with open(output_file, 'w') as out_file:
        for result in results:
            out_file.write(f"{result}\n")
    
    print(f"Data extraction completed for directory '{dir}'. Results saved to {output_file}.")



