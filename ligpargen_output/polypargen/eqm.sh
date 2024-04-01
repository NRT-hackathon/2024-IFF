#!/bin/bash

# Command line input

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
gmx editconf -f PET_50N.gro -o edited_conf.gro -c -d 1.5 -bt triclinic -box 65 $box_len $box_len

# Add PET
gmx insert-molecules -f edited_conf.gro -nmol $copies -try 30 -ci PET_50N.gro -o edited_conf.gro

# Add malodour
gmx insert-molecules -f edited_conf.gro -nmol $copies_small -try 30 -ci "$filename.gro" -o edited_conf.gro

# Solvate
gmx solvate -cp edited_conf.gro -cs spc216.gro -o solvated.gro -p topol.top

## Energy minimization process ##
gmx grompp -f minim.mdp -c solvated.gro -p topol.top -o em.tpr
gmx mdrun -v -deffnm em

## NVT Equilibration ##
gmx grompp -f eqm_nvt.mdp -c em.gro -p topol.top -o nvt.tpr
gmx mdrun -deffnm nvt

## NPT Equilibration ##
gmx grompp -f eqm_npt.mdp -c nvt.gro -p topol.top -o npt.tpr
gmx mdrun -deffnm npt

## Production ##
gmx grompp -f prod_md.mdp -c npt.gro -t npt.cpt -p topol.top -o md_1.tpr
gmx mdrun -deffnm md_1

## some post processing ##
#gmx trjconv -s md_1.tpr -f md_1.trr -o md_1_noPBC.trr -pbc mol -center

