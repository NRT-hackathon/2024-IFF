#!/bin/bash

# Command line input

filename=$1 # molecule name
copies=$2 # number of molecules
boxlen=$3 # nm

# pre-processing
cp "$filename.itp" topol.top # copying topology from raw itp file
sed -i "10,\$ { /^$filename/s/.*/$filename         $copies/ }" "topol.top" # adding the correct number of molecules to the topolgy file
((copies--))

# Energy minimization process
gmx editconf -f "$filename.gro" -o edited_conf.gro -c -d 1.0 -bt cubic -box $boxlen
#gmx insert-molecules -f edited_conf.gro -nmol $copies -try 30 -ci "$filename.gro" -o edited_conf.gro
#gmx solvate -cp edited_conf.gro -cs spc216.gro -o solvated.gro -p topol.top
#gmx grompp -f minim.mdp -c solvated.gro -p topol.top -o em.tpr
#gmx mdrun -v -deffnm em


