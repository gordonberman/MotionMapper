This code represents a sample implementation of the MotionMapper behavioral analysis methods initially described in the paper “Mapping the stereotyped behaviour of freely-moving fruit flies” by Berman, GJ, Choi, DM, Bialek, W, and Shaevitz, JW (Journal of the Royal Society, Interface, 11, 20140672).


This MATLAB code is presented in order to provide a more explicit representation of the algorithms described in the article text.

********* THIS IS !!!!NOT!!!! INTENDED TO BE STAND-ALONE SOFTWARE *********

As this code is presented for the sake of methodological repeatability (and not as “Black Box” software), the use of this software is at your own risk.  The authors are not responsible for any damage that may result from errors in the software.  

Downloaders of this software are free to use, modify, or redistribute this software how they see fit, but only for non-commercial purposes and all modified versions may only be shared under the same conditions as this (see license below).  For any further questions about this code, please email Gordon Berman at gberman(a t )princeton[dot)edu.  

This code was tested to perform properly using .avi movies of behaving flies, as described in the above paper.  If desired, these (very large) movies can be obtained through emailing Joshua Shaevitz ( shaevitz[ @t]princeton(d ot)edu ).  All tests were performed on a 12-core, 2.93 GHz Mac Pro with 64 GB of RAM installed.

Many aspects of the code are memory-limited, so adjusting run parameters in order to fit the specifics of your hardware will likely be necessary.  A listing of all parameters, their descriptions, and default values can be found in parameters.txt (Note: this is just a listing.  Altering parameter values within this file will NOT affect the algorithms).

All that being said, if any questions/concerns/bugs arise, please feel free to email me (Gordon), and I will do my absolute best to answer/resolve them.

*******



1)	To run this code, you will first have to compile the associated mex files contained in this repository.  In order to do this, type

	compile_mex_files

in the MATLAB command prompt from the main directory.  You will need to have your mex compiler properly set-up.


2)	An example run-through of all the portions of the algorithm can be found in runExample.m.  Given a folder of .avi movies (specified as ‘filePath’ at the top of the aforementioned file), this will run through each of the steps in the algorithm.  It should be noted again that this code is not currently tested to work cross-platform or for any movies other than the ones presented in the original paper.


3)	All default parameters can be adjusted within setRunParameters.m.  Additionally, parameters can be set by inputting a struct containing the desired parameter name and value into the function (see code for details).


4)	The major sub-routines for the method all can be run from individual files in the main directory, each named as coherently as possible:

	runAlignment.m -> Image segmentation and alignment.
	
	findRadonPixels.m -> Find image pixels with highest variance

	findPosturalEigenmodes.m -> Calculates a set of postural eigenmodes

	findProjections.m -> Finds time series of images projected onto eigenmodes

	findWavelets.m -> Computes the Morlet wavelet transform for a set of projections

	runEmbeddingSubSampling.m -> Finds a training set for t-SNE given a folder of projection files

	run_tSne.m -> Runs the t-SNE algorithm

	findEmbeddings.m -> Embeds a set of projections into a previously found embedding

Details about this inputs and outputs to each of these functions can be found in within the file comments.



*******

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
