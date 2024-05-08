#!/bin/bash

# Command line input

copies=$1 # number of PET molecules
box_len=$2 # size of box
#filename=$3 # identity of malodour molecule
#copies_small=$4 # number of malofour molecules

##  pre-processing ##
cp template.top topol.top
#sed -i "1,\$ { /^malodour.itp/s/.*/\#include \"$filename.itp\"/ }" "topol.top"
#sed -i "10,\$ { /^malodour/s/.*/$filename              $copies_small/ }" "topol.top" # adding the correct number of malodour molecules to the topolgy file
sed -i "10,\$ { /^PET/s/.*/PET              $copies/ }" "topol.top" # Adding correct number of PET to the topology file
((copies--))

# Edit box conf to fit all molecules
#gmx_mpi editconf -f PET.gro -o edited_conf.gro -c -bt cubic -box $box_len
gmx_mpi editconf -f PET_infinite.gro -o edited_conf.gro -c -bt triclinic -box 60 $box_len $box_len

# Add PET
#gmx_mpi insert-molecules -f edited_conf.gro -nmol $copies -try 30 -ci PET.gro -o edited_conf.gro

# Add malodour
#gmx_mpi insert-molecules -f edited_conf.gro -nmol $copies_small -try 30 -ci "$filename.gro" -o edited_conf.gro

# Solvate
gmx_mpi solvate -cp edited_conf.gro -cs spc216.gro -o solvated.gro -p topol.top

## Energy minimization process ##
gmx_mpi grompp -f prod_minim.mdp -c solvated.gro -p topol.top -o em.tpr
gmx_mpi mdrun -v -deffnm em -pin on -rdd 1

echo "10 0"|gmx_mpi energy -f em.edr -o etot_em.xvg

## NVT Equilibration ##
gmx_mpi grompp -f prod_nvt.mdp -c em.gro -p topol.top -o nvt.tpr
gmx_mpi mdrun -deffnm nvt -pin on -rdd 1

echo "15 0"|gmx_mpi energy -f nvt.edr -o t_nvt.xvg

## NPT Equilibration ##
gmx_mpi grompp -f prod_npt.mdp -c nvt.gro -p topol.top -o npt.tpr
gmx_mpi mdrun -deffnm npt -pin on -rdd 1

echo "15 0"|gmx_mpi energy -f npt.edr -o t_npt.xvg
echo "23 0"|gmx_mpi energy -f npt.edr -o rho_npt.xvg
echo "22 0"|gmx_mpi energy -f npt.edr -o v_npt.xvg
echo "17 0"|gmx_mpi energy -f npt.edr -o p_npt.xvg

## Production ##
gmx_mpi grompp -f prod_md.mdp -c npt.gro -t npt.cpt -p topol.top -o md_1.tpr
gmx_mpi mdrun -deffnm md_1 -pin on

echo "15 0"|gmx_mpi energy -f npt.edr -o t_prod.xvg
