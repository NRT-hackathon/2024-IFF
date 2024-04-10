#!/bin/bash

## some post processing ##
gmx rdf -s md_1.tpr -f md_1.trr -o rdf.xvg -tu ps -rmax 2.5 -ref 2 -sel 3 4 5 2 -bin 0.05
./xvg_convert.sh rdf
gmx rdf -s md_1.tpr -f md_1.trr -o rdf_LR.xvg -tu ps -cut 0.25 -rmax 2.5 -ref 2 -sel 3 4 5 2 -bin 0.05
./xvg_convert.sh rdf_LR
gmx rdf -s md_1.tpr -f md_1.trr -o rdf_mal1.xvg -tu ps -cut 0.25 -rmax 2.5 -ref 3 -sel 3 4 5 2 -bin 0.05
./xvg_convert.sh rdf_mal1
gmx rdf -s md_1.tpr -f md_1.trr -o rdf_mal2.xvg -tu ps -cut 0.25 -rmax 2.5 -ref 4 -sel 3 4 5 2 -bin 0.05
./xvg_convert.sh rdf_mal2
gmx rdf -s md_1.tpr -f md_1.trr -o rdf_mal3.xvg -tu ps -cut 0.25 -rmax 2.5 -ref 5 -sel 3 4 5 2 -bin 0.05
./xvg_convert.sh rdf_mal3
gmx msd -f md_1.trr -s md_1.tpr -o msd.xvg -sel 3 4 5 2 -maxtau 1000
./xvg_convert.sh msd