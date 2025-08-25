import os
import subprocess
import re
import numpy as np

# Define the directories containing the files
dirs = ['300', '600', '900', 'vac', 'stk-flt', 'disl']

# Function to extract the last numeric index from filenames
def extract_index(filename):
    match = re.search(r'-(\d+)\.txt$', filename)
    return int(match.group(1)) if match else float('inf')  # Use infinity if no numeric part is found

# Process each directory
for dir in dirs:
    directory = os.path.join(os.getcwd(), dir)
    output_file = os.path.join(os.getcwd(), f"EFS-output-{dir}.txt")
    
    # Prepare a list to hold filename and result pairs
    results = []
    
    # Loop through each file in the directory
    for filename in os.listdir(directory):
        # Construct the full file path
        file_path = os.path.join(directory, filename)
        
        # Ensure it's a file
        if os.path.isfile(file_path):
            # Define the Bash command
            bash_command = (
                f"""grep -B 1 "Loop time" "{file_path}" | """
                f"""head -n 1 | """
                f"""awk '{{print $4, $6, $7, $8, $9, $10, $11, $12}}'"""
            )
            
            # Execute the Bash command and capture the output
            process = subprocess.Popen(
                bash_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
            )
            stdout, stderr = process.communicate()
            
            # Check if the command was successful
            if process.returncode == 0:
                # Decode the output and store it with the filename
                result = stdout.decode('utf-8').strip()
                if result:
                    efs = np.asarray(list(map(float, result.split(' '))))
                    energy, stress_state, force_norm = efs[0], efs[1:-1]/10000, efs[-1]
                    stress_tensor = np.array([[stress_state[0], stress_state[3], stress_state[4]], [stress_state[3], stress_state[1], stress_state[5]], [stress_state[4], stress_state[5], stress_state[2]]])
                    #stress = np.sqrt(1/2*((stress_state[0]-stress_state[1])**2+(stress_state[1]-stress_state[2])**2+(stress_state[2]-stress_state[0])**2+3*(stress_state[3]**2+stress_state[4]**2+stress_state[5]**2)))
                    stress = np.mean(np.linalg.eigvalsh(stress_tensor))
                    results.append(f"{filename} {energy:.6f} {force_norm:.6f} {stress:.6f}")
            else:
                # Print error for debugging
                print(f"Error processing file {filename} in {dir}: {stderr.decode('utf-8')}")
    
    # Sort results based on the numeric index extracted from filenames
    results.sort(key=lambda x: extract_index(x.split(' ')[0]))
    
    # Write sorted results to the output file
    with open(output_file, 'w') as out_file:
        for result in results:
            out_file.write(f"{result}\n")
    
    print(f"Data extraction completed for directory '{dir}'. Results saved to {output_file}.")

