#!/bin/bash
#SBATCH --job-name=mlip         # Job name
#SBATCH -N 10 #Number of nodes
#SBATCH --ntasks-per-node=48  #Number of core per node
#SBATCH --error=job.%J.err  #Name of output file
#SBATCH --output=job.%J.out #Name of error file
#SBATCH --time=24:00:00 #Time take to execute the program
#SBATCH --partition=medium #specifies queue name(standard is the default partition if you does not specify any partition job will be submitted using default partition) other partitions You can specify hm and gpu


module load spack
source /home/apps/spack/share/spack/setup-env.sh

spack load lammps@20220623 /il5m4bh
module load mlip

cd ./

# Local train:
mpirun -np 48 mlp train 08.mtp train.cfg --trained-pot-name=pot.mtp --valid-cfgs=test.cfg 

echo training and validation done!
