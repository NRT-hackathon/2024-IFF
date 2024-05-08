#!/bin/bash

# Command line input
filename=$1 # identity of malodour molecule
copies_small=$2 # number of malofour molecules

##  pre-processing ##
cp template.top topol.top
sed -i "1,\$ { /^malodour.itp/s/.*/\#include \"$filename.itp\"/ }" "topol.top"
sed -i "10,\$ { /^malodour/s/.*/$filename              $copies_small/ }" "topol.top" # adding the correct number of malodour molecules to the topolgy file

# Edit box conf to fit all molecules
gmx_mpi editconf -f "$filename"_droplet_PET_fibril_4.gro -o edited_conf.gro -c -bt triclinic -box 60 6 6

# Solvate
gmx_mpi solvate -cp edited_conf.gro -cs spc216.gro -o solvated.gro -p topol.top

## Energy minimization process ##
gmx_mpi grompp -f minim.mdp -c solvated.gro -p topol.top -o em.tpr
gmx_mpi mdrun -v -deffnm em -pin on -rdd 1

echo "10 0"|gmx_mpi energy -f em.edr -o etot_em.xvg

## NVT Equilibration ##
gmx_mpi grompp -f prod_nvt.mdp -c em.gro -p topol.top -o nvt.tpr
gmx_mpi mdrun -deffnm nvt -pin on

echo "15 0"|gmx_mpi energy -f nvt.edr -o t_nvt.xvg

## NPT Equilibration ##
gmx_mpi grompp -f prod_npt.mdp -c nvt.gro -p topol.top -o npt.tpr
gmx_mpi mdrun -deffnm npt -pin on

echo "15 0"|gmx_mpi energy -f npt.edr -o t_npt.xvg
echo "23 0"|gmx_mpi energy -f npt.edr -o rho_npt.xvg
echo "22 0"|gmx_mpi energy -f npt.edr -o v_npt.xvg
echo "17 0"|gmx_mpi energy -f npt.edr -o p_npt.xvg

## Production ##
gmx_mpi grompp -f prod_md.mdp -c npt.gro -t npt.cpt -p topol.top -o md_1.tpr
gmx_mpi mdrun -deffnm md_1 -pin on

echo "15 0"|gmx_mpi energy -f md_1.edr -o t_prod.xvg
