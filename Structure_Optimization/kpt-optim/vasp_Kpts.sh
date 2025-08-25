#!/bin/sh
#SBATCH -A nsmapplications
#SBATCH -N 8
#SBATCH --ntasks-per-node=40
#SBATCH --job-name=5_HEA
#SBATCH --error=job.%J.err_node_40
#SBATCH --output=job.%J.out_node_40
#SBATCH --time=72:00:00
#SBATCH --partition=cpu

module purge
module load ohpc
module load hdf5/1.10.0-patch1/intel
module load intel/2020.2.254
module list
export OMP_NUM_THREADS=1


mpirun -np 40 /home/rraghav.iitgn/software/vasp.6.3.0/bin/vasp_std
E=`grep 'F' OSZICAR|tail -n 1 | awk '{ print $5}'`;
echo $i $E >>../kconv.txt




