/* SJS. 
Hyphy inference for an "experimental" dataset. Name of file indicates the mutation scheme.
Perform 6 total inferences, one for each of the following parameterizations: F61, F1x4, F3x4, CF3x4, Fnuc1 (goes w/ F1x4), Fnuc3 (goes w/ F3x4).
*/



global w; global k; global t; // note that we use "global t" (instead of locally estimated for each branch) since all branch lengths are the same in the simulation tree.

LIKELIHOOD_FUNCTION_OUTPUT = 1;
RANDOM_STARTING_PERTURBATIONS = 1;
OPTIMIZATION_PRECSION = 0.00000001;
#include "CF3x4.bf"; // to compute the CF3x4 frequencies
#include "GY94.mdl"; // Basic GY94 rate matrix
#include "fnuc.mdl"; // Custom Fnuc matrices for this run

/* Read in the data */
DataSet	raw_data = ReadDataFile("temp.fasta");

/* Filter the data to find and remove any stop codons*/
DataSetFilter   filt_data = CreateFilter(raw_data,3,"", "","TAA,TAG,TGA");


/* Set up frequencies. Note that these were all hard-coded in when the file was created via the script Omega_MutSel/np_scripts/prefs_to_freqs.py */

F61 = {{0.064733389149},{0.0189087927842},{0.0115632355352},{0.0720346808208},{0.0207617881406},{0.00656579480405},{0.00378655454002},{0.024940714433},{0.0183282358288},{0.00405567903695},{0.00328878996608},{0.0154654001066},{0.0608007675151},{0.0192542602696},{0.0132514010227},{0.0731046467845},{0.0191347680316},{0.00480231559218},{0.0034017780326},{0.0182508480802},{0.00493633324659},{0.00154560263115},{0.000894215786054},{0.00587706951851},{0.00512041822435},{0.0017083213866},{0.000887389890897},{0.00649153378304},{0.0213374201395},{0.00663029994479},{0.00386848498876},{0.0252850872804},{0.0124122552578},{0.00300126013449},{0.00220656490876},{0.0114319414507},{0.00510089124266},{0.00162307513157},{0.000932107751921},{0.00616737701312},{0.00292513578661},{0.000880222075102},{0.000507525132551},{0.00334915414632},{0.0125533738666},{0.00397240978366},{0.00229534552166},{0.015092184512},{0.0153368199285},{0.0580263918681},{0.0287298549736},{0.00881210127899},{0.00520928043386},{0.033507110926},{0.00341326527498},{0.00114878555926},{0.0129029488686},{0.0812743827376},{0.0190352784228},{0.0146973634242},{0.0724395752933}};

F1x4 = {{0.0542343414692},{0.0200931854557},{0.011436972433},{0.0615796392563},{0.0200931854557},{0.00744428881811},{0.00423726373221},{0.0228145318695},{0.011436972433},{0.00423726373221},{0.00241183602289},{0.0129859535034},{0.0615796392563},{0.0228145318695},{0.0129859535034},{0.0699197568958},{0.0200931854557},{0.00744428881811},{0.00423726373221},{0.0228145318695},{0.00744428881811},{0.0027580214262},{0.00156985636203},{0.0084525156482},{0.00423726373221},{0.00156985636203},{0.000893556871602},{0.00481114299528},{0.0228145318695},{0.0084525156482},{0.00481114299528},{0.0259044473347},{0.011436972433},{0.00423726373221},{0.00241183602289},{0.0129859535034},{0.00423726373221},{0.00156985636203},{0.000893556871602},{0.00481114299528},{0.00241183602289},{0.000893556871602},{0.000508609514921},{0.00273848613648},{0.0129859535034},{0.00481114299528},{0.00273848613648},{0.0147447228172},{0.0228145318695},{0.0699197568958},{0.0228145318695},{0.0084525156482},{0.00481114299528},{0.0259044473347},{0.00481114299528},{0.00273848613648},{0.0147447228172},{0.0699197568958},{0.0259044473347},{0.0147447228172},{0.079389429094}};

