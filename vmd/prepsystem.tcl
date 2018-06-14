######################
# create protein psf #
######################

place pdb file in wd
terminal --> sudo vmd --> vmd main --> extensions --> tk console
mol new vamp2wild_model.pdb
vmd main --> extensions --> modelling --> automatic psf builder
load input files --> everything --> guess and split
create chains --> apply patches and finish
file delete vamp2wild_model_autopsf.log
file delete vamp2wild_model_autopsf_formatted.pdb

######################
# membrane insertion #
######################

mol delete all
package require membrane
membrane -l POPC -x 120 -y 120 -o popc
set popc [atomselect top all]
mol load psf vamp2wild_model_autopsf.psf pdb vamp2wild_model_autopsf.pdb
set prot [atomselect top all]
$popc moveby [vecinvert [measure center $popc weight mass]]
$popc writepdb popc_TEMP.pdb
set tmd [atomselect top "protein and resid 93 to 115"]
$prot moveby [vecinvert [measure center $tmd weight mass]]
$prot move [transaxis x -75]
$prot writepdb prot_TEMP.pdb
mol delete all
package require psfgen
resetpsf
readpsf popc.psf
coordpdb popc_TEMP.pdb
readpsf vamp2wild_model_autopsf.psf
coordpdb prot_TEMP.pdb
writepsf vamp2wild_popc_raw.psf
writepdb vamp2wild_popc_raw.pdb
file delete vamp2wild_model_autopsf.psf
file delete vamp2wild_model_autopsf.pdb
file delete popc.pdb
file delete popc.psf
file delete prot_TEMP.pdb
file delete popc_TEMP.pdb

###################################
# remove all water and bad lipids #
###################################

mol delete all
mol load psf vamp2wild_popc_raw.psf pdb vamp2wild_popc_raw.pdb
set POPC [atomselect top "resname POPC"]
set all [atomselect top all]
$all set beta 0
set badlipid [atomselect top "resname POPC and same residue as (within 0.6 of protein and resid 93 to 115)"]
$badlipid set beta 1
set seglistlipid [$badlipid get segid]
set reslistlipid [$badlipid get resid]
set badwater [atomselect top water]
set seglistwater [$badwater get segid]
set reslistwater [$badwater get resid]
mol delete all
package require psfgen
resetpsf
readpsf vamp2wild_popc_raw.psf
coordpdb vamp2wild_popc_raw.pdb
foreach segid $seglistlipid resid $reslistlipid {delatom $segid $resid}
foreach segid $seglistwater resid $reslistwater {delatom $segid $resid}
writepsf vamp2wild_popc.psf
writepdb vamp2wild_popc.pdb
file delete vamp2wild_popc_raw.psf
file delete vamp2wild_popc_raw.pdb

######################
# solvate the system #
######################

# Solvation tools tend to under solvate resulting in a system with too small density
# that causes a fatal error later (solution below). Another more complex option is:
# First use DOWSER (to place buried waters), then Helmut Grubmuller's SOLVATE 
# (http://www.mpibpc.mpg.de/home/grubmueller/downloads/solvate/index.html) 
# to generate a closely contoured solvent bubble around the solute, and 
# then use VMD solvate to get the final cube. The main problem with VMD 
# solvate is its inability to do a good job with matching the biomolecular 
# surface, which is where DOWSER and Grubmuller SOLVATE excel. There is 
# now a vmd interface for DOWSER.

mol delete all
mol load psf vamp2wild_popc.psf pdb vamp2wild_popc.pdb
package require solvate
solvate vamp2wild_popc.psf vamp2wild_popc.pdb -t 10 -x 0 +x 0 -y 0 +y 0 +z 5 -o solv_TEMP
mol delete all
mol load psf solv_TEMP.psf pdb solv_TEMP.pdb
set tmd [atomselect top "protein and resid 93 to 115"]
set minmax_tmd [measure minmax $tmd]
set badwater [atomselect top "water not (z<[lindex $minmax_tmd 0 2] or z>[lindex $minmax_tmd 1 2])"]
set seglist [$badwater get segid]
set reslist [$badwater get resid]
mol delete all
package require psfgen
resetpsf
readpsf solv_TEMP.psf
coordpdb solv_TEMP.pdb
foreach segid $seglist resid $reslist {delatom $segid $resid}
writepdb vamp2wild_popc_solv.pdb
writepsf vamp2wild_popc_solv.psf
file delete solv_TEMP.log
file delete solv_TEMP.pdb
file delete solv_TEMP.psf
file delete vamp2wild_popc.psf
file delete vamp2wild_popc.pdb

######################
# neutralize the system #
######################

