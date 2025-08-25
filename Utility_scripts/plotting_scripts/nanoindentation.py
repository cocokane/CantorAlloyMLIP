import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit

# Function to parse the data from a file
def parse_data(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()
    header = lines[0].split()
    values = np.array([list(map(float, line.split())) for line in lines[1:]])
    return header, values

# Function to fit P = k * (h - h0)^(3/2) for h > h0
def p_h_fit(h, h0, k):
    return np.where(h > h0, k * (h - h0)**(3/2), 0)

# Indenter radius in angstroms
R = 30.0

# File paths for the two potentials
files = {
    "MTP": "indentation_MTP.txt",
    "MEAM": "indentation_MEAM.txt"
}

# Plot setup
plt.figure(figsize=(10, 7))

# Loop through each file and process the data
legend_labels = []
hardness_text = []

for potential, file_path in files.items():
    # Parse the data
    header, values = parse_data(file_path)

    # Extract relevant columns
    h = values[:, 2]  # Indentor position (v_z, 3rd column)
    P = values[:, -1]  # Pz (last column)

    # Convert h to depth of indentation (assume max position as reference)
    h_depth = max(h) - h

    # Identify the first significant non-zero pressure
    significant_indices = np.where(P > 0.01)[0]
    if len(significant_indices) == 0:
        print(f"No significant non-zero values found in {potential} data.")
        continue

    start_index = significant_indices[0]
    end_index = min(start_index + 250, len(P))

    h_fit = h_depth[start_index:end_index]
    P_fit = P[start_index:end_index]

    # Perform the curve fit
    params, _ = curve_fit(p_h_fit, h_fit, P_fit, p0=[h_fit[0], 1])
    h0_fit, k_fit = params

    depth = h_fit[-1] - h_fit[0] 
    # Calculate hardness (H) using k
    H = (k_fit / (2 * np.pi * R * depth)) * (160.27 * 1000 / 9.8)

    # Define colors for each potential
    color_data = 'blue' if potential == "MTP" else 'red'
    color_fit = 'black'

    # Plot the simulation data
    plt.plot(h_depth, P, 'o', label=f'{potential}', markersize=5, color=color_data)

    # Plot the fitted curve
    h_smooth = np.linspace(min(h_depth), max(h_depth), 500)
    P_smooth = p_h_fit(h_smooth, h0_fit, k_fit)
    plt.plot(h_smooth, P_smooth, '--', color=color_fit, linewidth=2)

    # Store the equation for the legend
    equation_str = rf"$P = {k_fit:.2f} (h - {h0_fit:.2f})^{{3/2}}$"
    legend_labels.append(f"{potential}: {equation_str}")

    # Store hardness value text
    hardness_text.append(f"{potential}: H = {H:.2f} HBN")

# Customize the plot
#plt.title('P vs h Plot for Nanoindentation', fontsize=20, fontweight='bold')
plt.xlabel(r'$Depth$ $of$ $Indentation$ $(h)$'+' [\u212B]', fontsize=20)
plt.ylabel(r'$Load$ $P$ $(eV/$'+'$\u212B)$', fontsize=20, fontweight='bold')

# Set legend with equations
plt.legend(fontsize=12)

# Add hardness values on the left side
plt.text(0.02 * max(h_depth), 0.8 * max(P), '\n'.join(hardness_text), fontsize=14, verticalalignment='top')

# Add hardness values on the left side
plt.text(0.02 * max(h_depth), 0.5 * max(P), '\n'.join(legend_labels), fontsize=14, verticalalignment='top')

# Save the plot
plt.tight_layout()
plt.savefig('P_vs_depth_comparison_plot.png', dpi=300)

# Show the plot
plt.show()

