# CantorAlloyMLIP  
*Training and Validation Guide for a Moment-Tensor Potential (MTP) of the Cantor (CoCrFeMnNi) High-Entropy Alloy*

---

## Purpose

This document serves as the **official training guide** for the MTP developed for the equiatomic CoCrFeMnNi alloy. It is written to (i) enable full reproduction of our workflow and (ii) act as a reference for training **your own** MLIP with active learning. Each step specifies what it accomplishes, why it is required, and the principal caveats that affect scientific outcomes.

---

## Prerequisites

- **LAMMPS** built with the **MLIP/MTP** interface and **MEAM** (for baselines).  
  *Use a consistent pair style name for your build (e.g., `pair_style mlip` vs `mlip/mlp`).*
- **MLIP/MTP package** for training, minimum-distance calculation, and extrapolation grade (Γ) evaluation.
- **Python 3.9+** with `numpy`, `pandas`, `matplotlib`, `seaborn` (post-processing and plotting).
- (**Optional / for DFT labels**) **VASP (PBE/PAW)**. *POTCARs are not distributed and must be generated under your license.*

---

## Getting Started: High-Quality Training Steps

> **Orientation.** The workflow is split into: data → seed model → active learning → validation.

---

### Step 1 — Dataset design and generation (DFT/AIMD)

- **Goal.** Provide diverse, label-accurate local environments representative of the Cantor alloy across temperatures and defect classes.
- **System choices.** We use (i) **108-atom SQS cells** for training/validation (efficient DFT labels) and (ii) larger boxes (e.g., **18×18×18 FCC**, 23,328 atoms) for downstream MD validations.
- **DFT protocol (for labels).** Single-point or short AIMD with PBE/PAW, 500 eV cutoff, 15×15×15 k-mesh for the primitive cell; Methfessel–Paxton σ=0.2 eV. Convert OUTCAR → `.cfg` using the provided converter.
- **Element order.** Adopt a **canonical ordering** `Co–Cr–Fe–Mn–Ni` across POSCAR/conf/CFG. Reorder inputs if necessary before training or inference.

**Composition of the present dataset** (training/test splits by category):

``` latex
\begin{tabular}{|l|c|c|c|c|S[table-format=1.2]|}
        \toprule
        \hline
        \textbf{Category} & \textbf{Temperature} & \textbf{Training} & \textbf{Test} & \textbf{Total} \\
        \midrule
        \hline
        Defect-free   & 300\,K & 36 & 6  & 42 \\
        Defect-free   & 600\,K & 36 & 6  & 42 \\
        Defect-free   & 900\,K & 36 & 6  & 42 \\
        \midrule
        Dislocation     & 300\,K & 36 & 6  & 42 \\
        Stacking Fault  & 300\,K & 20 & 10 & 30 \\
        Vacancy         & 300\,K & 36 & 6  & 42 \\
        \midrule
        \hline
        \textbf{Total}  & --     & 200 & 40 & 240 \\
        \bottomrule
        \hline
```
- **Rationale.** The temperature ladder (300/600/900 K) and defect coverage (dislocation, stacking fault, vacancy) encourage **transferability**; splits are held fixed for objective validation.
#### Minimum-distance sanity check (run before training and after any dataset change)

- **Goal.** Detect unphysical interatomic overlaps anywhere in the training/validation sets that cause divergent forces or unstable training/MD.  
- **Method.** Use the MLIP package’s *mindist* mode to scan the `.cfg` files and report the global minimum interatomic distance.  
- **Interpretation.** Values far below typical metallic nearest-neighbour distances indicate malformed structures; curate or regenerate those frames.  
- **Caveat.** Perform this check again after every active-learning augmentation.


---

### Step 2 — Structure optimization (DFT reference baseline)
**Relevant files:** `Structure_Optimization/`
- **Goal.** Establish consistent reference parameters (ENCUT, k-mesh, lattice constant) for label generation and EOS comparisons.
- **Procedure.**  
  1) **ENCUT sweep** → choose a plateauing energy;  
  2) **k-point density sweep** at fixed ENCUT;  
  3) **lattice-constant scan** and **Birch–Murnaghan** fit to obtain \(a_0\) and \(B_0\).  
