#!/bin/bash
#SBATCH --job-name=lammps-ananta         # Job name
#SBATCH -N 1 #Number of nodes
#SBATCH --ntasks-per-node=48  #Number of core per node
#SBATCH --error=job.%J.err  #Name of output file
#SBATCH --output=job.%J.out #Name of error file
#SBATCH --time=24:00:00 #Time take to execute the program
#SBATCH --partition=small #specifies queue name(standard is the default partition if you does not specify any partition job will be submitted using default partition) other partitions You can specify hm and gpu

module load spack
module laod intel/2018_4

source /home/apps/spack/share/spack/setup-env.sh


#LAMMPS module
spack load lammps@20220623%gcc@12.2.0 /soj4w5b
spack load gcc/bwq7xaa

MACHINEFILE=machinefile
	
scontrol show hostname $SLURM_JOB_NODELIST > $MACHINEFILE
mpirun -np 48 -machinefile $MACHINEFILE lmp < lmp_HEA_mtp_sol2liq.txt
#mpirun -np 48 lmp -machinefile $MACHINEFILE -v myseed 12345 -v tempstart 300 -v tempstop 300 -v latparam 3.518 -v size 3 -in stk_flt.txt > lammps-log.txt 2>&1
	

	

