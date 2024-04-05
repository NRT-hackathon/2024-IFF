#!/bin/bash

mkdir -p figures
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
gmx editconf -f test_edit_PET.gro -o edited_conf.gro -c -bt triclinic -box 60 $box_len $box_len

# Add PET
#gmx insert-molecules -f edited_conf.gro -nmol $copies -try 30 -ci test_edit_PET.gro -o edited_conf.gro

# Add malodour
#gmx insert-molecules -f edited_conf.gro -nmol $copies_small -try 30 -ci "$filename.gro" -o edited_conf.gro

# Solvate
gmx solvate -cp edited_conf.gro -cs spc216.gro -o edited_conf.gro -p topol.top

## Energy minimization process ##
gmx grompp -f minim.mdp -c edited_conf.gro -p topol.top -o em.tpr ;-maxwarn 1
gmx mdrun -v -deffnm em -rdd 1 -pin on

echo "10 0"|gmx energy -f em.edr -o etot_em.xvg
./xvg_convert.sh etot_em

## NVT Equilibration ##
gmx grompp -f eqm_nvt.mdp -c em.gro -p topol.top -o nvt.tpr
gmx mdrun -deffnm nvt -rdd 1 -pin on

echo "15 0"|gmx energy -f nvt.edr -o t_nvt.xvg
./xvg_convert.sh t_nvt

## NPT Equilibration ##
gmx grompp -f eqm_npt.mdp -c nvt.gro -p topol.top -o npt.tpr
gmx mdrun -deffnm npt -rdd 1 -pin on

echo "15 0"|gmx energy -f npt.edr -o t_npt.xvg
./xvg_convert.sh t_npt
echo "23 0"|gmx energy -f npt.edr -o rho_npt.xvg
./xvg_convert.sh rho_npt
echo "22 0"|gmx energy -f npt.edr -o v_npt.xvg
./xvg_convert.sh v_npt
echo "17 0"|gmx energy -f npt.edr -o p_npt.xvg
./xvg_convert.sh p_npt

echo "2 0"|gmx trjconv -s npt.tpr -f npt.trr -o npt_nopbc.trr -pbc mol -center

## Production ##
#gmx grompp -f prod_md.mdp -c npt.gro -t npt.cpt -p topol.top -o md_1.tpr
#gmx mdrun -deffnm md_1 -pin on

## some post processing ##
#gmx rdf -s md_1.tpr -f md_1.trr -o rdf.xvg -tu ps -rmax 3 -ref 2 -sel 3 4 2 -bin 0.05
#gmx rdf -s md_1.tpr -f md_1.trr -o rdf_LR.xvg -tu ps -cut 0.25 -rmax 3 -ref 2 -sel 3 4 2 -bin 0.05
#gmx rdf -s md_1.tpr -f md_1.trr -o rdf_mal.xvg -tu ps -rmax 3 -ref 3 -sel 3 4 2 -bin 0.05
#gmx msd -f md_1.trr -s md_1.tpr -o msd.xvg -sel 3 2 4 -maxtau 1000
#gmx trjconv -s md_1.tpr -f md_1.trr -o md_1_noPBC.trr -pbc mol -center

mv *.xvg figures
mv *.png figures

