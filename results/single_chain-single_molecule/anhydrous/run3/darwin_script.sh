#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --ntasks-per-node=16
#SBATCH --mem-per-cpu=4096M
#SBATCH --partition=idle
#SBATCH --time=0-12:00:00
#SBATCH --job-name=single_PET_production

#SBATCH --export=NONE

#set -e

vpkg_require gromacs/2023.2:mpi

cd $SLURM_SUBMIT_DIR

GROMACS_DOUBLE_PRECISION=YES
GROMACS_MDRUN_FLAGS=()

if [ -f md_1.tpr ]; then
        gmx_mpi mdrun -s md_1.tpr -cpi md_1.cpt -deffnm md_1 -append -pin on
        echo "15 0"|gmx_mpi energy -f md_1.edr -o t_prod.xvg
else
        ./eqm.sh

fi

