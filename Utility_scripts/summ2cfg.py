import subprocess
from decimal import *
import numpy as np

def get_force(nsw, n_ions):
    force = []
    f = []
    with open('forces.txt') as input_data:
        for line in input_data:
            b = line.split()
            f.append(b)
        #print(f)
        for i in range((nsw-1)*(n_ions+4)+2, (nsw-1)*(n_ions+4)+2 + n_ions):        #RANGE = (NSW-1)*(n_ions+4)+2 to (NSW-1)*(n_ions+4)+2 + n_ions, to be changed accordingly
            for j in range(3, 6):
                x = round(float(f[i][j]), 6)                      # Returns force in eV/Angstrom unit
                force.append(x)
        return force

def get_atomic_positions(nsw, n_ions):
    cartes = []
    c = []
    with open('cartes.txt') as input_data:
        for line in input_data:
            b = line.split()
            c.append(b)
        #print(c)
        for i in range((nsw-1)*(n_ions+4)+2, (nsw-1)*(n_ions+4)+2 + n_ions):     #RANGE = (NSW-1)*(n_ions+4)+2 to (NSW-1)*(n_ions+4)+2 + n_ions, to be changed accordingly
            for j in range(0, 3):
                x = round(float(c[i][j]), 6)                    #Returns coordinates in Angstrom
                cartes.append(x)
    return cartes

def get_lattice(nsw):
    #returns lattice parameter a and c in a.u.
    lattice = []
    lat = []
    with open('lattice_vec.txt') as input_data:
        for line in input_data:
            b = line.split()
            lattice.append(b)
        for i in range(10*(nsw-1) + 5, 10*(nsw-1) + 8):                      #RANGE = 10*(NSW-1) + 5 to 10*(NSW-1) + 8, to be changed accordingly 
            for j in range(0, 3):
                x = round(float(lattice[i][j]), 9)
                lat.append(x)
    return lat                                       # Returns final supercell lattice vectors

def get_energy(nsw):
    energy = []
    with open('energy.txt') as input_data:
        for line in input_data:
            b = line.split()
            energy.append(b)                         # Returns energy in eV
        e = round(float(energy[-2][4]), 6)                     # 12 comes from 3*(NSW-1), to be changed accordingly                                            
    return e

def get_stress(nsw):
    s = []
    stress = []
    with open('stress.txt') as input_data:
        for line in input_data:
            b = line.split()
            s.append(b)
        print(s)
        for i in range(2,8):
            val = round(float(s[3*(nsw-1)][i]), 4)                   # 12 comes from 3*(NSW-1), to be changed accordingly
            stress.append(val)                      # Returns stress acting on the atoms in GPa
    return stress

def main():
    
    n_ions = int(input('Enter the system size: '))                      # takes input about the number of atoms in system.
    nsw = int(input('Enter the NSW parameter chosen in INCAR file:'))   # takes input about number of ionic steps for recording each data point.
    n_files = int(input('Enter the number of files to be converted: ')) # takes input about number of VASP output files to be converted into cfg files. 
    
    for i in range(1, n_files+1):
    	file_name = 'SUMMARY_OUT_{0}.txt'.format(i)

    	subprocess.call('grep -A {0} "TOTAL-FORCE" {1} > forces.txt'.format(n_ions+2, file_name), shell=True)
    	subprocess.call('grep -A {0} "POSITION" {1} > cartes.txt'.format(n_ions+2, file_name), shell=True)
    	subprocess.call('grep -A 1 "TOTEN" {0} > energy.txt'.format(file_name), shell=True)
    	subprocess.call('grep -A 1 "in kB"  {0} > stress.txt'.format(file_name), shell=True)
    	subprocess.call('grep -A 8 "VOLUME and BASIS*" {0} > lattice_vec.txt'.format(file_name), shell=True)
    
    
    	lat = get_lattice(nsw)  
    	force = get_force(nsw, n_ions)  
    	cartes = get_atomic_positions(nsw, n_ions)  
    	energy = get_energy(nsw)
    	stress = get_stress(nsw)
    	f1 = open('MLIP_HEAvac_{0}.cfg'.format(i), 'w')
    	f1.write("\nBEGIN_CFG \n Size\n     " + str(n_ions) + "\n Supercell\n     " + str('{0:.9f}'.format(lat[0])) + "     "+str('{0:.9f}'.format(lat[1])) + "     "+str('{0:.9f}'.format(lat[2]))+ "\n" + "     " + str('{0:.9f}'.format(lat[3]))+ "     " + str('{0:.9f}'.format(lat[4])) + "     " + str('{0:.9f}'.format(lat[5]))+ "\n" +"     "+ str('{0:.9f}'.format(lat[6]))+"     "+ str('{0:.9f}'.format(lat[7]))+"     " + str('{0:.9f}'.format(lat[8])))
    	f1.write("\n AtomData:       id       type       cartes_x       cartes_y       cartes_z       fx          fy          fz")
    
    	for j in range(1, n_ions+1):
        	f1.write("\n                  " + str(j)+ "        " +str(int(np.heaviside(j-22, 1) + np.heaviside(j-43, 1) + np.heaviside(j-64, 1) + np.heaviside(j-85, 1))) + "         " + str('{0:.5f}'.format(cartes[3*(j-1)])) + "        "+ str('{0:.5f}'.format(cartes[3*(j-1)+1])) +"        "+ str('{0:.5f}'.format(cartes[3*(j-1)+2])))
        	f1.write("     "+str('{0:.6f}'.format(force[3*(j-1)]))+ "    "+ str('{0:.6f}'.format(force[3*(j-1)+1])) + "    "+ str('{0:.6f}'.format(force[3*(j-1)+2])))

        	#f1.write("\n              " + str(i) + "   " + str(0) + "   " + str(cartes[3]) + "    " + str(cartes[4]) + "    " + str(cartes[5]))
        	#f1.write("  " + str(force[3]) + "   " + str(force[4]) + "   " + str(force[5]))
    	f1.write("\n Energy\n     "+str(energy))
    	f1.write("\n PlusStress:    xx          yy          zz          yz          xz          xy \n")
    	f1.write("              " + str('{0:.3f}'.format(stress[0])) + "   ")
    	f1.write("   " + str('{0:.3f}'.format(stress[1])) + "   ")
    	f1.write("   " + str('{0:.3f}'.format(stress[2])) + "   ")

    	f1.write("   " + str('{0:.3f}'.format(stress[3])) + "   ")
    	f1.write("   " + str('{0:.3f}'.format(stress[4])) + "   ")
    	f1.write("   " + str('{0:.3f}'.format(stress[5])) + "   ")
    	f1.write("\n Feature    EFS_by	VASP")
    	f1.write("\nEND_CFG\n\n")
    	f1.close()

if __name__ == "__main__":
    getcontext().prec = 10
    main()
