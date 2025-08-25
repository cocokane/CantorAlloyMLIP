


import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.signal import savgol_filter
from scipy.optimize import curve_fit

# Linear function for fitting
def linear(x, m, c):
    return m * x + c

# Function to detect the temperature where the volume jump occurs
def find_jump(temp, volume):
    if len(temp) < 5 or len(volume) < 5:  # Ensure sufficient data for smoothing
        return None, None
    smoothed_vol = savgol_filter(volume, window_length=min(5, len(volume)), polyorder=3)  # Smooth data
    derivative = np.gradient(smoothed_vol)  # Calculate the derivative
    jump_index = np.argmax(np.abs(derivative))  # Find the largest jump
    return temp[jump_index], jump_index

# Function to create publication-quality scatter plot
def plot_results(temp_meam, volume_meam, temp_mtp, volume_mtp, jump_temp_meam, jump_temp_mtp, jump_index_meam, jump_index_mtp):
    plt.figure(figsize=(10, 6))

    # Plot MEAM data if available
    if len(temp_meam) > 0 and len(volume_meam) > 0:
        plt.scatter(temp_meam, volume_meam, label="MEAM", color="red", s=20, alpha=0.8)
        # Fit and plot linear segments for MEAM
        if jump_index_meam is not None:
            if jump_index_meam > 0:
                popt1, _ = curve_fit(linear, temp_meam[:jump_index_meam], volume_meam[:jump_index_meam])
                plt.plot(temp_meam[:jump_index_meam], linear(temp_meam[:jump_index_meam], *popt1), color="black")
            if jump_index_meam < len(temp_meam):
                popt2, _ = curve_fit(linear, temp_meam[jump_index_meam:], volume_meam[jump_index_meam:])
                plt.plot(temp_meam[jump_index_meam:], linear(temp_meam[jump_index_meam:], *popt2), color="black", linestyle="-")
            print(volume_meam[jump_index_meam], volume_meam[jump_index_meam+1])
            plt.axvline(jump_temp_meam, color="black", linestyle="-", label=f"MEAM Melting Point: {jump_temp_meam:.2f} K", ymin=0.65, ymax=0.95)

    # Plot MTP data if available
    if len(temp_mtp) > 0 and len(volume_mtp) > 0:
        plt.scatter(temp_mtp, volume_mtp, label="MTP", color="blue", s=20, alpha=0.8)
        # Fit and plot linear segments for MTP
        if jump_index_mtp is not None:
            if jump_index_mtp > 0:
                popt1, _ = curve_fit(linear, temp_mtp[:jump_index_mtp], volume_mtp[:jump_index_mtp])
                plt.plot(temp_mtp[:jump_index_mtp], linear(temp_mtp[:jump_index_mtp], *popt1), color="black")
            if jump_index_mtp < len(temp_mtp):
                popt2, _ = curve_fit(linear, temp_mtp[jump_index_mtp:], volume_mtp[jump_index_mtp:])
                plt.plot(temp_mtp[jump_index_mtp:], linear(temp_mtp[jump_index_mtp:], *popt2), color="black", linestyle="-")
            plt.axvline(jump_temp_mtp, color="black", linestyle="-", label=f"MTP Melting Point: {jump_temp_mtp:.2f} K", ymin=0.25, ymax=0.55)

    # Plot aesthetics
    plt.xlabel(r"$Temperature (K)$", fontsize=25, fontweight='bold')
    plt.ylabel(r"$Volume (Å³)$", fontsize=25, fontweight='bold')
    #plt.title("Temperature vs Volume for MEAM and MTP", fontsize=20, fontweight='bold')
    plt.legend(fontsize=12)
    #plt.grid(True)
    plt.tight_layout()
    plt.show()

# Load data from Excel file
filename = "VT_curve.xlsx"
df = pd.read_excel(filename)

# Extract data from the file, handling missing or incomplete columns
temp_meam = df["temp_meam"].dropna().values if "temp_meam" in df else np.array([])
volume_meam = df["volume_meam"].dropna().values if "volume_meam" in df else np.array([])
temp_mtp = df["temp_mtp"].dropna().values if "temp_mtp" in df else np.array([])
volume_mtp = df["volume_mtp"].dropna().values if "volume_mtp" in df else np.array([])

# Detect melting points for MEAM and MTP if data is available
jump_temp_meam, jump_index_meam = find_jump(temp_meam, volume_meam) if len(temp_meam) > 0 else (None, None)
jump_temp_mtp, jump_index_mtp = find_jump(temp_mtp, volume_mtp) if len(temp_mtp) > 0 else (None, None)

# Plot the results
plot_results(
    temp_meam, volume_meam, 
    temp_mtp, volume_mtp, 
    jump_temp_meam if jump_temp_meam else 0, 
    jump_temp_mtp if jump_temp_mtp else 0, 
    jump_index_meam if jump_index_meam else 0, 
    jump_index_mtp if jump_index_mtp else 0
)
