#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --ntasks-per-node=16
#SBATCH --mem-per-cpu=4096M
#SBATCH --partition=idle
#SBATCH --time=0-08:00:00
#SBATCH --job-name=post_process

#SBATCH --export=NONE

#set -e

vpkg_require gromacs/2023.2:mpi

cd $SLURM_SUBMIT_DIR

GROMACS_DOUBLE_PRECISION=YES
GROMACS_MDRUN_FLAGS=()

#out=md_1_noPBC.trr
#if [ -f $out ];then
#	echo "Periodic BC corrected"
#else
#	echo "2 0"|gmx_mpi trjconv -s md_1.tpr -f md_1.trr -o $out -pbc mol -center
#fi

last_part=$(basename "$PWD")
parent_directory=$(dirname "$PWD")
#parent_directory=$(dirname "$parent_directory")
hydration=$(basename "$parent_directory")

PET=2
MBA=3
HEP=4
ETB=5
SOL=6
if [ "$hydration" = "hydrated" ];then
    sel1="$PET $MBA $HEP $ETB $SOL"
    sel2="$MBA $HEP $ETB $SOL"
    sel3="$HEP $ETB $SOL"
    sel4="$ETB $SOL"
else
    sel1="$PET $MBA $HEP $ETB"
    sel2="$MBA $HEP $ETB"
    sel3="$HEP $ETB"
    sel4="$ETB"
fi

out=msd.xvg
if [ -f $out ];then
	echo "MSD calculated"
else
	gmx_mpi msd -s md_1.tpr -f md_1.trr -o $out -sel $sel1 -maxtau 1000 -pbc yes
fi

out=atom_groups.ndx
if [ -f $out ];then
	echo "Atom groups sorted"
else
        mba_c_aliph="t opls_135 | t opls_136 | t opls_137"
        mba_o_dipole="t opls_269 | t opls_267"
        mba_c_dipole="t opls_267"

        hep_c_aliph="t opls_135 | t opls_136 | t opls_142"
        hep_o_dipole="t opls_278"
        hep_c_dipole="t opls_277"

        etb_c_aliph="t opls_135 | t opls_136"
        etb_o_dipole="t opls_466 | t opls_467"
        etb_c_dipole="t opls_465"

        c_aro="t opls_145"
	
	echo -e "$mba_c_dipole\n$mba_o_dipole\n$mba_c_aliph\n$c_aro\nq" | gmx_mpi make_ndx -f md_1.tpr -o mba_atom_groups.ndx
        echo -e "$hep_c_dipole\n$hep_o_dipole\n$hep_c_aliph\n$c_aro\nq" | gmx_mpi make_ndx -f md_1.tpr -o hep_atom_groups.ndx
	echo -e "$etb_c_dipole\n$etb_o_dipole\n$etb_c_aliph\n$c_aro\nq" | gmx_mpi make_ndx -f md_1.tpr -o etb_atom_groups.ndx
fi

start=0
end=40000
interval=5000
bin=0.02

