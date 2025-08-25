#!/bin/bash
#SBATCH --job-name=lammps-ananta         # Job name
#SBATCH -N 1 #Number of nodes
#SBATCH --ntasks-per-node=48  #Number of core per node
#SBATCH --error=job.%J.err  #Name of output file
#SBATCH --output=job.%J.out #Name of error file
#SBATCH --time=1:00:00 #Time take to execute the program
#SBATCH --partition=debug #specifies queue name(standard is the default partition if you does not specify any partition job will be submitted using default partition) other partitions You can specify hm and gpu

module load spack
module laod intel/2018_4

source /home/apps/spack/share/spack/setup-env.sh


#LAMMPS module
spack load lammps@20220623%gcc@12.2.0 /soj4w5b
spack load gcc/bwq7xaa

MACHINEFILE=machinefile

for a in 3.35 3.40 3.45 3.50 3.55 3.60 3.65
do 
mkdir "$a"
lim=$(echo "$a * 3" | bc)
result=$lim
echo $result
cat >no_def<<EOF
# LAMMPS data file written by OVITO Basic 3.8.5

108 atoms
5 atom types

0.0 $result xlo xhi
0.0 $result ylo yhi
0.0 $result zlo zhi

Masses

1 58.9332  # Co
2 58.6934  # Ni
3 51.9961  # Cr
4 55.845  # Fe
5 54.938049  # Mn

Atoms  # atomic

