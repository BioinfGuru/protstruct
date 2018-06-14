# Protein homology modelling and molecular dynamics

## Contents

1 [Using Modeler](#using-modeller)

2 [Using QwikMD](#using-qwikmd)
* [Qwik Start](#qwik-start)
* [VMD folder](#vmd-folder)
* [Considering solvation](#considering-solvation)
* [Atomselect](#atomselect)
* [Show hydrophobic molecules](#show-hydrophobic-molecules)
* [Graphics representations](#graphics-representations)
* [PDB columns](#pdb-columns)
* [The infamous patch grid error](#the-infamous-patch-grid-error)

## Using Modeller

Modeller is used to model the protein structure of a target protein based on the protein structure of a template protein

1 [Download & Installation](https://salilab.org/modeller/download_installation.html) (Key: MODELIRANJE)

2 Prepare the target
* Get protein sequence in fasta format from [uniprot](http://www.uniprot.org/)

3 Prepare the template
* [BLASTp](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE=Proteins) the target sequence against PDB to find a suitable template
* Get the pdb id of the template from the blastp results
* Search the [protein data bank](https://www.rcsb.org/) with the pdb id
* Download the pdb file & fasta sequence

4 Alignment
* Perform pairwise sequence alignment with [Emboss Matcher](http://www.ebi.ac.uk/Tools/psa/emboss_matcher/)
* Download the alignment file

5 Prepare modeller files
* Download the 2 files in the modeller folder (targetname.ali & targetname.py)
* In total, the .py file requires 4 changes and the .ali file requires 7 changes
* In both files replace all instances of "targetname" and "templatename"
* In the targetname.ali file, insert the aligned sequences (must be same length, truncate ends if necessary)
* NB: change nothing else in the .ali file, even the ":.:.:." have functions

6 Run modeller
* The working directory should now contain the pdb file and the edited .ali and .py files only
```sh
cd [working directory]
mod9.20 [targetname].py
```
* If you get an error referring to "mismatched sequences" or "unequal sequence length", just open the log file to find the mismatch, then edit the .ali file accordingly

7 Select best model
* You have instructed modeller to build 5 models ("a.ending_model = 5" in .py file)
* Modeller has created a pdf file for each model and a log file
* The most favourable model is the one with the lowest free energy
* Property Density Function is the measure of free energy with the units "molpdf"
* Scroll to the end of the log file where the 5 models
* The model with the lowest "molpdf" value is your best model
* To quick check the best model, load and align the model and template pdfs in [Pymol](https://pymol.org/2/)

8 Model Evaluation
* Ramachandran plot with [Rampage](http://mordred.bioc.cam.ac.uk/~rapper/rampage.php)
* Analyze non-bonded interactions with [Errat](http://servicesn.mbi.ucla.edu/ERRAT/)
* Determine the compatibility of an atomic model (3D) with its own amino acid sequence (1D) with [Verify3D](http://servicesn.mbi.ucla.edu/Verify3d/)
* Multiple evaluation toolbox with [SAVES](http://servicesn.mbi.ucla.edu/SAVES/)

## Using QwikMD

* [Download VMD](http://www.ks.uiuc.edu/Development/Download/download.cgi?PackageName=VMD)
* [Install VMD](http://www.ks.uiuc.edu/Research/vmd/current/ig/node6.html)

As a novice to molecular dynamics (MD), I have spent a few weeks following the tutorials and jumping in at the deep end. Take my advice, [QwikMD](http://www.ks.uiuc.edu/Research/vmd/plugins/qwikmd/) is by far the best place to start. The image below is one of the [QwikMD workflows](http://www.ks.uiuc.edu/Research/qwikmd/tutorial/) on membrane proteins but for [more extensive tutorials](http://www.ks.uiuc.edu/Training/Tutorials/) are also available

<img src="https://github.com/roonysgalbi/protstruct/blob/master/vmd/qwikmd_membrane_proteins.png">

### Qwik Start
* Extensions --> simulations --> QwikMD
* Easy Run --> load example.pdb
* Chain/Type selection : all
* Molecular dynamikcs: explicit, 0.15mol/L, NaCl
* Temp 27C
* Simulation Time: 10.0
* Simulation setup --> "save" --> select working directory + provide a file prefix --> "save"
* Prepare
* Copy and paste all 5 lines of Periodic Boundary Conditions (including header) from previous step into prefix/run/prefixqwikmd_production_1.conf
* Start equilibration
* View results: 
```tcl
mol delete all
mol load psf prefix_QwikMD.psf dcd qwikmd_equilibration_0.dcd
```

### VMD folder
| file | contents |
|------|----------|
| [instructions_cytosolic.txt](https://github.com/roonysgalbi/protstruct/blob/master/vmd/instructions_cytosolic.txt) | Commands to perform MD in VMD on cytosolic proteins |
| [instructions_membranebound.txt](https://github.com/roonysgalbi/protstruct/blob/master/vmd/instructions_membranebound.txt) | Commands to perform MD in VMD on membrane bound proteins |
| [prepsystem.tcl](https://github.com/roonysgalbi/protstruct/blob/master/vmd/prepsystem.tcl) | Example script to perform MD in VMD on membrane bound proteins|
| [getBoxSize.tcl](https://github.com/roonysgalbi/protstruct/blob/master/vmd/getBoxSize.tcl) | Determines periodic boundary conditions for config file|
| [template.config.namd](https://github.com/roonysgalbi/protstruct/blob/master/vmd/template.config.namd) | Sets all paramaters required for a single MD run in VMD |

### Considering solvation
Solvation tools tend to under solvate resulting in a system with too small density that causes [the infamous patch grid error](#the-infamous-patch-grid-error). Another more complex option is to first use DOWSER (to place buried waters), then Helmut Grubmuller's [SOLVATE](https://www.mpibpc.mpg.de/grubmueller/solvate) to generate a closely contoured solvent bubble around the solute. Then use VMD solvate to get the final cube. The main problem with VMD solvate is its inability to do a good job with matching the biomolecular surface, which is where DOWSER and Grubmuller SOLVATE excel. There is now a vmd interface for DOWSER.

### Atomselect
Commands to use [atomselect](http://www.ks.uiuc.edu/Research/vmd/vmd-1.7/ug/node181.html) in TK console
```tcl
set sel [atomselect top "water"] # selects all water molecules
$sel num # counts number of atoms in selection
$sel get name # gets names of all atoms in selection
$sel get {name backbone} # getting multiple attributes from each atom in selection
$sel get {x y z} # get coords of each atom in selection
$sel set {x y z} {{1.6 0 0}} # set coords of all atoms in selection
$sel set beta 0 # set beta of all atoms in selection --> now colour by beta
```
### Show hydrophobic molecules
```tcl
mol delete all
mol load psf example.psf pdb example.pdb
set all [atomselect top all]
$all set beta 2
set protein [atomselect top protein]
$protein set beta 1
set hydro [atomselect top hydrophobic]
$hydro set beta 0
#tk console --> graphics --> representations --> protein, beta, new cartoon 
```
### Graphics representations
| selected atoms | coloring method | drawing method |
|----------------|-----------------|----------------|
| all not water | name | lines |
| protein	| sec struct | newcartoon |
| (chain X and resid 102) | colorID	4 | surf |
| water | name | points |

### PDB columns
| column  |   3  |    4    |   5   |   11    |   12  |
|---------|------|---------|-------|---------|-------|
| content | name | resname | resid | segname (2nd last) | segid (last) |

### The infamous patch grid error

1 Cause: 

The cell is shrinking too much. The system was started from a simulation box that is significantly larger than that of the equilibrated system. The reason why it shrinks so much initially, is that solvation tools under solvate resulting in a system with too small density. You get the error because NAMD only calculates the patch grid at the beginning of the simulation. 

2 Solution: 

Re-run but in protocol set temp to -213C and time to 0.5ns and leave overnight. The low temp just speeds up the first part of the simulation. The short time gives the tails a chance to reorient before the box starts moving. Stop after restart files are created. Re-start equilibration simulation again with the last configuration (restart files). Rinse and repeat until eventually you will get a box with relatively stable density, which will allow you to run long simulations without the error.

3 To re-start: 
* Create a backup just in case something goes wrong
* sudo vmd
* rename qwikmd_equilibration_0.log so it won't be overwritten
* simulation setup --> load --> select prefix.qwikmd
* loading trajectories --> select qwikmd_equilibration_0 --> ok
* reset time to 10.0
* start equilibration simulation (may produce error, ignore, press button again)
* If reset error occurs again --> re-start with time at 0.5 until new restart file created
* IF no reset error --> re-start with temp at 27C

4 To know when the error has not occured:

After beginning the program there is always many lines stating "MINIMIZER RESTARTING CONJUGATE GRADIENT ALGORITHM DUE TO POOR PROGRESS" until finally, it will say "TCL: Setting parameter langevinpistontemp to 60, TCL: Running for 500 steps". The error then occurs within a few min on the next line "FATAL ERROR". If no error, it will write multiple lines beginning with "PRESSURE", "GPRESSURE", "PRESSAVG".
