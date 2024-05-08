#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --ntasks-per-node=8
#SBATCH --mem-per-cpu=4096M
#SBATCH --partition=idle
#SBATCH --time=0-03:00:00
#SBATCH --job-name=ETB_solution

#SBATCH --export=NONE

#set -e

vpkg_require gromacs/2023.2:mpi

cd $SLURM_SUBMIT_DIR

GROMACS_DOUBLE_PRECISION=YES
GROMACS_MDRUN_FLAGS=()

#./eqm.sh ETB 200
if [ -f md_1.tpr ]; then
	gmx_mpi mdrun -s md_1.tpr -cpi md_1.cpt -deffnm md_1 -append -pin on
	echo "15 0"|gmx_mpi energy -f md_1.edr -o t_prod.xvg
else
	./eqm.sh 50 5 ETB 100

fi
