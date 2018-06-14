# extracts box size from solvated pdb/psf files for namd config file 
# from http://www.ks.uiuc.edu/Research/namd/mailing_list/namd-l.2011-2012/2735.html

proc get_cell {{molid top}} { 
 set all [atomselect $molid all] 
 set minmax [measure minmax $all] 
 set vec [vecsub [lindex $minmax 1] [lindex $minmax 0]] 
 puts "cellBasisVector1 [lindex $vec 0] 0 0" 
 puts "cellBasisVector2 0 [lindex $vec 1] 0" 
 puts "cellBasisVector3 0 0 [lindex $vec 2]" 
 set center [measure center $all] 
 puts "cellOrigin $center" 
 $all delete 
}
get_cell
