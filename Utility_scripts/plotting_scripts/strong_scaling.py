import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit

# Define the modified Amdahl's Law function
def modified_amdahl(P, C, f):
    return C * ((1 - f) + f / P)

# Function to create strong scaling plots
def plot_scaling(data, job_type, save_name):
    # Set publication-quality settings
    plt.rcParams.update({
        "font.size": 12,
        "font.family": "serif",
        "axes.labelsize": 16,
        "axes.titlesize": 18,
        "xtick.labelsize": 14,
        "ytick.labelsize": 14,
        "legend.fontsize": 12,
        "figure.figsize": (8, 6),
        #"axes.grid": True,
        "grid.alpha": 0.6,
        "lines.linewidth": 2
    })

    fig, ax = plt.subplots()

    colors = {"mtp": "blue", "meam": "red"}  # Define colors for potentials

    for potential in data["potential"].unique():
        subset = data[data["potential"] == potential]
        n_procs = subset["n_procs"].values
        #time_sim_npt = subset[f"time_sim_npt"].values
        time_sim_str = subset[f"time_sim_str"].values

        # Scatter plot
        ax.scatter(
            n_procs,
            time_sim_str,
            label=f"{potential.upper()}",
            s=80,
            alpha=0.9,
            edgecolor="black",
            color=colors[potential]
        )

        popt, pcov = curve_fit(modified_amdahl, n_procs, time_sim_str)
        C_fit, f_fit = popt

        # Generate fitted values
        P_fit = np.linspace(min(n_procs), max(n_procs), 100)
        T_fit = modified_amdahl(P_fit, C_fit, f_fit)
        # Plot the fit
        ax.plot(
                P_fit,
                T_fit,
                linestyle="--",
                color="black",
                label=f"Fit: $y = {C_fit:.2f} \\cdot (1 - {f_fit:.2f} + \\frac{{{f_fit:.2f}}}{{x}})$"
                )

    # Add labels, title, and legend
    ax.set_xlabel(r"$Number$ $of$ $Processors$", fontsize=20)
    ax.set_ylabel(r"$Time$ $for$ $simulation$ $(s)$", fontsize=20)
    #ax.set_title(f"Ahmdahl Strong Scaling {job_type}", fontsize=20, fontweight='bold')
    ax.legend(frameon=True, shadow=True)

    # Fine-tune the grid
    #ax.grid(color="gray", linestyle="--", linewidth=0.5)
    ax.set_axisbelow(True)

    # Save the plot in high resolution
    plt.tight_layout()
    plt.savefig(save_name, dpi=300, bbox_inches="tight")
    plt.show()

# Load data from the Excel file
data = pd.read_excel("strong_scaling.xlsx")

# Generate high-quality plots
plot_scaling(data, "NPT", "strong_scaling_NPT.png")
#plot_scaling(data, "uni stress", "strong_scaling_uni_stress.png")
