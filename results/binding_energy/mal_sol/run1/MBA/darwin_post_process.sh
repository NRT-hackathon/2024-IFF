#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --ntasks-per-node=4
#SBATCH --mem-per-cpu=4096M
#SBATCH --partition=idle
#SBATCH --time=0-00:10:00
#SBATCH --job-name=post_process
#SBATCH --output=NK_postprocess_%j.txt

#SBATCH --export=NONE

#set -e

vpkg_require gromacs/2023.2:mpi

cd $SLURM_SUBMIT_DIR

GROMACS_DOUBLE_PRECISION=YES
GROMACS_MDRUN_FLAGS=()

out=md_1_noPBC.trr
if [ -f $out ];then
	rm $out
else
	echo "Periodic BC trajectory correction not created"
fi

out=msd.xvg
if [ -f $out ];then
	echo "MSD calculated"
else
	gmx_mpi msd -s md_1.tpr -f md_1.trr -o msd.xvg -sel 3 4 2 -maxtau 1000 -pbc yes
fi

#start=0
#end=40000
#interval=5000
#bin=0.02
#
#for ((i=$start; i<=$end; i+=$interval)); do
#	f=$((i + interval))
#	printi=$(printf "%06d" "$i")
#	printf=$(printf "%06d" "$f")
	
#	out=rdf_PET_ref-$printi-$printf.xvg
#	if [ -f $out ];then
#		echo "PET Reference RDF completed"
#	else
#		gmx_mpi rdf -s md_1.tpr -f md_1.trr -o $out -tu ps -ref 2 -sel 2 3 4 -bin $bin -b $i -e $f -rmax 2.0 -pbc yes
#	fi

#	out=rdf_mal_ref-$printi-$printf.xvg
#        if [ -f $out ];then
#                echo "Malodour Reference RDF completed"
#        else
#                gmx_mpi rdf -s md_1.tpr -f md_1.trr -o $out -tu ps -ref 3 -sel 3 4 -bin $bin -b $i -e $f -rmax 2.0 -pbc yes
#        fi
#done

out=CSR.xvg
if [ -f $out ];then
	echo "Short Range Coulomb energy computed"
else
	echo "52 0"|gmx_mpi energy -f md_1.edr -o CSR.xvg
fi

out=LJSR.xvg
if [ -f $out ];then
        echo "Short Range LJ energy computed"
else
        echo "53 0"|gmx_mpi energy -f md_1.edr -o LJSR.xvg
fi






