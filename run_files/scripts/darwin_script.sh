#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --ntasks-per-node=8
#SBATCH --mem-per-cpu=4096M
#SBATCH --partition=idle
#SBATCH --time=0-00:10:00
#SBATCH --job-name=HEP_test

#SBATCH --export=NONE

#set -e

vpkg_require gromacs/2023.2:mpi

cd $SLURM_SUBMIT_DIR

GROMACS_DOUBLE_PRECISION=YES
GROMACS_MDRUN_FLAGS=()

copies=$1 # number of PET molecules
box_len=$2 # size of box
filename=$3 # identity of malodour molecule
copies_small=$4 # number of malofour molecules

##  pre-processing ##
cp template.top topol.top
sed -i "1,\$ { /^malodour.itp/s/.*/\#include \"$filename.itp\"/ }" "topol.top"
sed -i "10,\$ { /^malodour/s/.*/$filename              $copies_small/ }" "topol.top" # adding the correct number of malodour molecules to the topolgy file
sed -i "10,\$ { /^PET/s/.*/PET              $copies/ }" "topol.top" # Adding correct number of PET to the topology file
((copies--))

# Edit box conf to fit all molecules
gmx_mpi editconf -f PET.gro -o edited_conf.gro -c -d 1.0 -bt cubic -box $box_len

# Add PET
gmx_mpi insert-molecules -f edited_conf.gro -nmol $copies -try 30 -ci PET.gro -o edited_conf.gro

# Add malodour
gmx_mpi insert-molecules -f edited_conf.gro -nmol $copies_small -try 30 -ci "$filename.gro" -o edited_conf.gro

# Solvate
gmx_mpi solvate -cp edited_conf.gro -cs spc216.gro -o solvated.gro -p topol.top

## Energy minimization process ##
gmx_mpi grompp -f minim.mdp -c solvated.gro -p topol.top -o em.tpr
gmx_mpi mdrun -v -deffnm em -pin on
