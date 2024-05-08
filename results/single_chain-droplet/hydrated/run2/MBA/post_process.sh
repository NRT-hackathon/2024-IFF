#!/bin/bash -l

last_part=$(basename "$PWD")
parent_directory=$(dirname "$PWD")
parent_directory=$(dirname "$parent_directory")
hydration=$(basename "$parent_directory")

if [ "$last_part" = "MBA" ]; then
    cut=0.55
    elj_mal=-1633.729
    eqq_mal=-8337.685
    c_aliph="t opls_135 | t opls_136 | t opls_137"
    o_dipole="t opls_269 | t opls_267"
    c_dipole="t opls_267"
elif [ "$last_part" = "HEP" ]; then
    cut=0.65
    elj_mal=-2248.105
    eqq_mal=-15230.426
    c_aliph="t opls_135 | t opls_136 | t opls_142"
    o_dipole="t opls_278"
    c_dipole="t opls_277"
elif [ "$last_part" = "ETB" ]; then
    cut=0.6
    elj_mal=-1648.059
    eqq_mal=-2399.477
    c_aliph="t opls_135 | t opls_136"
    o_dipole="t opls_466 | t opls_467"
    c_dipole="t opls_465"
else
    echo "None of the conditions matched"
    cut=0.6
fi

ref1=2
ref2=3
if [ "$hydration" = "hydrated" ];then
    sel1="2 3 4"
    sel2="3 4"
    ref3=8
    sel3="8 7 9"
    ref4=9
    sel4="9 10 7"
else
    sel1="2 3"
    sel2="3"
    ref3=5
    sel3="5 4 6"
    ref4=6
    sel4="6 7 4"
fi

c_aro="t opls_145"

elj_pet=-2827.765
eqq_pet=-5292.352

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
	gmx_mpi msd -s md_1.tpr -f md_1.trr -o msd.xvg -sel 2 3 -maxtau 1000 -pbc yes
fi


out=nclust.xvg
if [ -f $out ];then
        echo "Cluster size calculated"
else
	echo -e "keep 3 \n q" | gmx_mpi make_ndx -f md_1.tpr -o mal_com.ndx
	gmx_mpi clustsize -f md_1.trr -s md_1.tpr -n mal_com.ndx -nc nclust.xvg -ac avgclustsize.xvg -mc maxclustsize.xvg -b 0 -e 40000 -pbc yes -cut $cut
fi

out=atom_groups.ndx                                                                                                                       
if [ -f $out ];then                                                                                                                               
	echo "Atom groups sorted"                                                                                                         
else                                                                                                                                              
	echo -e "$c_dipole name dipole C\n$o_dipole name dipole O \n$c_aliph name aliphatic C\n$c_aro aromatic C\nq" | gmx_mpi make_ndx -f md_1.tpr -o atom_groups.ndx
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
		gmx_mpi rdf -s md_1.tpr -f md_1.trr -o $out -tu ps -ref $ref1 -sel $sel1 -bin $bin -b $i -e $f -rmax 3.0 -pbc yes -selrpos whole_res_com -seltype whole_res_com
	fi

	out=rdf_mal_ref-$printi-$printf.xvg
        if [ -f $out ];then
                echo "Malodour Reference RDF completed"
        else
                gmx_mpi rdf -s md_1.tpr -f md_1.trr -o $out -tu ps -ref $ref2 -sel $sel2 -bin $bin -b $i -e $f -rmax 3.0 -pbc yes -selrpos whole_res_com -seltype whole_res_com
        fi
	
	out=rdf_dipole_atoms-$printi-$printf.xvg
        if [ -f $out ];then
                echo "Dipole RDF calculated"
        else
                gmx_mpi rdf -s md_1.tpr -f md_1.trr -n atom_groups.ndx -o $out -tu ps -b $i -e $f -ref $ref3 -sel $sel3 -rmax 2.0 -pbc yes
        fi
        out=rdf_vdw_atoms-$printi-$printf.xvg
        if [ -f $out ];then
                echo "Dipole RDF calculated"
        else
                gmx_mpi rdf -s md_1.tpr -f md_1.trr -n atom_groups.ndx -o $out -tu ps -b $i -e $f -ref $ref4 -sel $sel4 -rmax 2.0 -pbc yes         	
	fi

done

if [ "$hydration" = "hydrated" ]; then
    if [ -f lie_mal.xvg ];then
        echo "Rerun complete"
    else 	
	gmx_mpi grompp -f rerun_md_$last_part.mdp -c md_1.tpr -p topol.top -o Gbind.tpr
    	gmx_mpi mdrun -deffnm Gbind -pin on -rerun md_1.trr
        gmx_mpi lie -f Gbind.edr -o lie_mal.xvg -Elj $elj_mal -Eqq $eqq_mal -ligand $last_part # MAL - PET // MAL-SOL energies in
        gmx_mpi lie -f Gbind.edr -o lie_sol.xvg -Elj $elj_mal -Eqq $eqq_mal -ligand SOL # SOL - PET // MBA-SOL energies in
        gmx_mpi lie -f Gbind.edr -o lie_pet.xvg -Elj $elj_pet -Eqq $eqq_pet -ligand SOL # MBA - SOL // PET-SOL energies in
        rm Gbind*
    fi
else
    echo "Water not present. Binding energy not calculated"
fi
