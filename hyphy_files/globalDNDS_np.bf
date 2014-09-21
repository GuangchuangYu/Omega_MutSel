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

F61 = {{0.017274122406},{0.0165289044056},{0.0178110465444},{0.0160481777078},{0.0165440302014},{0.0168247775624},{0.0168554874281},{0.0165038458249},{0.0200679091543},{0.0181013815289},{0.0206754445263},{0.017558678789},{0.0164871224637},{0.0166462890039},{0.0173729848651},{0.0162567427401},{0.0155233995997},{0.0131009968735},{0.0159735514944},{0.0127411086481},{0.0106387025502},{0.0108436972708},{0.0108415639061},{0.0106397457816},{0.0197065093418},{0.0202521359352},{0.0201287408928},{0.0198549102606},{0.017215404483},{0.0175145854924},{0.0175783292453},{0.0171865440495},{0.0156850442726},{0.0136527780793},{0.0161527396802},{0.0132610406112},{0.0197188518977},{0.0200716076979},{0.0200875621772},{0.0196974866951},{0.0185883425154},{0.0188952460818},{0.0188949053976},{0.0185130475514},{0.0156929188991},{0.0159927570671},{0.0159780563508},{0.0156862465877},{0.012581752079},{0.012125389635},{0.0178623254559},{0.0181568015369},{0.018202541326},{0.0178066149475},{0.0139415063448},{0.0108684811772},{0.0134699264357},{0.0166776296994},{0.0138377888856},{0.0171530917999},{0.0134506481382}};

F1x4 = {{0.0146858345174},{0.015584381651},{0.016247583579},{0.0143603894888},{0.015584381651},{0.0165379060452},{0.017241685728},{0.0152390243936},{0.016247583579},{0.017241685728},{0.017975415142},{0.0158875294537},{0.0143603894888},{0.0152390243936},{0.0158875294537},{0.0140421564757},{0.015584381651},{0.0165379060452},{0.017241685728},{0.0152390243936},{0.0165379060452},{0.0175497714626},{0.0182966116344},{0.0161714182369},{0.017241685728},{0.0182966116344},{0.0190752340003},{0.0168596018295},{0.0152390243936},{0.0161714182369},{0.0168596018295},{0.0149013204161},{0.016247583579},{0.017241685728},{0.017975415142},{0.0158875294537},{0.017241685728},{0.0182966116344},{0.0190752340003},{0.0168596018295},{0.017975415142},{0.0190752340003},{0.019886991069},{0.0175770714532},{0.0158875294537},{0.0168596018295},{0.0175770714532},{0.0155354542978},{0.0152390243936},{0.0140421564757},{0.0152390243936},{0.0161714182369},{0.0168596018295},{0.0149013204161},{0.0168596018295},{0.0175770714532},{0.0155354542978},{0.0140421564757},{0.0149013204161},{0.0155354542978},{0.0137309756566}};

F3x4 = {{0.0142169514769},{0.0153690285207},{0.0152273581074},{0.015001594277},{0.0178203326289},{0.0192644112816},{0.0190868335574},{0.0188038483788},{0.018381039594},{0.0198705553873},{0.0196873902777},{0.0193955011261},{0.0177815608248},{0.0192224975869},{0.0190453062197},{0.0187629367336},{0.0127921151653},{0.013828729959},{0.0137012578885},{0.0134981203225},{0.0160343620531},{0.0173337137786},{0.0171739330617},{0.0169193089252},{0.0165388744363},{0.0178791095492},{0.01771430142},{0.017451665675},{0.0159994759959},{0.017296000714},{0.017136567633},{0.0168824974837},{0.0141663283288},{0.015314303103},{0.0151731371441},{0.0149481772044},{0.0177568787063},{0.0191958153419},{0.0190188699293},{0.018736892393},{0.0183155891287},{0.0197998011141},{0.0196172882114},{0.019326438407},{0.0177182449593},{0.0191540508918},{0.0189774904605},{0.0186961264243},{0.010860462107},{0.0106008161786},{0.0125926662828},{0.0136131186468},{0.0134876340632},{0.0132876637264},{0.0140414479379},{0.0139120150509},{0.0137057527575},{0.0125652683436},{0.0135835005033},{0.0134582889372},{0.0132587536771}};

pos_freqs = {{0.277556945152,0.208460052037,0.23768231294},{0.249739925825,0.26129564226,0.256943005845},{0.276568631562,0.269517165933,0.254574526812},{0.196134497461,0.260727139771,0.250800154403}};
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


////////////// CNF //////////////
global w; global k; global t;
Model MyModel = (CNF, F61, 0);
UseModel (USE_NO_MODEL);
UseModel(MyModel);
Tree    Tree01 = DATAFILE_TREE;
LikelihoodFunction  LikFn7 = (filt_data, Tree01);
Optimize (paramValues, LikFn7);
fprintf ("cnf_hyout.txt", LikFn7);