for ((i=$start; i<=$end; i+=$interval)); do
	f=$((i + interval))
	printi=$(printf "%06d" "$i")
	printf=$(printf "%06d" "$f")
	
	out=rdf_PET_ref-$printi-$printf.xvg
	if [ -f $out ];then
		echo "PET Reference RDF completed"
	else
		gmx_mpi rdf -s md_1.tpr -f md_1.trr -o $out -tu ps -ref 2 -sel $sel1 -bin $bin -b $i -e $f -rmax 2.0 -pbc yes -selrpos atom -seltype atom
	fi

	out=rdf_MBA_ref-$printi-$printf.xvg
        if [ -f $out ];then
                echo "MBA Reference RDF completed"
        else
                gmx_mpi rdf -s md_1.tpr -f md_1.trr -o $out -tu ps -ref 3 -sel $sel2 -bin $bin -b $i -e $f -rmax 2.0 -pbc yes -selrpos whole_res_com -seltype whole_res_com
        fi
	
        out=rdf_HEP_ref-$printi-$printf.xvg
        if [ -f $out ];then
                echo "HEP Reference RDF completed"
        else
                gmx_mpi rdf -s md_1.tpr -f md_1.trr -o $out -tu ps -ref 4 -sel $sel3 -bin $bin -b $i -e $f -rmax 2.0 -pbc yes -selrpos whole_mol_com -seltype whole_mol_com
        fi

        out=rdf_ETB_ref-$printi-$printf.xvg
        if [ -f $out ];then
                echo "ETB Reference RDF completed"
        else
                gmx_mpi rdf -s md_1.tpr -f md_1.trr -o $out -tu ps -ref 5 -sel $sel4 -bin $bin -b $i -e $f -rmax 2.0 -pbc yes -selrpos whole_mol_com -seltype whole_mol_com
        fi
	out=rdf_ETB_dipole_atoms-$printi-$printf.xvg
	if [ -f $out ];then
		echo "Dipole RDF calculated"
	else
		gmx_mpi rdf -s md_1.tpr -f md_1.trr -n etb_atom_groups.ndx -o $out -tu ps -b $i -e $f -ref "OPLS_466_OPLS_467"  -sel "OPLS_145" -rmax 2.0 -pbc yes
	fi
	out=rdf_ETB_vdw_atoms-$printi-$printf.xvg
        if [ -f $out ];then
                echo "VdW RDF calculated"
        else
                gmx_mpi rdf -s md_1.tpr -f md_1.trr -n etb_atom_groups.ndx -o $out -tu ps -b $i -e $f -ref "OPLS_135_OPLS_136"  -sel "OPLS_145" -rmax 2.0 -pbc yes
        fi

        out=rdf_HEP_dipole_atoms-$printi-$printf.xvg
        if [ -f $out ];then
                echo "Dipole RDF calculated"
        else
                gmx_mpi rdf -s md_1.tpr -f md_1.trr -n hep_atom_groups.ndx -o $out -tu ps -b $i -e $f -ref "OPLS_278"  -sel "OPLS_145" -rmax 2.0 -pbc yes
        fi
        out=rdf_HEP_vdw_atoms-$printi-$printf.xvg
        if [ -f $out ];then
                echo "VdW RDF calculated"
        else
                gmx_mpi rdf -s md_1.tpr -f md_1.trr -n hep_atom_groups.ndx -o $out -tu ps -b $i -e $f -ref "OPLS_135_OPLS_136_OPLS_142"  -sel "OPLS_145" -rmax 2.0 -pbc yes
        fi

        out=rdf_MBA_dipole_atoms-$printi-$printf.xvg
        if [ -f $out ];then
                echo "Dipole RDF calculated"
        else
                gmx_mpi rdf -s md_1.tpr -f md_1.trr -n mba_atom_groups.ndx -o $out -tu ps -b $i -e $f -ref "OPLS_269_OPLS_267"  -sel "OPLS_145" -rmax 2.0 -pbc yes
        fi
        out=rdf_MBA_vdw_atoms-$printi-$printf.xvg
        if [ -f $out ];then
                echo "VdW RDF calculated"
        else
                gmx_mpi rdf -s md_1.tpr -f md_1.trr -n mba_atom_groups.ndx -o $out -tu ps -b $i -e $f -ref "OPLS_135_OPLS_136_OPLS_137"  -sel "OPLS_145" -rmax 2.0 -pbc yes
        fi
done

if [ "$hydration" = "hydrated" ]; then
    if [ -f lie_mal_ETB.xvg ];then
        echo "Rerun complete"
    else
        gmx_mpi grompp -f rerun_md.mdp -c md_1.tpr -p topol.top -o Gbind.tpr
        gmx_mpi mdrun -deffnm Gbind -pin on -rerun md_1.trr
	
	### MBA ###
        gmx_mpi lie -f Gbind.edr -o lie_mal_MBA.xvg -Elj -1633.729 -Eqq -8337.685 -ligand MBA # MAL - PET // MAL-SOL energies in
        gmx_mpi lie -f Gbind.edr -o lie_sol_MBA.xvg -Elj -1633.729 -Eqq -8337.685 -ligand SOL # SOL - PET // MBA-SOL energies in
        gmx_mpi lie -f Gbind.edr -o lie_pet_MBA.xvg -Elj -2827.765 -Eqq -5292.352 -ligand SOL # MBA - SOL // PET-SOL energies in
        ###########
	### HEP ###
        gmx_mpi lie -f Gbind.edr -o lie_mal_HEP.xvg -Elj -2248.105 -Eqq -15230.426 -ligand HEP # MAL - PET // MAL-SOL energies in
        gmx_mpi lie -f Gbind.edr -o lie_sol_HEP.xvg -Elj -2248.105 -Eqq -15230.426 -ligand SOL # SOL - PET // MBA-SOL energies in
        gmx_mpi lie -f Gbind.edr -o lie_pet_HEP.xvg -Elj -2827.765 -Eqq -5292.352 -ligand SOL # MBA - SOL // PET-SOL energies in
	###########
	### ETB ###
        gmx_mpi lie -f Gbind.edr -o lie_mal_ETB.xvg -Elj -1648.059 -Eqq -2399.477 -ligand ETB # MAL - PET // MAL-SOL energies in
        gmx_mpi lie -f Gbind.edr -o lie_sol_ETB.xvg -Elj -1648.059 -Eqq -2399.477 -ligand SOL # SOL - PET // MBA-SOL energies in
        gmx_mpi lie -f Gbind.edr -o lie_pet_ETB.xvg -Elj -2827.765 -Eqq -5292.352 -ligand SOL # MBA - SOL // PET-SOL energies in
	###########	
        rm Gbind*
    fi
else
    echo "Water not present. Binding energy not calculated"
fi
