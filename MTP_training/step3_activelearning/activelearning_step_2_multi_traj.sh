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

echo ALCYCLE-MULTI: Iteration $curr begin

prev=$(( $curr-1 ))
prev=`printf "%02d" $prev`
curr=`printf "%02d" $curr`

mkdir $curr

#
# Step A
# Input:$prev/pot.mtp, $prev/train.cfg
# Output:$curr/A-state.als
#

echo ALCYCLE-MULTI: Iteration $curr, Step A: calc-grade
mpirun -np 1 mlp calc-grade $prev/pot.mtp $prev/train.cfg $prev/train.cfg $curr/temp.cfg --als-filename=$curr/A-state.als
rm $curr/temp.cfg
cp $prev/pot.mtp $curr/pot.mtp

# Step B
echo ALCYCLE-MULTI: Iteration $curr, Step B: LAMMPS
cp exec/mlip*.ini $curr/
cd $dir/$curr

# parallel LAMMPS, EDIT FOR YOUR OWN QUEUE SYSTEM
for script in fcc_liquid fcc_solid; do
for a in 3.41 3.46 3.56 3.61; do
for T in 500 1000 1500 2000; do
  mkdir B-lammps_${script}_${T}_${a}
  cd B-lammps_${script}_${T}_${a}
  cp ../mlip-early-break.ini ./mlip.ini; cp ../pot.mtp .; cp ../A-state.als .
  #mpirun -np 1 lmp_mpi -v SEED 1 -v T $T -v latparam $a -v size 3 -log none -in $dir/exec/${script}.in >lammps-log.txt 2>&1
  mpirun -np 1  lmp_intel_cpu_intelmpi -v myseed 12345 -v tempstart $T -v tempstop $T -v latparam $a -v size 3 -log none -in $dir/exec/${script}.txt >B-lammps-log.txt 2>&1
  cd $dir/$curr
done; done; done

# combining preselected configurations
cat B-lammps*/B-preselected.cfg >>B-preselected.cfg
cd $dir

# Step C
echo ALCYCLE-MULTI: Iteration $curr, Step C: select
mpirun -np 1 mlp select-add $prev/pot.mtp $prev/train.cfg $curr/B-preselected.cfg $curr/C-selected.cfg
rm selected.cfg state.als # remove files created by select-add

#
# Step D: DFT
# Input: $curr/C-selected.cfg
# Output: $curr/D-computed.cfg
#

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
  export omp_num_threads=1
  ulimit -s unlimited
  mpirun -np 48 vasp_std #92/144 doesn't work
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

# Step E and F: merge and train
echo ALCYCLE-MULTI: Iteration $curr, Step E and F: merge and train
cat $prev/train.cfg $curr/D-computed.cfg >>$curr/train.cfg
cp $curr/train.cfg $curr/E-train.cfg

# Local train:
# exec/mlp train $curr/pot.mtp $curr/train.cfg --trained-pot-name=$curr/pot.mtp --curr-pot-name= --max-iter=500
# Cluster train:

cp $curr/pot.mtp train/
cp $curr/train.cfg train/
cd train

mpirun -np 1 mlp train pot.mtp train.cfg --trained-pot-name=pot.mtp >train-output.txt

jobs_left=`squeue -np $1 | grep -v JOBID | wc -l`;
wait_time=1
while( (( $jobs_left > 0 )) ); do
echo Jobs left: $jobs_left
sleep $wait_time
if [ $wait_time -lt 10 ]; then wait_time=$(( $wait_time+1 )); fi
jobs_left=`squeue -np $1 | grep -v JOBID | wc -l`;
done 

cd ..

cd $dir

cp train/pot.mtp $curr/

grep -v "DAT Registry" train/train-output.txt > $curr/E-train-output.txt

cp $curr/pot.mtp $curr/E-pot.mtp

echo ALCYCLE-MULTI: Iteration $curr end