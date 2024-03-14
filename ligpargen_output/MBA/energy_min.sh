#!/bin/bash

read filename
gmx editconf -f $filename -o edited_conf.gro -c -d 1.0 -bt cubic
gmx solvate -cp edited_conf.gro -cs spc216.gro -o solvated.gro -p topol.top
gmx grompp -f minim.mdp -c solvated.gro -p topol.top -o em.tpr
gmx mdrun -v -deffnm em