package require autoionize
autoionize -psf vamp2wild_popc_solv.psf -pdb vamp2wild_popc_solv.pdb -neutralize -o vamp2wild_popc_solv_neut
file delete vamp2wild_popc_solv.psf
file delete vamp2wild_popc_solv.pdb
# tk console --> graphics --> representations --> resname CLA, VDW,	Name

#################################
# To show hydrophobic molecules #
#################################

mol delete all
mol load psf vamp2wild_popc_solv_neut.psf pdb vamp2wild_popc_solv_neut.pdb
#set all [atomselect top all]
#$all set beta 2
#set protein [atomselect top protein]
#$protein set beta 1
#set hydro [atomselect top hydrophobic]
#$hydro set beta 0
#tk console --> graphics --> representations --> protein, beta, new cartoon 

#################################################
# To get periodic boundary condtions for config #
#################################################

Run getBoxSize.tcl
round each cellBasisVector humber up to an integer as follows:

# Periodic Boundary Conditions 
cellBasisVector1 125 0 0
cellBasisVector2 0 124 0
cellBasisVector3 0 0 110
cellOrigin -0.2047187089920044 -0.38287708163261414 -24.721282958984375

###############
# Run QwikMD #
##############

Extensions --> simulations --> QwikMD
Easy Run --> load vamp2wild_popc_solv_neu.pdb
Chain/Type selection : all
Molecular dynamikcs: explicit, 0.15mol/L, NaCl
Temp 27C
Simulation Time: 10.0
Simulation setup --> "save" --> select working directory + provied a file prefix --> "save"
Prepare
Copy and paste all 5 lines of Periodic Boundary Conditions (including header)
 from previous step into prefix/run/prefixqwikmd_production_1.conf
Start equilibration

###########################

## Using atomselect:	http://www.ks.uiuc.edu/Research/vmd/vmd-1.7/ug/node181.html
#set sel [atomselect top "water"] 				# selects all water molecules
#$sel num 										# counts number of atoms in selection
#$sel get name 									# gets names of all atoms in selection
#$sel get {name backbone} 						# getting multiple attributes from each atom in selection
#$sel get {x y z} 								# get coords of each atom in selection
#$sel set {x y z} {{1.6 0 0}} 					# set coords of all atoms in selection
#$sel set beta 0 								# set beta of all atoms in selection --> now colour by beta

###############################

#graphics representations:
#			atoms 						coloring 		drawing
#			all not water 				name			lines
#			protein						sec struct		newcartoon
#			(chain X and resid 102)		colorID	4		surf
#			water 						name 			points
#
#PDB colums:
#3 name
#4 resname
#5 resid
#11 segname (second last column)
#12 segid? (last column)

###########################################################################
#FATAL ERROR: Periodic cell has become too small for original patch grid! #
###########################################################################

# Cause: 
# Your cell is shrinking too much. Your system was started from a simulation 
# box that is significantly larger than that of the equilibrated system. The 
# reason why it shrinks so much initially, is that solvation tools under 
# solvate resulting in a system with too small density. You get the infamous 
# "patch grid error" because NAMD only calculates the patch grid at the 
# beginning of the simulation. 

# Solution: 
# Re-run but in protocol set temp to -213C and time to 0.5ns and leave 
# overnight. The low temp just speeds up the first part of the simulation. 
# The short time gives the tails a chance to reorient before the box starts 
# moving. Stop after restart files are created. Re-start equilibration 
# simulation again with the last configuration (restart files). Rinse and 
# repeat until eventually you will get a box with relatively stable density, 
# which will allow you to run long simulations without the error.

# To re-start:
# create a backup just in case
# sudo vmd
# rename qwikmd_equilibration_0.log: prefix it with "old"
# simulation setup --> load --> select vamp2.qwikmd
# loading trajectories --> select qwikmd_equilibration_0 --> ok
# reset time to 10.0
# start equilibration simulation (may produce error, ignore, press button again)
# If reset error occurs again --> re-start with time at 0.5 until new restart file created
# IF no reset error --> re-start with temp at 27C

# To know when the error has not occured:
# After beginning the program there is always many lines stating 
# "MINIMIZER RESTARTING CONJUGATE GRADIENT ALGORITHM DUE TO POOR PROGRESS"
# Until finally, it will say "TCL: Setting parameter langevinpistontemp to 60, TCL: Running for 500 steps"
# The error then occurs within a few min on the next line "FATAL ERROR"
# If no error, it will write multiple lines beginning with "PRESSURE", "GPRESSURE", "PRESSAVG"

###############
# To view DCD #
###############
mol delete all
mol load psf vamp2_QwikMD.psf dcd qwikmd_equilibration_0.dcd
