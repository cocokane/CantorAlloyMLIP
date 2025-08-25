#!/bin/bash
#SBATCH --job-name=lammps-ananta         # Job name


for d in 300 600 900
do
cd ./$d
for f in $(ls .)
do
touch tmp
awk 'NR==1, NR==12 {print}' $f >> tmp
awk 'NR==13, NR==13 {print "4", $2}' $f >> tmp
awk 'NR==14, NR==14 {print "5", $2}' $f >> tmp
awk 'NR==15, NR==15 {print "1", $2}' $f >> tmp
awk 'NR==16, NR==16 {print "3", $2}' $f >> tmp
awk 'NR==17, NR==17 {print "2", $2}' $f >> tmp
awk 'NR==18, NR==20 {print}' $f >> tmp
awk 'NR==21, NR==41 {print $1, "4", $3, $4. $5}' $f >> tmp
awk 'NR==42, NR==63 {print $1, "5", $3, $4, $5}' $f >> tmp
awk 'NR==64, NR==85 {print $1, "1", $3, $4, $5}' $f >> tmp
awk 'NR==86, NR==107 {print $1, "3", $3, $4, $5}' $f >> tmp 
awk 'NR==108, NR==128 {print $1, "2", $3, $4, $5}' $f >> tmp && mv tmp $f
done 
cd ..
done

