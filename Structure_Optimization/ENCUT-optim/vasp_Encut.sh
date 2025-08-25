#!/bin/sh
#SBATCH -A nsmapplications
#SBATCH -N 3
#SBATCH --ntasks-per-node=40
#SBATCH --job-name=vasp_Mo
#SBATCH --error=job.%J.err_node_40
#SBATCH --output=job.%J.out_node_40
#SBATCH --time=4-00:00:00
#SBATCH --partition=cpu

module purge
module load ohpc
module load hdf5/1.10.0-patch1/intel
module load intel/2020.2.254
module list
export OMP_NUM_THREADS=1


for i in `seq -w 250 50 550` 
do

cat >INCAR<<EOF

Global Parameters
ISTART =  1            (Read existing wavefunction, if there)
ISPIN  =  1            (Non-Spin polarised DFT)
# ICHARG =  11         (Non-self-consistent: GGA/LDA band structures)
LREAL  = .FALSE.       (Projection operators: automatic)
ENCUT  =  $i eV        (Cut-off energy for plane wave basis set, in eV)
# PREC   =  Accurate   (Precision level: Normal or Accurate, set Accurate when perform structure lattice relaxation calculation)
LWAVE  = .TRUE.        (Write WAVECAR or not)
LCHARG = .TRUE.        (Write CHGCAR or not)
ADDGRID= .TRUE.        (Increase grid, helps GGA convergence)
# LVTOT  = .TRUE.      (Write total electrostatic potential into LOCPOT or not)
# LVHAR  = .TRUE.      (Write ionic + Hartree electrostatic potential into LOCPOT or not)
# NELECT =             (No. of electrons: charged cells, be careful)
# LPLANE = .TRUE.      (Real space distribution, supercells)
# NWRITE = 2           (Medium-level output)
# KPAR   = 2           (Divides k-grid into separate groups)
# NGXF    = 300        (FFT grid mesh density for nice charge/potential plots)
# NGYF    = 300        (FFT grid mesh density for nice charge/potential plots)
# NGZF    = 300        (FFT grid mesh density for nice charge/potential plots)
 
Electronic Relaxation
ISMEAR =  1            (Gaussian smearing, metals:1)
SIGMA  =  0.2         (Smearing value in eV, metals:0.2)
NELM   =  90           (Max electronic SCF steps)
NELMIN =  6            (Min electronic SCF steps)
EDIFF  =  1E-08        (SCF energy convergence, in eV)
# GGA  =  PS           (PBEsol exchange-correlation)
 
Ionic Relaxation
NSW    =  0          (Max ionic steps)
IBRION =  -1            (Algorithm: 0-MD, 1-Quasi-New, 2-CG)
ISIF   =  2            (Stress/relaxation: 2-Ions, 3-Shape/Ions/V, 4-Shape/Ions)
#EDIFFG = -2E-02        (Ionic convergence, eV/AA)
#ISYM =  2            (Symmetry: 0=none, 2=GGA, 3=hybrids)
 
EOF

mkdir $i
cp INCAR $i/
cp POSCAR $i/
cp POTCAR $i/
cp KPOINTS $i/
cd $i

mpirun -np 40 /home/rraghav.iitgn/software/vasp.6.3.0/bin/vasp_std
E=`grep 'F' OSZICAR|tail -n 1 | awk '{ print $5}'`;
echo $i $E >>../EC-conv.txt

cd ..

done
