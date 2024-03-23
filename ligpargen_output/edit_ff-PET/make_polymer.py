import numpy as np
import sys

try:
    DP = int(sys.argv[1])
except IndexError:
    DP = 50

n_h_terminus = 23
idxs_2_drop_h_terminus = [15 - 1, 25 - 1] #'O0E' and 'H0P'

n_oh_terminus = 24
idxs_2_drop_oh_terminus = [16 - 1] # 'H0F'

n_monomer = 22
idxs_2_drop_monomer = [15 - 1, 16 - 1, 25 - 1] #'O0E' and 'H0P' and # 'H0F'

monomer_size = 1 #nm

f = open('PET.gro')
read_monomer_PET = f.readlines()
f.close()

# DP = 3
n_atoms = n_h_terminus + n_monomer*(DP - 2) + n_oh_terminus
L_box = DP*monomer_size
mol_id = "PET"
line1 = f"{DP}N {mol_id}"
line2 = f"{n_atoms}"
box_size = "{0:.5f}   {0:.5f}   {0:.5f}".format(L_box//2)

original = read_monomer_PET[2:-1]
original_coords = np.zeros((len(original), 3), dtype = float)
original_atom_names = np.zeros((len(original)), dtype = object)

for i, line in enumerate(original):
    ls = line.split()
    original_coords[i] = ls[3:]
    original_atom_names[i] = ls[1]

original_coords += 1 # correcting for shift to center box where L is half of box dimension

new_coords = np.zeros((n_atoms, 3), dtype = float)
new_atom_names = np.zeros((n_atoms), dtype = object)
PET_ID = np.zeros((n_atoms), dtype = int)

start_idx = 0
monomer_ID = 1

# H terminus
slc = slice(start_idx, n_h_terminus)
new_coords[slc] = np.delete(original_coords, idxs_2_drop_h_terminus, axis = 0)
new_atom_names[slc] = np.delete(original_atom_names, idxs_2_drop_h_terminus, axis = 0)
PET_ID[slc] = monomer_ID

start_idx += n_h_terminus
monomer_ID += 1

# monomers
for i in range(DP - 2):
    # lim1 = n_h_terminus + i*n_monomer
    slc = slice(start_idx, start_idx + n_monomer)
    curr_coords = np.delete(original_coords, idxs_2_drop_monomer, axis = 0)
    curr_coords[:, 2] += (i + 1)*monomer_size
    new_coords[slc] = curr_coords
    # new_coords[slc] = np.delete(original_coords, idxs_2_drop_monomer, axis = 0) + (i + 1)*monomer_size
    new_atom_names[slc] = np.delete(original_atom_names, idxs_2_drop_monomer, axis = 0)
    PET_ID[slc] = monomer_ID

    start_idx += n_monomer
    monomer_ID += 1

# OH terminus
slc = slice(start_idx, start_idx + n_oh_terminus)
curr_coords = np.delete(original_coords, idxs_2_drop_oh_terminus, axis = 0)
curr_coords[:, 2] += (DP - 1)*monomer_size
new_coords[slc] = curr_coords
# new_coords[slc] = np.delete(original_coords, idxs_2_drop_oh_terminus, axis = 0) + (DP - 1)*monomer_size
new_atom_names[slc] = np.delete(original_atom_names, idxs_2_drop_oh_terminus, axis = 0)
PET_ID[slc] = monomer_ID

new_coords -= L_box//2 # Centering box at L_box//2

output_str = ""
output_str += line1 + "\n"
output_str += "   " + line2 + "\n"

for i in range(n_atoms):
    chainid = PET_ID[i]
    atom_ID = new_atom_names[i]
    x = new_coords[i, 0]
    y = new_coords[i, 1]
    z = new_coords[i, 2]

    output_str += "{0:5d}{1:5s}{2:5s}{3:5d}{4:8.3f}{5:8.3f}{6:8.3f}\n".format(chainid, mol_id, atom_ID, i + 1, x, y, z)

output_str += "   " + box_size + "\n"

f = open(f'test_{DP}NPET.gro', 'w')
f.write(output_str)
f.close()