- **Caveat.** Keep smearing, cutoff, and PAW datasets constant across the sweep;
---

### Step 3 — Label extraction and format unification
**Relevant files:** `utility_scripts/summ2cfg.py`, `utility_scripts/extract_data_dft.py`
- **Goal.** Produce consistent `.cfg` files with **E**, **F**, **σ** (when available), lattice, species, and **canonical element order**.
- **Method.** Convert VASP outputs (OUTCAR) to `.cfg`; verify units; verify that **energy per atom** vs **per cell** is documented; keep hashes to avoid duplicate frames.
- **Sanity.** Re-run **Step 0** (mindist) after assembling the final train/test lists.

---

### Step 4 — Seed MTP configuration
**Relevant files:** `MTP_training/step2_train_validate/`
- **Goal.** Define descriptors and training hyperparameters that produce a *stable* initial potential.
- **Key choices.**  
  - **Descriptor order / radial basis size** (e.g., `mtp8-rb10` proved stable; `mtp8-rb8` and `mtp16-rb8` were not MD-stable).  
  - **Training config** (`mlip.ini`): mode = training; loss weights for E/F/σ; regularization; early stopping criteria.
- **Caveat.** Higher order does **not** guarantee stability; prioritize robustness over nominal expressivity at this stage.

---

### Step 5 — Initial supervised training and validation
**Relevant files:** `MTP_training/step2_train_validate/`
- **Goal.** Train on `train.cfg`, evaluate on `test.cfg`, and obtain a usable `pot.mtp` for MD.
- **What to monitor.** Convergence of E/F/σ MAEs; smoothness of validation curves; absence of pathological outliers (often indicative of mislabeled frames or ordering errors).
- **Outcome.** A **seed** MTP that can run short NVT/NPT without breakdown.

---

### Step 6 — Active learning (Round 1: single trajectory stress test)
**Relevant files:** `MTP_training/step3_activelearning/activelearning_step_1.sh`
- **Goal.** Expose the seed model to new states and collect **only** high-value labels using **extrapolation grade Γ**.
- **Protocol.**  
  1) Run an **NPT** trajectory at representative T and P;  
  2) Compute Γ for each frame;  
  3) **Select frames with Γ above threshold** for DFT relabeling;  
  4) Retrain and iterate until breakdowns cease and Γ-flagging rate decreases.  
- **Γ thresholds.** Start from literature-typical values and tune so you neither label everything nor miss failures.

---

### Step 7 — Active learning (Round 2: multi-trajectory coverage)
**Relevant files:** `MTP_training/step3_activelearning/activelearning_step_2_multi_traj.sh`
- **Goal.** Expand diversity across **temperatures, lattice constants, and defect states**; improve transferability for downstream tasks.
- **Protocol.** Run multiple NVT/NPT trajectories spanning the targeted state space; keep the same Γ-based selection and retraining loop; version the dataset after each augmentation.

---

### Step 8 — Freeze, version, and document the model
**Relevant files:** `Trained_MTP_models/`
- **Goal.** Finalize a production potential and make its provenance auditable.
- **Actions.**  
  - Freeze the best model (e.g., **`mtp8-rb10`**) as the **production** potential.  
  - Record dataset version(s), Γ thresholds, training curves, and known limitations in a short **model card**.  
  - Tag the model with a semantic version (e.g., `v1.0.0_mtp8-rb10_Γ0.6-1.0`).

---

