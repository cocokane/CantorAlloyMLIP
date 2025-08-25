#!/bin/bash
#SBATCH --job-name=mlip
#SBATCH -N 4 #Number of nodes
#SBATCH --ntasks-per-node=48  #Number of core per node
#SBATCH --error=job.%J.err  #Name of output file
#SBATCH --output=job.%J.out #Name of error file
#SBATCH --time=72:00:00 #Time take to execute the program
#SBATCH --partition=small #specifies queue name(standard is the default partition if you does not specify any partition job will be submitted using default partition) other partitions You can specify hm and gpu

#module load spack
#source /home/apps/spack/share/spack/setup-env.sh


#MLIP module
#module load mlip/mlip_new

#LAMMPS module
#spack load lammps@20220623%gcc@12.2.0 /soj4w5b
#spack load gcc/bwq7xaa
#spack load openmpi/7cvclvr

#MLIP_LAMMPS interface
#module load DL/conda-python/3.7
#module load intel/2018_4
#spack load lammps@20220623/il5m4bh
#export PATH=/home/apps/MLIP:$PATH

#VASP module
#module load spack
#source /home/apps/spack/share/spack/setup-env.sh
#source ./script.sh

#spack load intel-oneapi-compilers@2022.1.0
#spack load intel-oneapi-tbb/u2peahx
#spack load intel-oneapi-mkl/5j2ryvm
#spack load intel-oneapi-mpi@2021.6.0
#spack load fftw@3.3.10/46ojwso
#module load gcc/10.2

#module load spack /home/a.deshmukh/apps_AD/Packages/vasp.6.3.0   #(vasp compile directory cpu version)

cd ./

#dir=`pwd`

#cp ../../exec/mlip-no-active-learning.ini ./mlip.ini
module load mlip/mlip_new
export PATH=/home/apps/MLIP:$PATH
mpirun -np 192 lmp_intel_cpu_intelmpi -log none -in lmp_HEA_mtp_sol2liq.txt >lammps-log.txt 2>&1
#cd $dir

#end
