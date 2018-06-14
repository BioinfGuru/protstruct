mol new solvated.psf
mol addfile solvated.pdb
set all [atomselect top all]
$all moveby [vecinvert [measure center $all]]
display resetview