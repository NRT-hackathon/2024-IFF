# Molecular Dynamics Simulations of Binding and Trapping of Malodor Molecules in PET Fibers


## Introduction

This project was performed by University of Delaware students, Nikhil Karthikeyan (NK), Kelsey Koutsoukos (KK) and Wanwei Pan (WP) in collaboration with IFF corporation. Malodor molecules represent unpleasant odorous compounds originating from the by-products of bacterial metabolism and accumulation of sweat, sebum and other bodily secretions. It has been noted in past literature that these molecules stick to synthetic fibers more than natural fibers such as cotton by [Munk et al. 2001](https://doi.org/10.1007/s11743-001-0192-2). The goal of the project is to identify the bonding mechanisms and structural evolution of three malodour molecule species, Methyl Butanoic Acid (MBA), Ethyl Butanoic Acid (ETB) and Z-4-Heptenal (HEP) on PolyEthylene Teraphthalate (PET). The distribution of work among the group at UD is shown below and follows the standard set by [NISO](https://credit.niso.org/). 

| NK  | KK   | WP  |
|---|---|---|
| Investigation   | Project administration   | Investigation  |
| Methodology   | Writing - original draft   | Data Curation  |
| Data curation   | Writing - review and editing   | Formal Analysis  |
| Visualization   |    | Writing - original draft  |
| Formal Analysis   |    | Writing - review and editing  |
| Writing - original draft   |    |  |
| Writing - review and editing   |    |  |

This research was supported in part through the use of DARWIN computing system: DARWIN – A Resource for Computational and Data-intensive Research at the University of Delaware and in the Delaware Region, which is supported by NSF under Grant Number: 1919839, Rudolf Eigenmann, Benjamin E. Bagozzi, Arthi Jayaraman, William Totten, and Cathy H. Wu, University of Delaware, 2021, URL:https://udspace.udel.edu/handle/19716/29071

GROMACS was used to perform the molecular dynamics simulations performed during this work. The gromacs user manual can be found [here](https://doi.org/10.5281/zenodo.10721192) while some marquee publications using gromacs can be seen in [Pronk et al. 2013](https://doi.org/10.1093/bioinformatics/btt055), [Abraham et al. 2015](https://doi.org/10.1016/j.softx.2015.06.001) and [Pail et al. 2015](https://doi.org/10.1007/978-3-319-15976-8_1). 

## Data provenance

Three configurations of malodour molecule and PET fiber systems were constructed and simulated in an anhydrous and hydrated state. Three analysis techniques were used to calculate the desired properties and those were the radial distribution function (RDF), cluster size, and binding energy calculated using the Linear Interaction Energy technique (LIE). Within each folder is a data analysis script titled `read_xvg.ipynb`. By opening and running the script in your IDE of choice, the plots used for the report in addition to many others can be generated. 

Within each folder lies `edited_conf.gro` and `md_1.gro` which contains the initial and final configuration for that simulation as read by GROMACS. The appropriate molecule definitions for PET and the malodour molecule are in their respect `.itp` files. All input scripts for the various stages of the simulation are laballed `minim.mdp` for energy minimization, `prod_nvt.mdp` and `prod_npt.mdp` for NVT and NPT equiilibration and `prod_md.mdp` for production simulations respectively. Cluster size relevant files have `clustsize` in their filenames. MSD related files are labelled `msd.vxg`. RDF's are split into species RDF's generating data from the distance between the center of masses of species and bond RDF's which generate data based on the distance between specific atoms in each species. The former RDF type is labelled `rdf_{reference species}` where reference species is the species to which all other species distances are computed. The bond RDF's are labelled `rdf_{bond type}` where bond type is dipole or van der Walls (vdw). 

### Calculation of parameters needed for Linear Interaction Energy calculation

For the LIE technique, the LJ and Coulombic energies for each species relative to water are necessary. To obtain the constants for the malodor molecule, 100 malodor molecules were placed in a $5nm^3$ box with water which was run for 10ns. For the PET chain, the 50mer long chain was placed in the center of a box which was $60 \cdot 3 \cdot 3 nm^3$ and run for 10ns. The stabilization of the necessary constants were ensure by plotting them as a function of time. This was repeated 3 times and the average of the 3 values was used in further LIE operations.

| Species | run1  | run2  | run3 |
|---|---|---|---|
| ETB | `binding_energy/mal_sol/run1/ETB`  | `binding_energy/mal_sol/run2/ETB`  | `binding_energy/mal_sol/run3/ETB` |
| HEP | `binding_energy/mal_sol/run1/HEP`  | `binding_energy/mal_sol/run2/HEP`  | `binding_energy/mal_sol/run3/HEP` |
| MBA | `binding_energy/mal_sol/run1/MBA`  | `binding_energy/mal_sol/run2/MBA`  | `binding_energy/mal_sol/run3/MBA` |
| PET | `binding_energy/pet_sol/run1/`  | `binding_energy/pet_sol/run2/`  | `binding_energy/pet_sol/run3/` |

The data to be plotted are located in `CSR.xvg` for the coulombic constant and `LJSR.xvg` for the LJ constant.

### Single chain with single molecules around it

Configuration 1 is defined as a single PET chain with 50 repeat units placed in the middle of a simulation box, followed by placing 1 copy of each malodour molecule 1.5nm from the PET chain, 5nm from each subsequent malodour molecule. This allowed us to determine a general idea of the interaction strengths and trends of the malodour molecules and how the presence of water affected these properties. This data is located in the directory titled `single_chain-single_molecule` with anhydrous and hydrated states named accordingly in the directory. All directories are listed for runs in the table below.

| Hydration  | run1  | run2  | run3 |
|---|---|---|---|
| Anhydrous | `single_chain-single_molecule/anhydrous/run1`  | `single_chain-single_molecule/anhydrous/run2`  | `single_chain-single_molecule/anhydrous/run2`  |
| Hydrated  | `single_chain-single_molecule/hydrated/run1`   | `single_chain-single_molecule/hydrated/run1`   | `single_chain-single_molecule/hydrated/run1`   |

### Single chain with a droplet on it

Configuration 2 is defined as a single PET chain with 50 repeat units placed in the middle of a simulation box, followed by placing 300 malodour molecules in a droplet of radius 2nm at the center of the chain. This experiment was performed separately for each malodour molecule so as to quantitatively determine the interaction strengths, cluster behavior and bonding interactions underpinning the observed behaviour. This data is located in the directory titled `single_chain-droplet` with anhydrous and hydrated states named accordingly in the directory. All directories are listed for runs in the table below for each malodour molecule

| Hydration  | run1  | run2  | run3 |
|---|---|---|---|
| Anhydrous | `single_chain-droplet/anhydrous/run1/ETB`  | `single_chain-droplet/anhydrous/run2/ETB`  | `single_chain-droplet/anhydrous/run3/ETB`  |
| Hydrated  | `single_chain-droplet/hydrated/run1/ETB`   | `single_chain-droplet/hydrated/run2/ETB`   | `single_chain-droplet/hydrated/run3/ETB`   |

| Hydration  | run1  | run2  | run3 |
|---|---|---|---|
| Anhydrous | `single_chain-droplet/anhydrous/run1/HEP`  | `single_chain-droplet/anhydrous/run2/HEP`  | `single_chain-droplet/anhydrous/run3/HEP`  |
| Hydrated  | `single_chain-droplet/hydrated/run1/HEP`   | `single_chain-droplet/hydrated/run2/HEP`   | `single_chain-droplet/hydrated/run3/HEP`   |

| Hydration  | run1  | run2  | run3 |
|---|---|---|---|
| Anhydrous | `single_chain-droplet/anhydrous/run1/MBA`  | `single_chain-droplet/anhydrous/run2/MBA`  | `single_chain-droplet/anhydrous/run3/MBA`  |
| Hydrated  | `single_chain-droplet/hydrated/run1/MBA`   | `single_chain-droplet/hydrated/run2/MBA`   | `single_chain-droplet/hydrated/run3/MBA`   |

### Single fibril with three droplets on it

Configuration 3 is defined as a single PET fibril placed in the middle of a simulation box, followed by placing three droplets of 150 malodour molecules each in a droplet of radius 1.5nm with each droplet spaced 20nm apart. One PET fibril is constructed of 4 PET chains of 50 repeat units placed 0.4nm from each other, with benzene rings facing each other. This allowed us to determine a general idea of the interaction strengths and trends of the malodour molecules and how the presence of water affected these properties. This data is located in the directory titled `square_fibril_droplets` with anhydrous and hydrated states named accordingly in the directory.

| Hydration  | run1  | run2  | run3 |
|---|---|---|---|
| Anhydrous | `square_fibril_droplets/anhydrous/run1/ETB`  | `square_fibril_droplets/anhydrous/run2/ETB`  | `square_fibril_droplets/anhydrous/run3/ETB`  |
| Hydrated  | `square_fibril_droplets/hydrated/run1/ETB`   | `square_fibril_droplets/hydrated/run2/ETB`   | `square_fibril_droplets/hydrated/run3/ETB`   |

| Hydration  | run1  | run2  | run3 |
|---|---|---|---|
| Anhydrous | `square_fibril_droplets/anhydrous/run1/HEP`  | `square_fibril_droplets/anhydrous/run2/HEP`  | `square_fibril_droplets/anhydrous/run3/HEP`  |
| Hydrated  | `square_fibril_droplets/hydrated/run1/HEP`   | `square_fibril_droplets/hydrated/run2/HEP`   | `square_fibril_droplets/hydrated/run3/HEP`   |

| Hydration  | run1  | run2  | run3 |
|---|---|---|---|
| Anhydrous | `square_fibril_droplets/anhydrous/run1/MBA`  | `square_fibril_droplets/anhydrous/run2/MBA`  | `square_fibril_droplets/anhydrous/run3/MBA`  |
| Hydrated  | `square_fibril_droplets/hydrated/run1/MBA`   | `square_fibril_droplets/hydrated/run2/MBA`   | `square_fibril_droplets/hydrated/run3/MBA`   |