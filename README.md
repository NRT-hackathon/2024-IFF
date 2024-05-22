# 2024-IFF
This repository contains the input files, molecule topology, initial and final configuration, data and postprocessing scripts used in the data generation and analysis for the project titled Molecular Dynamics Simulations of the Binding and Trapping of Malodor Molecules in PET fibers conducted by students in the NRT-MIDAS program from the University of Delaware in conjunction with staff from International Flavors and Fragrances (IFF)

The `results` folder contains the the file `data-provenance.md` which details the location and type of data as well as the data obtained from simulations performed. Within each folder in `results` resides `read_xvg.ipynb` which generates plots shown in the report in addition to many others used for validation of run status. The following python packages are required to run these scripts

1. `numpy`
2. `matplotlib`
3. `glob`
4. `pwlf`
5. `scipy`

The forcefield used for these simulations is an unmodified OPLS-AA forcefield that comes with GROMACS 2024.1. A copy of it is located within `run_files/forcefields`. Initial configurations, molecule topologies and coordinate files used for this project were created using packmol and are located within the folder `run_files/molecule_definitions`. Templates of the run scripts used can be found in `run_files/parameters` although these were modified to fit the run program defined in the report. Some scripts used for basic automation are located in `run_files/scripts` although the most updated versions are located in the subdirectories within `results`.
