#!/bin/bash
#SBATCH --job-name=cal_dis        # Job name
#SBATCH --ntasks-per-node=48    # Number of MPI tasks (i.e. processes)
#SBATCH --output=myjob.%J.out
#SBATCH --error=myjob.%J.err
#SBATCH --partition=debug
#SBATCH -v

module load spack
source /home/apps/spack/share/spack/setup-env.sh

spack load lammps@20220623 /il5m4bh
module load mlip

cd ./

echo Training set mindist_train:
mpirun -np 1 mlp mindist train.cfg

echo Training set mindist_test
mpirun -np 1 mlp mindist test.cfg
