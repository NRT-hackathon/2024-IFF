#!/bin/bash

# Command line input

filename=$1 # malodour molecule name
copies_small=$2 # number of malodor molecules
copies=$3 # number of PET molecules
boxlen=$4 # size of box

# monomer_size=1 #nm
# boxlen=$(( monomer_size*copies ))

##  pre-processing ##
cp template.top topol.top
sed -i "10,\$ { /^$filename/s/.*/$filename              $copies_small/ }" "topol.top" # adding the correct number of malodour molecules to the topolgy file
sed -i "10,\$ { /^PET/s/.*/PET              $copies/ }" "topol.top" # Adding correct number of PET to the topology file
((copies--))

# Edit box conf to fit all molecules
gmx editconf -f PET.gro -o edited_conf.gro -c -d 1.0 -bt cubic -box $boxlen

# Add PET
gmx insert-molecules -f edited_conf.gro -nmol $copies -try 30 -ci PET.gro -o edited_conf.gro

# Add malodour
gmx insert-molecules -f edited_conf.gro -nmol $copies_small -try 30 -ci "$filename.gro" -o edited_conf.gro

# Solvate
gmx solvate -cp edited_conf.gro -cs spc216.gro -o solvated.gro -p topol.top

## Energy minimization process ##
gmx grompp -f minim.mdp -c solvated.gro -p topol.top -o em.tpr
gmx mdrun -v -deffnm em

## NPT Equilibration ##
gmx grompp -f press_eq_1.mdp -c em.gro -p topol.top -o npt.tpr
gmx mdrun -deffnm npt


