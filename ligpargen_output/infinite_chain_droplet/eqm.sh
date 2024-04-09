#!/bin/bash

# Command line input

#copies=$1 # number of PET molecules
#box_len=$2 # size of box
filename=$1 # identity of malodour molecule
copies_small=$2 # number of malofour molecules

##  pre-processing ##
cp template.top topol.top
sed -i "1,\$ { /^malodour.itp/s/.*/\#include \"$filename.itp\"/ }" "topol.top"
sed -i "10,\$ { /^malodour/s/.*/$filename              $copies_small/ }" "topol.top" # adding the correct number of malodour molecules to the topolgy file
#sed -i "10,\$ { /^PET/s/.*/PET              $copies/ }" "topol.top" # Adding correct number of PET to the topology file
#((copies--))

# Edit box conf to fit all molecules
#gmx editconf -f PET_single_malodour_ensemble.gro -o edited_conf.gro -c -d 1.0 -bt triclinic -box 59 3 3
gmx editconf -f PET_MBA_droplet.gro -o edited_conf.gro -c -bt triclinic -box 60 3 3

# Add PET
#gmx insert-molecules -f edited_conf.gro -nmol $copies -try 30 -ci PET.gro -o edited_conf.gro

# Add malodour
#gmx insert-molecules -f edited_conf.gro -nmol $copies_small -try 30 -ci "$filename.gro" -o edited_conf.gro

# Solvate
gmx solvate -cp edited_conf.gro -cs spc216.gro -o solvated.gro -p topol.top

## Energy minimization process ##
gmx grompp -f minim.mdp -c solvated.gro -p topol.top -o em.tpr
gmx mdrun -v -deffnm em -pin on -rdd 1

echo "10 0"|gmx energy -f em.edr -o etot_em.xvg
./xvg_convert.sh etot_em

## NVT Equilibration ##
#gmx grompp -f eqm_nvt.mdp -c em.gro -p topol.top -o nvt.tpr
#gmx mdrun -deffnm nvt -pin on

#echo "15 0"|gmx energy -f nvt.edr -o t_nvt.xvg
#./xvg_convert.sh t_nvt

## NPT Equilibration ##
#gmx grompp -f eqm_npt.mdp -c nvt.gro -p topol.top -o npt.tpr
#gmx mdrun -deffnm npt -pin on

#echo "15 0"|gmx energy -f npt.edr -o t_npt.xvg
#./xvg_convert.sh t_npt
#echo "23 0"|gmx energy -f npt.edr -o rho_npt.xvg
#./xvg_convert.sh rho_npt
#echo "22 0"|gmx energy -f npt.edr -o v_npt.xvg
#./xvg_convert.sh v_npt
#echo "17 0"|gmx energy -f npt.edr -o p_npt.xvg
#./xvg_convert.sh p_npt

## Production ##
#gmx grompp -f prod_md.mdp -c npt.gro -t npt.cpt -p topol.top -o md_1.tpr
#gmx mdrun -deffnm md_1 -pin on

## some post processing ##
#gmx rdf -s md_1.tpr -f md_1.trr -o rdf.xvg -tu ps -rmax 3 -ref 2 -sel 3 4 2 -bin 0.05
#./xvg_convert.sh rdf
#gmx rdf -s md_1.tpr -f md_1.trr -o rdf_LR.xvg -tu ps -cut 0.25 -rmax 3 -ref 2 -sel 3 4 2 -bin 0.05
#./xvg_convert.sh rdf_LR
#gmx rdf -s md_1.tpr -f md_1.trr -o rdf_mal.xvg -tu ps -rmax 3 -ref 3 -sel 3 4 2 -bin 0.05
#./xvg_convert.sh rdf_mal
#gmx msd -f md_1.trr -s md_1.tpr -o msd.xvg -sel 3 2 4 -maxtau 1000
#./xvg_convert.sh msd
#gmx trjconv -s md_1.tpr -f md_1.trr -o md_1_noPBC.trr -pbc mol -center

