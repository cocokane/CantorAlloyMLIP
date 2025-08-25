#!/bin/bash
#SBATCH --job-name=mlip         # Job name
#SBATCH -N 4 #Number of nodes
#SBATCH --ntasks-per-node=48  #Number of core per node
#SBATCH --error=job.%J.err  #Name of output file
#SBATCH --output=job.%J.out #Name of error file
#SBATCH --time=72:00:00 #Time take to execute the program
#SBATCH --partition=small #specifies queue name(standard is the default partition if you does not specify any partition job will be submitted using default partition) other partitions You can specify hm and gpu

module load spack
source /home/apps/spack/share/spack/setup-env.sh

#MLIP module
module load mlip

#LAMMPS module
#spack load lammps@20220623%gcc@12.2.0 /soj4w5b
#spack load gcc/bwq7xaa
#spack load openmpi/7cvclvr

#MLIP_LAMMPS interface
module load DL/conda-python/3.7
module load intel/2018_4
spack load lammps@20220623/il5m4bh
export PATH=$PATH:/home/a.deshmukh/MLIP/interface-lammps-mlip-2

#VASP module
module load spack
source /home/apps/spack/share/spack/setup-env.sh
source /script.sh

spack load intel-oneapi-compilers@2022.1.0
spack load intel-oneapi-tbb / u2peahx
spack load intel-oneapi-mkl / 5j2ryvm
spack load intel-oneapi-mpi@2021.6.0
spack load fftw@3.3.10 / 46ojwso
module load gcc/10.2

#module load spack /home/a.deshmukh/apps_AD/Packages/vasp.6.3.0   #(vasp compile directory cpu version)

cd ./

dir=`pwd`

if [ -z "$1" ]; then
    echo "First argument should be the current interation number (starting from 1)"
    curr=`ls | grep -e "^[0-9]*\$" | wc -l`
else
    curr=$1
fi

echo ALCYCLE: Iteration $curr begin

prev=$(( $curr-1 ))
prev=`printf "%02d" $prev`
curr=`printf "%02d" $curr`

mkdir $curr

#
# Step A
# Input:$prev/pot.mtp, $prev/train.cfg
# Output:$curr/A-state.als
#

echo ALCYCLE: Iteration $curr, Step A: calc-grade
mpirun -np 1 mlp calc-grade $prev/pot.mtp $prev/train.cfg $prev/train.cfg $curr/temp.cfg --als-filename=$curr/A-state.als
rm $curr/temp.cfg
cp $prev/pot.mtp $curr/pot.mtp

#
# Step B
# Input: $prev/pot.mtp $curr/A-state.als,
# Output: $curr/B-preselected.cfg
#

echo ALCYCLE: Iteration $curr, Step B: LAMMPS
cp exec/mlip.ini $curr/
cd $curr
mpirun -np 1 lmp_intel_cpu_intelmpi -v myseed 12345 -v tempstart 300 -v tempstop 300 -v latparam 3.518 -v size 3 -log none -in $dir/exec/fcc_solid.txt >B-lammps-log.txt 2>&1
cd $dir

#
# Step C
# Input: $prev/pot.mtp, $prev/train.cfg, $curr/B-preselected.cfg
# Output: $curr/C-selected.cfg
#

echo ALCYCLE: 	Iteration $curr, Step C: select 
mpirun -np 1 mlp select-add $prev/pot.mtp $prev/train.cfg $curr/B-preselected.cfg $curr/C-selected.cfg
rm selected.cfg state.als # remove files created by select-add

#
# Step D: DFT
# Input: $curr/C-selected.cfg
# Output: $curr/D-computed.cfg

echo ALCYCLE: Iteration $curr, Step D: DFT
rm vasp/in.cfg
cp $curr/C-selected.cfg vasp/in.cfg

#------------------------------dft_launch_begin----------------------------------------

cd vasp
rm -r dir_POSCAR*
rm POSCAR*

mpirun -np 1 mlp convert-cfg in.cfg POSCAR --output-format=vasp-poscar

for f in POSCAR*; do
  mkdir dir_$f;
  cp sample_in/* dir_$f/
  cp $f dir_$f/POSCAR
  cd dir_$f
  #export I_MPI_FABRICS=shm:ofi
  #ulimit -s unlimited
  #export OMP_NUM_THREADS=1
  #mpirun -np 1 /home/a.deshmukh/apps_AD/Packages/vasp.6.3.0/bin/vasp_std
  export omp_num_threads=1
  ulimit -s unlimited
  mpirun -np 48 vasp_std
  cd $dir/vasp
done
cd $dir

#------------------------------dft_launch_ends----------------------------------------

#------------------------------dft_collect_begin--------------------------------------

cd vasp
rm out.cfg
for f in POSCAR*; do
mpirun -np 1 mlp convert-cfg dir_$f/OUTCAR out.cfg --input-format=vasp-outcar --append
done
mpirun -np 1 mlp filter-nonconv out.cfg
cd $dir
cp vasp/out.cfg $curr/D-computed.cfg

#------------------------------dft_collect_ends----------------------------------------

#
# Step E and F: merge and train
# Input: $prev/pot.mtp, $prev/train.cfg, $curr/D-computed.cfg
# Output: $curr/pot.mtp, $curr/train.cfg, 
#
echo ALCYCLE: Iteration $curr, Step E and F: merge and train
cat $prev/train.cfg $curr/D-computed.cfg >>$curr/train.cfg
cp $curr/train.cfg $curr/E-train.cfg

# Local train:
mpirun -np 1 mlp train $curr/pot.mtp $curr/train.cfg --trained-pot-name=$curr/pot.mtp

cp $curr/pot.mtp $curr/E-pot.mtp
echo ALCYCLE: Iteration $curr end