### Step 9 — Physical validation (compared with MEAM in our workflow)
**Relevant files:** `MTP_validation/`
- **Uniaxial tension (σ–ε).** 18×18×18 FCC (23,328 atoms), 300 K, timestep 1 fs; apply `fix deform` along X at \(1\times10^{-4}\,\text{ps}^{-1}\); lateral NPT on Y/Z (thermostat 0.1 ps; barostat 1 ps).  
  **Reporting:** \(\sigma_{ii} = -p_{ii}/10{,}000\) (GPa); print stress every 5 ps; dump every 10 ps.
- **Melting (heating/cooling).** 6×6×6 FCC (864 atoms); NPT 300→2000 K over 3 ns, then 2000→300 K over 3 ns at 1.013 bar; observe volume inflection and enthalpy plateau.
- **Nanoindentation.** PBC X/Y, free Z; bottom 30 Å slab fixed; mobile atoms at 300 K (NVT). Rigid spherical indenter **R = 30 Å** with harmonic repulsion **k = 16 eV Å⁻³**; load–unload 400 ps (max depth 20 Å; ≈10 m/s).  
  *Use for comparative trends; absolute hardness depends on `k` and rate.*
- **EOS (E–V) & BM fit.** 4-atom FCC, DFT single-points over a₀ = 3.30–3.70 Å; PBE/PAW, 500 eV, 15×15×15; Methfessel–Paxton σ=0.2 eV; fit **third-order Birch–Murnaghan** to obtain \(a_0, V_0, B_0\).
- **NVT/NPT stability and scaling.** Demonstrate robustness across thermodynamic conditions and quantify speedup vs MEAM/DFT.  
  *Record node type, MPI ranks/threads, pinning, and storage path; small boxes can be latency-dominated.*

---

## Conventions and critical caveats

- **Stress sign & units.** We report **GPa** with \(\sigma_{ii} = -p_{ii}/10{,}000\). Keep this convention consistent across scripts and figures.
- **Thermostat/barostat damping.** 0.1 ps / 1 ps across MD; inappropriate damping can distort responses under high strain-rate.
- **High-rate protocols.** Tension and indentation use elevated rates for tractability; treat absolute values as computational proxies and compare **relative** trends.
- **Element ordering.** Enforce `Co–Cr–Fe–Mn–Ni` everywhere; reorder inputs proactively to avoid silent species swaps.
- **Data versioning.** Append active-learning data into a *new* dataset version; never overwrite prior labels.

---

## Post-Processing and Plotting

- The Python scripts under `utility_scripts/` (extractors and plotters) are **intended as templates** and are **meant to be modified as per your requirements**—filenames, units, columns, smoothing, and styling can differ across systems and clusters.
- Typical flow: run calculation → parse with `extract_data_lammps_log.py` (LAMMPS) and/or `extract_data_dft.py` + `summ2cfg.py` (DFT) → generate figures via `plotting_scripts/*.py`.

---

## Scope & Limitations

The inputs and defaults target metallic bonding in the equiatomic CoCrFeMnNi alloy. Extending to other chemistries or bonding types may require revisiting descriptor choices, the state-space spanned by the dataset, and Γ thresholds during active learning.

---

## Citations

**Primary manuscript**

**_Machine Learning Interatomic Potentials for High Entropy Alloys_**  
Manish Sahoo¹, Yash Kokane², Jayaprakash³, Akash Deshmukh⁴, Raghavan Ranganathan²,*  
¹ Department of Advanced Materials Science, GSFS, University of Tokyo, Kashiwa, Japan  
² Department of Materials Engineering, Indian Institute of Technology Gandhinagar, Gujarat, 382355, India  
³ Regional Institute of Education, Manasagangothri, Mysuru, Karnataka, India  
⁴ Herbert Gleiter International Institute, Liaoning Academy of Materials, Shenyang-110167, China  
*Corresponding author:* rraghav@iitgn.ac.in

**Core software (cite as applicable)**  
- Plimpton, S. *J. Comput. Phys.* **1995**, 117, 1–19. (LAMMPS)  
- VASP references (Kresse & Furthmüller; PAW; PBE) if you regenerate DFT labels.  
- The MLIP/MTP framework you use to train and evaluate the potential.

