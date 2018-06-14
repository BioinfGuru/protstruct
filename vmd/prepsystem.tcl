# place pdb file in wd
# terminal --> sudo vmd --> vmd main --> extensions --> tk console

######################
# create protein psf #
######################

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
