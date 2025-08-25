import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit


# Define a polynomial fit function
def polynomial_fit(x, a, b, c):
    return a * x**b +  c

# Helper function to convert system sizes to numeric values
def system_size_to_numeric(size):
    dims = [int(x) for x in size.split("x")]
    return np.prod(dims)

# Updated plotting function
def plot_inverted_weak_scaling_poly(data, job_type, output_filename):
    plt.figure(figsize=(10, 7))
    
    # Filter data for the job type
    for potential in data["potential"].unique():
        subset = data[data["potential"] == potential]
        system_sizes = subset["system_size_numeric"].values
        inverted_system_sizes = 1 / system_sizes  # Use 1/System Size for the x-axis
        time_sim = subset[f"time_sim/day({job_type})"].values

        # Perform a polynomial fit
        popt, _ = curve_fit(polynomial_fit, inverted_system_sizes, time_sim)

        # Generate fit line
        fit_x = np.linspace(min(inverted_system_sizes), max(inverted_system_sizes), 100)
        fit_y = polynomial_fit(fit_x, *popt)

        # Plot data points
        if potential == "mtp":
            color = "blue"
        else:  # "meam"
            color = "red"
        plt.scatter(inverted_system_sizes, time_sim, label=f"{potential.upper()} (Data)", color=color)
        plt.plot(fit_x, fit_y, label=f"{potential.upper()} Fit: $y={popt[0]:.2f}x^{popt[1]:.2f} + {popt[2]:.2f}$", color="black", linestyle="--")

    # Customize plot
    plt.xlabel(r"$1/System Size$", fontsize=20)
    plt.ylabel(r"$Time$ $Simulated/Day(ns)$", fontsize=20)
    plt.title(f"Weak Scaling {job_type} ", fontsize=20, fontweight='bold')
    plt.legend(fontsize=12)
    #plt.grid(True)
    plt.tight_layout()

    # Save plot
    plt.savefig(output_filename, dpi=300)
    plt.close()

# Main script
data = pd.read_excel("weak_scaling.xlsx")

# Convert system size to numerical values for plotting
data["system_size_numeric"] = data["system_size"].apply(system_size_to_numeric)

# Generate high-quality plots
plot_inverted_weak_scaling_poly(data, "NPT", "weak_scaling_NPT_poly.png")
plot_inverted_weak_scaling_poly(data, "uni. Stress", "weak_scaling_uni_stress_poly.png")
