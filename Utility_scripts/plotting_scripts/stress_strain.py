import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import linregress
from sklearn.linear_model import LinearRegression
from matplotlib.ticker import AutoMinorLocator

# Load the Excel file
file_path = "Book2.xlsx"
data = pd.read_excel(file_path)

# Extract data
strain_mtp = data["strain_mtp"]
stress_mtp = data["stress_mtp"]
strain_meam = data["strain_meam"]
stress_meam = data["stress_meam"]

# Linear region: let's consider strain in [0.0015, 0.007] for fitting (approx. linear elastic region)
fit_range_mtp = (data['strain_mtp'] >= 0.0015) & (data['strain_mtp'] <= 0.09)
strain_fit_mtp = data.loc[fit_range_mtp, 'strain_mtp'].values.reshape(-1, 1)
stress_fit_mtp = data.loc[fit_range_mtp, 'stress_mtp'].values

# Fit a linear regression model
model_mtp = LinearRegression()
model_mtp.fit(strain_fit_mtp, stress_fit_mtp)
modulus_mtp = model_mtp.coef_[0]

# Predict values for the fit range
strain_pred_mtp = np.linspace(strain_fit_mtp.min(), strain_fit_mtp.max(), 100).reshape(-1, 1)
stress_pred_mtp = model_mtp.predict(strain_pred_mtp)

# MEAM model
fit_range_meam = (data['strain_meam'] >= 0.0015) & (data['strain_meam'] <= 0.06)
strain_fit_meam = data.loc[fit_range_meam, 'strain_meam'].values.reshape(-1, 1)
stress_fit_meam = data.loc[fit_range_meam, 'stress_meam'].values

# Fit a linear regression model
model_meam = LinearRegression()
model_meam.fit(strain_fit_meam, stress_fit_meam)
modulus_meam = model_meam.coef_[0]

# Predict values for the fit range
strain_pred_meam = np.linspace(strain_fit_meam.min(), strain_fit_meam.max(), 100).reshape(-1, 1)
stress_pred_meam = model_meam.predict(strain_pred_meam)


# Fit Young's modulus in the linear region (strain ≤ 0.05)
def fit_youngs_modulus(strain, stress):
    mask = strain <= 0.05
    slope, intercept, _, _, _ = linregress(strain[mask], stress[mask])
    return slope, intercept

E_mtp, intercept_mtp = fit_youngs_modulus(strain_mtp, stress_mtp)
E_meam, intercept_meam = fit_youngs_modulus(strain_meam, stress_meam)

print(E_meam, intercept_meam)
# Generate triangle points for visualization
# def get_triangle_points(E, intercept):
#     x_tri = np.array([0, 0.05])
#     y_tri = E * x_tri + intercept
#     return x_tri, y_tri

# x_tri_mtp, y_tri_mtp = get_triangle_points(E_mtp, intercept_mtp)
# x_tri_meam, y_tri_meam = get_triangle_points(E_meam, intercept_meam)

# Create the plot
plt.figure(figsize=(8, 6))
plt.plot(strain_mtp, stress_mtp, label=f"MTP (E = {E_mtp:.2f} GPa)", linewidth=2, color="blue", marker="o", markersize=5)
plt.plot(strain_meam, stress_meam, label=f"MEAM (E = {E_meam:.2f} GPa)", linewidth=2, color="red", marker="s", markersize=5)

# # Plot Young's modulus triangles
# plt.plot(x_tri_mtp, y_tri_mtp, linestyle="--", color="blue")
# plt.plot(x_tri_meam, y_tri_meam, linestyle="--", color="red")

# Customize the plot for publication quality
plt.xlabel(r"$Strain$", fontsize=20)
plt.ylabel(r"$Stress (GPa)$", fontsize=20)
#plt.title("Stress vs. Strain Curve for HEA", fontsize=20, weight="bold")
plt.legend(fontsize=12, loc="upper right", frameon=False)

# Axis ticks and grid
plt.xticks(fontsize=12)
plt.yticks(fontsize=12)
plt.gca().xaxis.set_minor_locator(AutoMinorLocator(5))  # Minor ticks on x-axis
plt.gca().yaxis.set_minor_locator(AutoMinorLocator(5))  # Minor ticks on y-axis

# Save the figure in high resolution for publication
plt.xlim(0, 0.25)
plt.ylim(0, 15)




#plt.plot(data['strain_mtp'], data['stress_mtp'], 'o-', label='MTP Data', color='tab:blue')
plt.plot(strain_pred_mtp, stress_pred_mtp, 'k--', label=f'Linear Fit\nE = {modulus_mtp:.2e} Pa')

# Highlight the triangle for the linear fit range
x0, x1 = strain_fit_mtp.min(), strain_fit_mtp.max()
y0, y1 = model_mtp.predict([[x0]])[0], model_mtp.predict([[x1]])[0]
plt.fill([x0, x1, x1], [0, 0, y1], color='gray', alpha=0.2, label='Fit Region')


plt.plot(strain_pred_meam, stress_pred_meam, 'k--', label=f'Linear Fit\nE = {modulus_mtp:.2e} Pa')

# Highlight the triangle for the linear fit range
x0, x1 = strain_fit_meam.min(), strain_fit_meam.max()
y0, y1 = model_meam.predict([[x0]])[0], model_meam.predict([[x1]])[0]
plt.fill([x0, x1, x1], [0, 0, y1], color='gray', alpha=0.4, label='Fit Region')

# Display the plot
plt.show()

plt.tight_layout()
# plt.savefig("stress_vs_strain_hea.png", dpi=300, bbox_inches="tight")
# plt.savefig("stress_vs_strain_hea.pdf", dpi=300, bbox_inches="tight")