F3x4 = {{0.0516306288865},{0.0172336346698},{0.009794035423},{0.0655013296892},{0.0261047700568},{0.0087134338667},{0.00495192578823},{0.0331178834508},{0.0131797839329},{0.00439924103627},{0.00250012973868},{0.0167205666721},{0.0728641699367},{0.0243211154365},{0.0138219168896},{0.0924393159736},{0.0155992756703},{0.005206836016},{0.00295909350288},{0.019790061067},{0.00788709169746},{0.00263260897364},{0.00149613624965},{0.0100059791001},{0.00398203716045},{0.00132915238774},{0.000755369706824},{0.00505182165134},{0.0220146122145},{0.00734819219686},{0.00417604620557},{0.0279288942192},{0.0101202472712},{0.0033780073573},{0.00191975310783},{0.0128390776434},{0.00511686054637},{0.00170794172402},{0.000970639221844},{0.00649151824895},{0.00258340204756},{0.000862306116602},{0.0004900566139},{0.00327743963005},{0.0142822861715},{0.00476724199255},{0.00270926811666},{0.0181192589634},{0.0141812189246},{0.0538997555636},{0.0214811017086},{0.00717011330553},{0.00407484230963},{0.0272520547483},{0.00362004890046},{0.00205730757576},{0.0137590253631},{0.0599584919507},{0.0200133674123},{0.0113737834836},{0.0760664945137}};

pos_freqs = {{0.430844130737,0.315245041574,0.358149014141},{0.130171886557,0.159389871852,0.11954549848},{0.0844508237156,0.0804728050667,0.0679388224946},{0.35453315899,0.444892281507,0.454366664885}};
CF3x4_ = BuildCodonFrequencies(CF3x4(pos_freqs, "TAA,TAG,TGA"));


/* Optimize likelihoods for each frequency specification */


////////////// F61 FREQUENCIES //////////////
Model MyModel = (GY94, F61, 1);
UseModel (USE_NO_MODEL);
UseModel(MyModel);
Tree    Tree01 = DATAFILE_TREE;
LikelihoodFunction  LikFn1 = (filt_data, Tree01);
Optimize (paramValues, LikFn1);
fprintf ("f61_hyout.txt", LikFn1);



////////////// F1x4 FREQUENCIES //////////////
global w; global k; global t;
Model MyModel = (GY94, F1x4, 1);
UseModel (USE_NO_MODEL);
UseModel(MyModel);
Tree    Tree01 = DATAFILE_TREE;
LikelihoodFunction  LikFn2 = (filt_data, Tree01);
Optimize (paramValues, LikFn2);
fprintf ("f1x4_hyout.txt", LikFn2);



////////////// F3x4 FREQUENCIES //////////////
global w; global k; global t;
Model MyModel = (GY94, F3x4, 1);
UseModel (USE_NO_MODEL);
UseModel(MyModel);
Tree    Tree01 = DATAFILE_TREE;
LikelihoodFunction  LikFn3 = (filt_data, Tree01);
Optimize (paramValues, LikFn3);
fprintf ("f3x4_hyout.txt", LikFn3);


////////////// CF3x4 FREQUENCIES //////////////
global w; global k; global t;
Model MyModel = (GY94, CF3x4_, 1);
UseModel (USE_NO_MODEL);
UseModel(MyModel);
Tree    Tree01 = DATAFILE_TREE;
LikelihoodFunction  LikFn4 = (filt_data, Tree01);
Optimize (paramValues, LikFn4);
fprintf ("cf3x4_hyout.txt", LikFn4);

////////////// Fnuc_f1x4 //////////////
global w; global k; global t;
Model MyModel = (Fnuc1, F1x4, 0);
UseModel (USE_NO_MODEL);
UseModel(MyModel);
Tree    Tree01 = DATAFILE_TREE;
LikelihoodFunction  LikFn5 = (filt_data, Tree01);
Optimize (paramValues, LikFn5);
fprintf ("fnuc1_hyout.txt", LikFn5);


////////////// Fnuc_f3x4 //////////////
global w; global k; global t;
Model MyModel = (Fnuc3, F3x4, 0);
UseModel (USE_NO_MODEL);
UseModel(MyModel);
Tree    Tree01 = DATAFILE_TREE;
LikelihoodFunction  LikFn6 = (filt_data, Tree01);
Optimize (paramValues, LikFn6);
fprintf ("fnuc3_hyout.txt", LikFn6);
