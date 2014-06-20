# SJS
# Generic code for simulating and deriving omega via math, hyphy ML.
# Be sure to cp src/ directory (simulator), hyphy files, and the functions_simandinf.py script into working directory
# 6/12/14 -> best combo for 100000 sites where kappa=1 is mu=1e-6,bl=0.001

import sys
import numpy as np
from functions_simandinf import *

sys.path.append('src/')
from misc import *
from newick import *
from stateFreqs import *
from matrixBuilder import *
from evolver import *



# Input parameters and global stuff
if (len(sys.argv) != 10):
    print "\n\nUsage: python run_siminf.py <rep> <cpu> <numaa> <aadist> <mu> <kappa> <bias> <bl> <seqlength>\n."
    sys.exit()
rep = sys.argv[1]
cpu = sys.argv[2]
numaa = int(sys.argv[3])
aadist = sys.argv[4] # Either "exp", "equal", "random"
mu = float(sys.argv[5])
kappa = float(sys.argv[6])
bias = float(sys.argv[7])
bl = sys.argv[8]
seqlength = int(sys.argv[9])



# Write tree given bl specifications
treefile = "tree.tre"
treef = open(treefile, 'w')
treef.write("(t1:" + str(bl) + ", t2:" + str(bl) + ");")
treef.close()

# set up output sequence and parameter files
seqfile = "seqs"+str(rep)+".fasta"
freqfile = "codonFreqs" + str(rep)+".txt"
outfile = "params"+str(rep)+".txt"
outf = open(outfile,'w')

# Simulate
print "simulating"
f, gc_content, aminos_used = setFreqs(aadist, numaa, bias, freqfile)

simulate(f, seqfile, treefile, mu, kappa, seqlength, None) # omega is last argument. when None, sim via mutsel
    
# Derive omega
print "deriving"
mu_dict = {'AT':mu, 'AC':mu, 'AG':mu, 'CG':mu, 'CT':mu, 'GT':mu}
mu_dict['AG'] = mu_dict['AG'] * kappa
mu_dict['CT'] = mu_dict['CT'] * kappa
derived_dN, derived_dS, derived_w = deriveOmega(f, mu_dict)

# HyPhy/PAML omega
print "ML"
mg94_dS, mg94_dN = runhyphy("globalDNDS.bf", "MG94", seqfile, treefile, cpu, f, aminos_used, bias, kappa)
mg94_w = mg94_dN/mg94_dS
gy94_w = runhyphy("globalDNDS.bf", "GY94", seqfile, treefile, cpu, f, aminos_used, bias, kappa)

# Save
outf.write(rep + '\t' + str(numaa) + '\t' + str(aadist) + '\t' + str(mu) + '\t' + str(bl) + '\t' + str(seqlength) + '\t' + str(kappa) + '\t' +  str(bias) + '\t' + str(derived_dN) + '\t' + str(mg94_dN) + '\t' + str(derived_dS) + '\t' + str(mg94_dS) + '\t' + str(derived_w) + '\t' + str(mg94_w) + '\t' + str(gy94_w) + '\n')
outf.close()





