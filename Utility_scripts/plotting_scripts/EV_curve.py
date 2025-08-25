import pandas as pd
import numpy as np
import scipy.optimize as opt
import matplotlib.pyplot as plt

# Define file paths
data_files = {
    "DFT": "DFT.txt",
    "MEAM": "MEAM.txt",
    "MTP": "AL.txt"
}

num_atoms = 108  

# Read data from files
data = {}
E_min_values = {}

for label, file in data_files.items():
    try:
        df = pd.read_csv(file, delim_whitespace=True, header=None, names=['Lattice Parameter (Å)', 'Energy (eV)'])
        df['Energy (eV)'] /= num_atoms  # Convert total energy to per-atom basis
        E_min = min(df['Energy (eV)'])  
        df['Volume (Å³/atom)'] = (df['Lattice Parameter (Å)'] ** 3) / 4  # Assuming FCC
        data[label] = df
        E_min_values[label] = E_min  # Store for later use
    except FileNotFoundError:
        print(f"Warning: {file} not found. Skipping {label}.")
        continue

# Birch-Murnaghan EOS function
def birch_murnaghan(V, E0, V0, B0, B0_prime):
    eta = (V0 / V) ** (2/3)
    return E0 + (9/16) * B0 * V0 * ((eta - 1) ** 3 * B0_prime + (eta - 1) ** 2 * (6 - 4 * eta))

# Store fitted parameters
eos_params = {}

# Create the plot
plt.figure(figsize=(10, 8), dpi=400)
colors = {'DFT': 'black', 'MEAM': 'red', 'MTP': 'blue'}
markers = {'DFT': 'o', 'MEAM': 's', 'MTP': '^'}

# colors = {'DFT': 'black', 'MTP': 'blue'}
# markers = {'DFT': 'o', 'MTP': '^'}

for label, df in data.items():
    # Fit EOS using per-atom energy
    try:
        print(df['Volume (Å³/atom)'])
        params, _ = opt.curve_fit(birch_murnaghan, df['Volume (Å³/atom)'].iloc[3:12], df['Energy (eV)'].iloc[3:12],
                                  p0=[min(df['Energy (eV)'].iloc[3:12]), np.mean(df['Volume (Å³/atom)'].iloc[3:12]), 100, 4])
        E0, V0, B0, B0_prime = params
        B0_GPa = B0 * 160.217  # Convert from eV/Å³ to GPa
        eos_params[label] = (E0 * num_atoms, V0, B0_GPa, B0_prime)  # Convert back to total energy for reporting

        # Generate EOS curve
        V_fit = np.linspace(min(df['Volume (Å³/atom)']), max(df['Volume (Å³/atom)']), 100)
        E_fit = birch_murnaghan(V_fit, *params) * num_atoms  # Convert back to total energy

        # Plot original data (shifted by E_min for clarity)
        plt.scatter(df['Lattice Parameter (Å)'], df['Energy (eV)'] * num_atoms - E_min_values[label] * num_atoms, 
                    marker=markers[label], color=colors[label], label=f"{label} (B₀={B0_GPa:.2f} GPa)", 
                    s=50, edgecolors='black', linewidth=0.8)
        
        # Plot EOS fit as a dashed curve
        plt.plot(V_fit ** (1/3) * (4 ** (1/3)), E_fit - E_min_values[label] * num_atoms, 
                 linestyle="--", linewidth=2, color=colors[label], alpha=0.8)

        print(f"{label}: Bulk Modulus = {B0_GPa:.2f} GPa, Equilibrium Volume = {V0:.3f} Å³/atom")

    except RuntimeError:
        print(f"Warning: EOS fitting failed for {label}")

# Add symbolic EOS equation within the plot
eos_equation = r"$E(V) = E_{\min} + \frac{9}{16} B_0 V_0 [(η - 1)^3 B_0' + (η - 1)^2 (6 - 4η)]$"
plt.text(0.1, 0.85, eos_equation, transform=plt.gca().transAxes, fontsize=14, fontweight="bold", bbox=dict(facecolor='white', edgecolor='black'))

# Customize the plot
#plt.title('Equation of State', fontsize=20, fontweight='bold')
plt.xlabel(r'$Lattice$ $Parameter$ $(Å)$', fontsize=25, fontweight='bold')
plt.ylabel(r'$E - E_{\min}$ $(eV)$', fontsize=25, fontweight='bold')
plt.legend()
#plt.grid(True, linestyle='--', alpha=0.6, linewidth=0.5)
plt.tight_layout()

# Save the plot
output_file_path = 'eos_plot.png'
plt.savefig(output_file_path, dpi=400)
plt.show()

print(f"Comparative EOS plot has been saved to {output_file_path}")
