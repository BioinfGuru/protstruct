# Protein homology modelling and molecular dynamics

## Contents

* [Using Modeler](#using-modeller)
* [Using QwikMD](#using-qwikmd)

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

## Using QwikMd

* [Download VMD](http://www.ks.uiuc.edu/Development/Download/download.cgi?PackageName=VMD)
* [Install VMD](http://www.ks.uiuc.edu/Research/vmd/current/ig/node6.html)

This section is currently a work in progress. As a novice to molecular dynamics, I have spent a few weeks following the tutorials and jumping in at the deep end. Take my advice, [QwikMD](http://www.ks.uiuc.edu/Research/vmd/plugins/qwikmd/) is by far the best place to start. The image below is one of the [QwikMd workflows](http://www.ks.uiuc.edu/Research/qwikmd/tutorial/) on membrane proteins but for [more extensive tutorials](http://www.ks.uiuc.edu/Training/Tutorials/) are also available

<img src="https://github.com/roonysgalbi/protstruct/blob/master/vmd/qwikmd_membrane_proteins.png">




