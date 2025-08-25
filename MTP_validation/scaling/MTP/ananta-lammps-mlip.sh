#!/bin/bash
#SBATCH --job-name=mlip
#SBATCH -N 1 #Number of nodes
#SBATCH --ntasks-per-node=48  #Number of core per node
#SBATCH --error=job.%J.err  #Name of output file
#SBATCH --output=job.%J.out #Name of error file
#SBATCH --time=1:00:00 #Time take to execute the program
#SBATCH --partition=debug #specifies queue name(standard is the default partition if you does not specify any partition job will be submitted using default partition) other partitions You can specify hm and gpu

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

#!/bin/bash

# Loop over the specified values
#for i in 48 96 144 192; do
  # Create a directory for the current value
 # mkdir -p $i
  
  # Copy the necessary files into the directory
  #cp ./mlip.ini ./lmp.txt ./pot-new.mtp ./$i
  
  # Change into the directory
  #cd ./$i
  
  # Load the required module
  module load mlip/mlip_new
  
  # Update the PATH environment variable
  export PATH=/home/apps/MLIP:$PATH
  
  # Run the simulation with mpirun
  mpirun -np 12 lmp_intel_cpu_intelmpi -log none -in lmp.txt > lammps-log.txt 2>&1
  
  # Return to the parent directory
 # cd ..
#done
#dir=`pwd`

#cp ../../exec/mlip-no-active-learning.ini ./mlip.ini
#cd $dir

#end
