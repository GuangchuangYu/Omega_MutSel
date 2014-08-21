# SJS. stephanie.spielman@gmail.com
# Code for using Jesse Bloom's NP amino acid preferene data, with mutation rates either from NP (Bloom 2014) or yeast.

######## Input parameters ########
import sys
if (len(sys.argv) != 7):
    print "\n\nUsage: python run_np.py <rep> <treefile> <simdir> <cpu> <dataset> <batchfile>\n."
    sys.exit()
rep = sys.argv[1]         # which rep we're on, for saving files. needs to run from 1-498, since 498 sites.
treefile = sys.argv[2]    # tree for simulation
simdir = sys.argv[3]      # directory of simulation library
cpu = sys.argv[4]         # hyphy can use
dataset = sys.argv[5]     # either np, yeast, or polio. determines the mutation scheme and eq freqs
batchfile = sys.argv[6]   # hyphy batchfile name

sys.path.append(simdir)
from functions_simandinf import *

seqlength = 500


# output files
seqfile   = "seqs"+str(rep)+".fasta"
paramfile = "params"+str(rep)+".txt"

# Set up mutation rates, frequencies, hyphy batchfile name based on the dataset specified
if dataset == 'np':
    mu_dict = {'AG':2.4e-5, 'TC':2.4e-5, 'GA':2.3e-5, 'CT':2.3e-5, 'AC':9.0e-6, 'TG':9.0e-6, 'CA':9.4e-6, 'GT':9.4e-6, 'AT':3.0e-6, 'TA':3.0e-6, 'GC':1.9e-6, 'CG':1.9e-6}
elif dataset == 'yeast':
    mu = 1.67e-10 # this is the mean per generation per nucleotide mutation rate. 
    mu_dict = {'AG':0.144/2*mu, 'TC':0.144/2*mu, 'GA':0.349/2*mu, 'CT':0.349/2*mu, 'AC':0.11/2*mu, 'TG':0.11/2*mu, 'CA':0.182/2*mu, 'GT':0.182/2*mu, 'AT':0.063/2*mu, 'TA':0.063/2*mu, 'GC':0.152/2*mu, 'CG':0.152/2*mu}
elif dataset == 'polio':
    mu_dict = {'AG':2.495e-5, 'TC':6.886e-05, 'GA':1.259e-04, 'CT':2.602e-04, 'AC':1.721e-06, 'TG':1.177e-06, 'CA':9.072e-06, 'GT':1.472e-05, 'AT':3.812e-06, 'TA':3.981e-06, 'GC':6.301e-06, 'CG':1.633e-06}
else:
    raise AssertionError("Dataset has to be np, yeast, or polio.")




# Read in equilibrium frequencies and determine entropy
eq_codon_freqs = np.loadtxt(dataset + "_codon_eqfreqs.txt")
codon_freqs_true = eq_codon_freqs[ int(rep) - 1 ]
codon_freqs_true_dict = dict(zip(codons, codon_freqs_true))
entropy = calc_entropy(codon_freqs_true)


# Simulate according to MutSel model along phylogeny
print "Simulating"
simulate(codon_freqs_true, seqfile, treefile, mu_dict, seqlength)


# Derive omega from eq freqs
print "Deriving omega from equilibrium codon frequencies"
derivedw = derive_omega(codon_freqs_true_dict, mu_dict)


# Maximum likelihood omega inference across a variety of frequency, kappa specifications
print "Conducting ML inference with HyPhy"


# Lists for storing values and printing strings
krun = [1.0, 'free']
kspecs = ['one', 'free'] # since no simulation, we have no true kappa.
fspecs = ['equal', 'null', 'f61_site', 'f61_global', 'f3x4_site', 'f3x4_global', 'cf3x4_site', 'cf3x4_global'] # DO NOT CHANGE THIS LIST !!!!
omegas = np.zeros([2,8])
kappas = np.zeros([2,8])
omega_errors = np.ones([2,8])


# First, set up F61 (data) frequency vector in the hyphy batchfile as this applies to all hyphy runs.
hyf = array_to_hyphy_freq(codon_freqs_true)
setuphyphyf = "sed -i 's/DATAFREQS/"+hyf+"/g' " + batchfile
setupf = subprocess.call(setuphyphyf, shell = True)
assert(setupf == 0), "couldn't properly add in sitewise F61 frequencies"


# Run hyphy and save omegas, kappas (only sometimes returned, note), and omega errors along the way
for i in range(3):
    omegas[i], kappas[i] = run_hyphy_np(batchfile, seqfile, treefile, cpu, krun[i], fspecs)  
    omega_errors[i] = (derivedw - omegas[i]) / derivedw


# Finally, save results
outstring_params = rep + '\t' + str(entropy) + '\t' + str(derivedw)
outf = open(paramfile, 'w')
for f in fspecs:
    y =  fspecs.index(f)
    for k in kspecs:
        x = kspecs.index(k)
        outf.write( outstring_params + '\t' + f + '\t' + k + '\t' + str(omegas[x,y]) + '\t' + str(omega_errors[x,y]) + '\t' + str(kappas[x,y]) + '\n')
outf.close()   
