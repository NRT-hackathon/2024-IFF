#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --ntasks-per-node=32
#SBATCH --mem-per-cpu=4096M
#SBATCH --partition=idle
#SBATCH --time=0-24:00:00
#SBATCH --job-name=single_PET_production

#SBATCH --export=NONE

#set -e

vpkg_require gromacs/2023.2:mpi

cd $SLURM_SUBMIT_DIR

GROMACS_DOUBLE_PRECISION=YES
GROMACS_MDRUN_FLAGS=()

./eqm.sh