1 4  $(printf "%.8f" $(echo "$result * 0.002747" | bc))    $(printf "%.8f" $(echo "$result * 0.495020" | bc))    $(printf "%.8f" $(echo "$result * 0.502978" | bc))
2 4  $(printf "%.8f" $(echo "$result * 0.164239" | bc))    $(printf "%.8f" $(echo "$result * 0.837518" | bc))    $(printf "%.8f" $(echo "$result * 0.672218" | bc))
3 4  $(printf "%.8f" $(echo "$result * 0.335245" | bc))    $(printf "%.8f" $(echo "$result * 0.837132" | bc))    $(printf "%.8f" $(echo "$result * 0.496839" | bc))
4 4  $(printf "%.8f" $(echo "$result * 0.840049" | bc))    $(printf "%.8f" $(echo "$result * 0.826126" | bc))    $(printf "%.8f" $(echo "$result * 0.006035" | bc))
5 4  $(printf "%.8f" $(echo "$result * 0.996174" | bc))    $(printf "%.8f" $(echo "$result * 0.170857" | bc))    $(printf "%.8f" $(echo "$result * 0.501778" | bc))
6 4  $(printf "%.8f" $(echo "$result * 0.002765" | bc))    $(printf "%.8f" $(echo "$result * 0.499000" | bc))    $(printf "%.8f" $(echo "$result * 0.837089" | bc))
7 4  $(printf "%.8f" $(echo "$result * 0.165296" | bc))    $(printf "%.8f" $(echo "$result * 0.002049" | bc))    $(printf "%.8f" $(echo "$result * 0.164693" | bc))
8 4  $(printf "%.8f" $(echo "$result * 0.163525" | bc))    $(printf "%.8f" $(echo "$result * 0.163105" | bc))    $(printf "%.8f" $(echo "$result * 0.334455" | bc))
9 4  $(printf "%.8f" $(echo "$result * 0.333881" | bc))    $(printf "%.8f" $(echo "$result * 0.997652" | bc))    $(printf "%.8f" $(echo "$result * 0.999084" | bc))
10 4 $(printf "%.8f" $(echo "$result * 0.995756" | bc))    $(printf "%.8f" $(echo "$result * 0.004238" | bc))    $(printf "%.8f" $(echo "$result * 0.672969" | bc))
11 4 $(printf "%.8f" $(echo "$result * 0.166923" | bc))    $(printf "%.8f" $(echo "$result * 0.169551" | bc))    $(printf "%.8f" $(echo "$result * 0.673280" | bc))
12 4 $(printf "%.8f" $(echo "$result * 0.334326" | bc))    $(printf "%.8f" $(echo "$result * 0.166446" | bc))    $(printf "%.8f" $(echo "$result * 0.496714" | bc))
13 4 $(printf "%.8f" $(echo "$result * 0.330906" | bc))    $(printf "%.8f" $(echo "$result * 0.333906" | bc))    $(printf "%.8f" $(echo "$result * 0.671527" | bc))
14 4 $(printf "%.8f" $(echo "$result * 0.500248" | bc))    $(printf "%.8f" $(echo "$result * 0.498625" | bc))    $(printf "%.8f" $(echo "$result * 0.665345" | bc))
15 4 $(printf "%.8f" $(echo "$result * 0.673942" | bc))    $(printf "%.8f" $(echo "$result * 0.168569" | bc))    $(printf "%.8f" $(echo "$result * 0.165006" | bc))
16 4 $(printf "%.8f" $(echo "$result * 0.830204" | bc))    $(printf "%.8f" $(echo "$result * 0.839291" | bc))    $(printf "%.8f" $(echo "$result * 0.670969" | bc))
17 4 $(printf "%.8f" $(echo "$result * 0.337121" | bc))    $(printf "%.8f" $(echo "$result * 0.166806" | bc))    $(printf "%.8f" $(echo "$result * 0.828405" | bc))
18 4 $(printf "%.8f" $(echo "$result * 0.664714" | bc))    $(printf "%.8f" $(echo "$result * 0.501801" | bc))    $(printf "%.8f" $(echo "$result * 0.830441" | bc))
19 4 $(printf "%.8f" $(echo "$result * 0.837555" | bc))    $(printf "%.8f" $(echo "$result * 0.166543" | bc))    $(printf "%.8f" $(echo "$result * 0.328222" | bc))
20 4 $(printf "%.8f" $(echo "$result * 0.831461" | bc))    $(printf "%.8f" $(echo "$result * 0.496624" | bc))    $(printf "%.8f" $(echo "$result * 0.666434" | bc))
21 4 $(printf "%.8f" $(echo "$result * 0.499403" | bc))    $(printf "%.8f" $(echo "$result * 0.008085" | bc))    $(printf "%.8f" $(echo "$result * 0.829762" | bc))
22 5 $(printf "%.8f" $(echo "$result * 0.169505" | bc))    $(printf "%.8f" $(echo "$result * 0.839128" | bc))    $(printf "%.8f" $(echo "$result * 0.992593" | bc))
23 5 $(printf "%.8f" $(echo "$result * 0.001543" | bc))    $(printf "%.8f" $(echo "$result * 0.339690" | bc))    $(printf "%.8f" $(echo "$result * 0.004398" | bc))
24 5 $(printf "%.8f" $(echo "$result * 0.004088" | bc))    $(printf "%.8f" $(echo "$result * 0.490434" | bc))    $(printf "%.8f" $(echo "$result * 0.162516" | bc))
25 5 $(printf "%.8f" $(echo "$result * 0.159716" | bc))    $(printf "%.8f" $(echo "$result * 0.503173" | bc))    $(printf "%.8f" $(echo "$result * 0.002298" | bc))
26 5 $(printf "%.8f" $(echo "$result * 0.999694" | bc))    $(printf "%.8f" $(echo "$result * 0.167587" | bc))    $(printf "%.8f" $(echo "$result * 0.167194" | bc))
27 5 $(printf "%.8f" $(echo "$result * 0.994234" | bc))    $(printf "%.8f" $(echo "$result * 0.837990" | bc))    $(printf "%.8f" $(echo "$result * 0.831883" | bc))
28 5 $(printf "%.8f" $(echo "$result * 0.167316" | bc))    $(printf "%.8f" $(echo "$result * 0.330344" | bc))    $(printf "%.8f" $(echo "$result * 0.170717" | bc))
29 5 $(printf "%.8f" $(echo "$result * 0.490926" | bc))    $(printf "%.8f" $(echo "$result * 0.828650" | bc))    $(printf "%.8f" $(echo "$result * 0.335194" | bc))
30 5 $(printf "%.8f" $(echo "$result * 0.169825" | bc))    $(printf "%.8f" $(echo "$result * 0.319521" | bc))    $(printf "%.8f" $(echo "$result * 0.500503" | bc))
31 5 $(printf "%.8f" $(echo "$result * 0.329182" | bc))    $(printf "%.8f" $(echo "$result * 0.329812" | bc))    $(printf "%.8f" $(echo "$result * 0.335276" | bc))
32 5 $(printf "%.8f" $(echo "$result * 0.510716" | bc))    $(printf "%.8f" $(echo "$result * 0.834761" | bc))    $(printf "%.8f" $(echo "$result * 0.673879" | bc))
33 5 $(printf "%.8f" $(echo "$result * 0.653931" | bc))    $(printf "%.8f" $(echo "$result * 0.329455" | bc))    $(printf "%.8f" $(echo "$result * 0.997348" | bc))
34 5 $(printf "%.8f" $(echo "$result * 0.669367" | bc))    $(printf "%.8f" $(echo "$result * 0.668984" | bc))    $(printf "%.8f" $(echo "$result * 0.333788" | bc))
35 5 $(printf "%.8f" $(echo "$result * 0.337205" | bc))    $(printf "%.8f" $(echo "$result * 0.002204" | bc))    $(printf "%.8f" $(echo "$result * 0.340348" | bc))
36 5 $(printf "%.8f" $(echo "$result * 0.488435" | bc))    $(printf "%.8f" $(echo "$result * 0.171729" | bc))    $(printf "%.8f" $(echo "$result * 0.336002" | bc))
37 5 $(printf "%.8f" $(echo "$result * 0.662124" | bc))    $(printf "%.8f" $(echo "$result * 0.500021" | bc))    $(printf "%.8f" $(echo "$result * 0.504144" | bc))
38 5 $(printf "%.8f" $(echo "$result * 0.667559" | bc))    $(printf "%.8f" $(echo "$result * 0.830954" | bc))    $(printf "%.8f" $(echo "$result * 0.824509" | bc))
39 5 $(printf "%.8f" $(echo "$result * 0.822546" | bc))    $(printf "%.8f" $(echo "$result * 0.171140" | bc))    $(printf "%.8f" $(echo "$result * 0.005398" | bc))
40 5 $(printf "%.8f" $(echo "$result * 0.171289" | bc))    $(printf "%.8f" $(echo "$result * 0.990967" | bc))    $(printf "%.8f" $(echo "$result * 0.831776" | bc))
41 5 $(printf "%.8f" $(echo "$result * 0.507221" | bc))    $(printf "%.8f" $(echo "$result * 0.334292" | bc))    $(printf "%.8f" $(echo "$result * 0.823245" | bc))
42 5 $(printf "%.8f" $(echo "$result * 0.667746" | bc))    $(printf "%.8f" $(echo "$result * 0.335930" | bc))    $(printf "%.8f" $(echo "$result * 0.671546" | bc))
43 5 $(printf "%.8f" $(echo "$result * 0.833462" | bc))    $(printf "%.8f" $(echo "$result * 0.665940" | bc))    $(printf "%.8f" $(echo "$result * 0.829504" | bc))
44 1 $(printf "%.8f" $(echo "$result * 0.997849" | bc))    $(printf "%.8f" $(echo "$result * 0.837044" | bc))    $(printf "%.8f" $(echo "$result * 0.505146" | bc))
45 1 $(printf "%.8f" $(echo "$result * 0.332939" | bc))    $(printf "%.8f" $(echo "$result * 0.665965" | bc))    $(printf "%.8f" $(echo "$result * 0.998009" | bc))
46 1 $(printf "%.8f" $(echo "$result * 0.004444" | bc))    $(printf "%.8f" $(echo "$result * 0.327830" | bc))    $(printf "%.8f" $(echo "$result * 0.336060" | bc))
47 1 $(printf "%.8f" $(echo "$result * 0.996856" | bc))    $(printf "%.8f" $(echo "$result * 0.666243" | bc))    $(printf "%.8f" $(echo "$result * 0.670749" | bc))
48 1 $(printf "%.8f" $(echo "$result * 0.501065" | bc))    $(printf "%.8f" $(echo "$result * 0.499562" | bc))    $(printf "%.8f" $(echo "$result * 0.991647" | bc))
49 1 $(printf "%.8f" $(echo "$result * 0.497226" | bc))    $(printf "%.8f" $(echo "$result * 0.664688" | bc))    $(printf "%.8f" $(echo "$result * 0.174616" | bc))
50 1 $(printf "%.8f" $(echo "$result * 0.167930" | bc))    $(printf "%.8f" $(echo "$result * 0.664576" | bc))    $(printf "%.8f" $(echo "$result * 0.831519" | bc))
51 1 $(printf "%.8f" $(echo "$result * 0.332647" | bc))    $(printf "%.8f" $(echo "$result * 0.663852" | bc))    $(printf "%.8f" $(echo "$result * 0.666362" | bc))
52 1 $(printf "%.8f" $(echo "$result * 0.501053" | bc))    $(printf "%.8f" $(echo "$result * 0.326328" | bc))    $(printf "%.8f" $(echo "$result * 0.170756" | bc))
53 1 $(printf "%.8f" $(echo "$result * 0.664234" | bc))    $(printf "%.8f" $(echo "$result * 0.494766" | bc))    $(printf "%.8f" $(echo "$result * 0.165267" | bc))
54 1 $(printf "%.8f" $(echo "$result * 0.670282" | bc))    $(printf "%.8f" $(echo "$result * 0.836177" | bc))    $(printf "%.8f" $(echo "$result * 0.503784" | bc))
55 1 $(printf "%.8f" $(echo "$result * 0.835115" | bc))    $(printf "%.8f" $(echo "$result * 0.496919" | bc))    $(printf "%.8f" $(echo "$result * 0.998814" | bc))
56 1 $(printf "%.8f" $(echo "$result * 0.166272" | bc))    $(printf "%.8f" $(echo "$result * 0.336448" | bc))    $(printf "%.8f" $(echo "$result * 0.829195" | bc))
57 1 $(printf "%.8f" $(echo "$result * 0.667043" | bc))    $(printf "%.8f" $(echo "$result * 0.332360" | bc))    $(printf "%.8f" $(echo "$result * 0.332458" | bc))
58 1 $(printf "%.8f" $(echo "$result * 0.335604" | bc))    $(printf "%.8f" $(echo "$result * 0.999533" | bc))    $(printf "%.8f" $(echo "$result * 0.671892" | bc))
59 1 $(printf "%.8f" $(echo "$result * 0.498607" | bc))    $(printf "%.8f" $(echo "$result * 0.166248" | bc))    $(printf "%.8f" $(echo "$result * 0.671796" | bc))
60 1 $(printf "%.8f" $(echo "$result * 0.834696" | bc))    $(printf "%.8f" $(echo "$result * 0.001535" | bc))    $(printf "%.8f" $(echo "$result * 0.165871" | bc))
61 1 $(printf "%.8f" $(echo "$result * 0.665926" | bc))    $(printf "%.8f" $(echo "$result * 0.996055" | bc))    $(printf "%.8f" $(echo "$result * 0.669926" | bc))
62 1 $(printf "%.8f" $(echo "$result * 0.663110" | bc))    $(printf "%.8f" $(echo "$result * 0.167602" | bc))    $(printf "%.8f" $(echo "$result * 0.832686" | bc))
63 1 $(printf "%.8f" $(echo "$result * 0.836027" | bc))    $(printf "%.8f" $(echo "$result * 0.998105" | bc))    $(printf "%.8f" $(echo "$result * 0.503139" | bc))
64 1 $(printf "%.8f" $(echo "$result * 0.837889" | bc))    $(printf "%.8f" $(echo "$result * 0.171902" | bc))    $(printf "%.8f" $(echo "$result * 0.667054" | bc))
65 1 $(printf "%.8f" $(echo "$result * 0.835793" | bc))    $(printf "%.8f" $(echo "$result * 0.002472" | bc))    $(printf "%.8f" $(echo "$result * 0.833600" | bc))
66 3 $(printf "%.8f" $(echo "$result * 0.000622" | bc))    $(printf "%.8f" $(echo "$result * 0.662100" | bc))    $(printf "%.8f" $(echo "$result * 0.990514" | bc))
67 3 $(printf "%.8f" $(echo "$result * 0.008382" | bc))    $(printf "%.8f" $(echo "$result * 0.838489" | bc))    $(printf "%.8f" $(echo "$result * 0.153720" | bc))
68 3 $(printf "%.8f" $(echo "$result * 0.988259" | bc))    $(printf "%.8f" $(echo "$result * 0.684738" | bc))    $(printf "%.8f" $(echo "$result * 0.330464" | bc))
69 3 $(printf "%.8f" $(echo "$result * 0.331888" | bc))    $(printf "%.8f" $(echo "$result * 0.837550" | bc))    $(printf "%.8f" $(echo "$result * 0.161001" | bc))
70 3 $(printf "%.8f" $(echo "$result * 0.998221" | bc))    $(printf "%.8f" $(echo "$result * 0.002276" | bc))    $(printf "%.8f" $(echo "$result * 0.000941" | bc))
71 3 $(printf "%.8f" $(echo "$result * 0.153954" | bc))    $(printf "%.8f" $(echo "$result * 0.495825" | bc))    $(printf "%.8f" $(echo "$result * 0.334218" | bc))
72 3 $(printf "%.8f" $(echo "$result * 0.338365" | bc))    $(printf "%.8f" $(echo "$result * 0.677635" | bc))    $(printf "%.8f" $(echo "$result * 0.334932" | bc))
73 3 $(printf "%.8f" $(echo "$result * 0.999023" | bc))    $(printf "%.8f" $(echo "$result * 0.007169" | bc))    $(printf "%.8f" $(echo "$result * 0.334688" | bc))
74 3 $(printf "%.8f" $(echo "$result * 0.002631" | bc))    $(printf "%.8f" $(echo "$result * 0.332464" | bc))    $(printf "%.8f" $(echo "$result * 0.667341" | bc))
75 3 $(printf "%.8f" $(echo "$result * 0.162606" | bc))    $(printf "%.8f" $(echo "$result * 0.503462" | bc))    $(printf "%.8f" $(echo "$result * 0.657065" | bc))
76 3 $(printf "%.8f" $(echo "$result * 0.336659" | bc))    $(printf "%.8f" $(echo "$result * 0.500412" | bc))    $(printf "%.8f" $(echo "$result * 0.506371" | bc))
77 3 $(printf "%.8f" $(echo "$result * 0.505132" | bc))    $(printf "%.8f" $(echo "$result * 0.167755" | bc))    $(printf "%.8f" $(echo "$result * 0.997724" | bc))
78 3 $(printf "%.8f" $(echo "$result * 0.507181" | bc))    $(printf "%.8f" $(echo "$result * 0.497230" | bc))    $(printf "%.8f" $(echo "$result * 0.331003" | bc))
79 3 $(printf "%.8f" $(echo "$result * 0.827813" | bc))    $(printf "%.8f" $(echo "$result * 0.660066" | bc))    $(printf "%.8f" $(echo "$result * 0.156647" | bc))
80 3 $(printf "%.8f" $(echo "$result * 0.828363" | bc))    $(printf "%.8f" $(echo "$result * 0.828701" | bc))    $(printf "%.8f" $(echo "$result * 0.334676" | bc))
81 3 $(printf "%.8f" $(echo "$result * 0.002800" | bc))    $(printf "%.8f" $(echo "$result * 0.158226" | bc))    $(printf "%.8f" $(echo "$result * 0.828739" | bc))
82 3 $(printf "%.8f" $(echo "$result * 0.330890" | bc))    $(printf "%.8f" $(echo "$result * 0.497636" | bc))    $(printf "%.8f" $(echo "$result * 0.830838" | bc))
83 3 $(printf "%.8f" $(echo "$result * 0.500915" | bc))    $(printf "%.8f" $(echo "$result * 0.658695" | bc))    $(printf "%.8f" $(echo "$result * 0.830831" | bc))
84 3 $(printf "%.8f" $(echo "$result * 0.672281" | bc))    $(printf "%.8f" $(echo "$result * 0.664444" | bc))    $(printf "%.8f" $(echo "$result * 0.662925" | bc))
85 3 $(printf "%.8f" $(echo "$result * 0.827225" | bc))    $(printf "%.8f" $(echo "$result * 0.332649" | bc))    $(printf "%.8f" $(echo "$result * 0.172160" | bc))
86 3 $(printf "%.8f" $(echo "$result * 0.837061" | bc))    $(printf "%.8f" $(echo "$result * 0.663021" | bc))    $(printf "%.8f" $(echo "$result * 0.512539" | bc))
87 3 $(printf "%.8f" $(echo "$result * 0.834602" | bc))    $(printf "%.8f" $(echo "$result * 0.332176" | bc))    $(printf "%.8f" $(echo "$result * 0.494432" | bc))
88 2 $(printf "%.8f" $(echo "$result * 0.166226" | bc))    $(printf "%.8f" $(echo "$result * 0.666994" | bc))    $(printf "%.8f" $(echo "$result * 0.167522" | bc))
89 2 $(printf "%.8f" $(echo "$result * 0.167049" | bc))    $(printf "%.8f" $(echo "$result * 0.837796" | bc))    $(printf "%.8f" $(echo "$result * 0.333212" | bc))
90 2 $(printf "%.8f" $(echo "$result * 0.498686" | bc))    $(printf "%.8f" $(echo "$result * 0.833874" | bc))    $(printf "%.8f" $(echo "$result * 0.996229" | bc))
91 2 $(printf "%.8f" $(echo "$result * 0.168648" | bc))    $(printf "%.8f" $(echo "$result * 0.164567" | bc))    $(printf "%.8f" $(echo "$result * 0.997132" | bc))
92 2 $(printf "%.8f" $(echo "$result * 0.164953" | bc))    $(printf "%.8f" $(echo "$result * 0.670926" | bc))    $(printf "%.8f" $(echo "$result * 0.496944" | bc))
93 2 $(printf "%.8f" $(echo "$result * 0.335349" | bc))    $(printf "%.8f" $(echo "$result * 0.333026" | bc))    $(printf "%.8f" $(echo "$result * 0.998288" | bc))
94 2 $(printf "%.8f" $(echo "$result * 0.333974" | bc))    $(printf "%.8f" $(echo "$result * 0.500484" | bc))    $(printf "%.8f" $(echo "$result * 0.168205" | bc))
95 2 $(printf "%.8f" $(echo "$result * 0.665528" | bc))    $(printf "%.8f" $(echo "$result * 0.665371" | bc))    $(printf "%.8f" $(echo "$result * 0.995825" | bc))
96 2 $(printf "%.8f" $(echo "$result * 0.666438" | bc))    $(printf "%.8f" $(echo "$result * 0.832851" | bc))    $(printf "%.8f" $(echo "$result * 0.166704" | bc))
97 2 $(printf "%.8f" $(echo "$result * 0.334860" | bc))    $(printf "%.8f" $(echo "$result * 0.165021" | bc))    $(printf "%.8f" $(echo "$result * 0.166928" | bc))
98 2 $(printf "%.8f" $(echo "$result * 0.337380" | bc))    $(printf "%.8f" $(echo "$result * 0.832888" | bc))    $(printf "%.8f" $(echo "$result * 0.830149" | bc))
99 2 $(printf "%.8f" $(echo "$result * 0.501041" | bc))    $(printf "%.8f" $(echo "$result * 0.670145" | bc))    $(printf "%.8f" $(echo "$result * 0.503335" | bc))
100 2 $(printf "%.8f" $(echo "$result * 0.168144" | bc))    $(printf "%.8f" $(echo "$result * 0.001049" | bc))    $(printf "%.8f" $(echo "$result * 0.505194" | bc))
101 2 $(printf "%.8f" $(echo "$result * 0.499421" | bc))    $(printf "%.8f" $(echo "$result * 0.004038" | bc))    $(printf "%.8f" $(echo "$result * 0.169896" | bc))
102 2 $(printf "%.8f" $(echo "$result * 0.497810" | bc))    $(printf "%.8f" $(echo "$result * 0.330780" | bc))    $(printf "%.8f" $(echo "$result * 0.503387" | bc))
103 2 $(printf "%.8f" $(echo "$result * 0.667885" | bc))    $(printf "%.8f" $(echo "$result * 0.000274" | bc))    $(printf "%.8f" $(echo "$result * 0.997181" | bc))
104 2 $(printf "%.8f" $(echo "$result * 0.834012" | bc))    $(printf "%.8f" $(echo "$result * 0.503453" | bc))    $(printf "%.8f" $(echo "$result * 0.333646" | bc))
105 2 $(printf "%.8f" $(echo "$result * 0.500945" | bc))    $(printf "%.8f" $(echo "$result * 0.996550" | bc))    $(printf "%.8f" $(echo "$result * 0.500848" | bc))
106 2 $(printf "%.8f" $(echo "$result * 0.667808" | bc))    $(printf "%.8f" $(echo "$result * 0.002529" | bc))    $(printf "%.8f" $(echo "$result * 0.333084" | bc))
107 2 $(printf "%.8f" $(echo "$result * 0.666454" | bc))    $(printf "%.8f" $(echo "$result * 0.167082" | bc))    $(printf "%.8f" $(echo "$result * 0.499670" | bc))
108 2 $(printf "%.8f" $(echo "$result * 0.835798" | bc))    $(printf "%.8f" $(echo "$result * 0.329725" | bc))    $(printf "%.8f" $(echo "$result * 0.834206" | bc))
EOF

cp machinefile no_def library.meam CoNiCrFeMn.meam EFS.txt ./$a
cd ./$a

mpirun -np 48 lmp < EFS.txt > lammps-log.txt 2>&1

E=`grep -A 3 'Minimization stats:' lammps-log.txt| tail -n 1 | awk '{ print $3 }'`
cd ..
echo $a $E >> EV.txt
done 

#mpirun -np 48 lmp -machinefile $MACHINEFILE -v myseed 12345 -v tempstart 300 -v tempstop 300 -v latparam 3.518 -v size 1 -in stk_flt.txt > lammps-log.txt 2>&1
	

	

