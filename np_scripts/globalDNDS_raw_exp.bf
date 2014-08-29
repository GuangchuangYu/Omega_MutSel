/* 
Hyphy inference for an "experimental" dataset. Name of file indicates the mutation scheme.
Run across 5 sets of equilibrium freqs: Fequal, Fnull, F61, F3x4, CF3x4. 
NOTE: Fnull refers to frequencies which would exist in the absence of natural selection. 
*/


global w;
global k;
global t;

LIKELIHOOD_FUNCTION_OUTPUT = 1;
RANDOM_STARTING_PERTURBATIONS = 1;

/* Include relevant functions */
#include "matrices.mdl"; //rate matrices
#include "GY94_Header.ibf";

/* Read in the data */
DataSet	raw_data = ReadDataFile("temp.fasta");

/* Filter the data to find and remove any stop codons*/
DataSetFilter   filt_data = CreateFilter(raw_data,3,"", "","TAA,TAG,TGA");



/* Set up frequencies. MANY OF THESE WERE HARD-CODED IN WHEN THIS FILE WAS CREATED!!!*/

Fequal_CodonFreqs = {{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623},{0.016393442623}};

Fnull_CodonFreqs = INSERTNULL

F61_CodonFreqs = INSERTF61

F3x4_CodonFreqs  = INSERTF3x4

CF3x4_CodonFreqs = INSERTCF3x4


/* Optimize likelihoods for each frequency specification */

////////////// FEQUAL FREQUENCIES //////////////
Model MyModel = (GY94, Fequal_CodonFreqs, 1);
UseModel (USE_NO_MODEL);
UseModel(MyModel);
Tree    Tree01 = DATAFILE_TREE;
LikelihoodFunction  LikFn = (filt_data, Tree01);
Optimize (paramValues, LikFn);
fprintf ("equal_hyout.txt", LikFn);


////////////// NULL FREQUENCIES //////////////
Model MyModel = (GY94, Fnull_CodonFreqs, 1);
UseModel (USE_NO_MODEL);
UseModel(MyModel);
Tree    Tree01 = DATAFILE_TREE;
LikelihoodFunction  LikFn1 = (filt_data, Tree01);
Optimize (paramValues, LikFn1);
fprintf ("null_hyout.txt", LikFn1);



////////////// F61 FREQUENCIES, GLOBAL //////////////
global w;
global k;
global t;
Model MyModel = (GY94, F61_CodonFreqs, 1);
UseModel (USE_NO_MODEL);
UseModel(MyModel);
Tree    Tree01 = DATAFILE_TREE;
LikelihoodFunction  LikFn3 = (filt_data, Tree01);
Optimize (paramValues, LikFn3);
fprintf ("f61_hyout.txt", LikFn3);



////////////// F3x4 FREQUENCIES //////////////
global w;
global k;
global t;
Model MyModel = (GY94, F3x4_CodonFreqs, 1);
UseModel (USE_NO_MODEL);
UseModel(MyModel);
Tree    Tree01 = DATAFILE_TREE;
LikelihoodFunction  LikFn5 = (filt_data, Tree01);
Optimize (paramValues, LikFn5);
fprintf ("f3x4_hyout.txt", LikFn5);



////////////// CF3x4 FREQUENCIES //////////////
global w;
global k;
global t;
Model MyModel = (GY94, CF3x4_CodonFreqs, 1);
UseModel (USE_NO_MODEL);
UseModel(MyModel);
Tree    Tree01 = DATAFILE_TREE;
LikelihoodFunction  LikFn7 = (filt_data, Tree01);
Optimize (paramValues, LikFn7);
fprintf ("cf3x4_hyout.txt", LikFn7);

