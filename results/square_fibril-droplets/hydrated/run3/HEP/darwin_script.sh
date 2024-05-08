#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --ntasks-per-node=32
#SBATCH --mem-per-cpu=4096M
#SBATCH --partition=idle
#SBATCH --time=0-24:00:00
#SBATCH --job-name=HEP_square_fibril

#SBATCH --export=NONE

#set -e

vpkg_require gromacs/2023.2:mpi

cd $SLURM_SUBMIT_DIR

last_part=$(basename "$PWD")

echo "rerun_md_$last_part.mdp"

GROMACS_DOUBLE_PRECISION=YES
GROMACS_MDRUN_FLAGS=()

if [ -f md_1.tpr ]; then
	gmx_mpi mdrun -s md_1.tpr -cpi md_1.cpt -deffnm md_1 -append -pin on
        echo "15 0"|gmx_mpi energy -f md_1.edr -o t_prod.xvg
else
	./eqm.sh $last_part 450
fi

./post_process.sh
