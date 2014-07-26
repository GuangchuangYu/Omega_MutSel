# SJS.
# Generic code for simulating and deriving omega via math, hyphy ML.
# Be sure to cp src/ directory (simulator), hyphy files, and the functions_simandinf.py script into working directory
# NOTE: very little to no sanity checking for input args

######## Input parameters ########
import sys
if (len(sys.argv) != 6):
    print "\n\nUsage: python run_siminf.py <rep> <treefile> <simdir> <cpu> <gcbias>\n."
    sys.exit()
rep = sys.argv[1]
treefile = sys.argv[2]
simdir = sys.argv[3]
cpu = sys.argv[4]
gc_bias = bool(int(sys.argv[5])) # 0 or 1
sys.path.append(simdir)
from functions_simandinf import *




# set up output sequence and parameter files
seqfile = "seqs"+str(rep)+".fasta"
freqfile = "codonFreqs" + str(rep)+".txt"
outfile = "params"+str(rep)+".txt"

# Parameters
seqlength = 500000
lambda_ = rn.uniform(0.5, 3.5) # sets strength of selection, effectively. This parameter will be the stddev for the normal distribution from which we draw scaled selection coefficients. Larger stddev = larger fitness differences among amino acids.
mu = 1e-5
kappa = rn.uniform(1.0, 5.0)
if gc_bias:
    bias = rn.uniform(1., 5.)
else:
    bias = 1.0
mu_dict = {'AC': mu*bias, 'CA':mu, 'AG': mu*kappa*bias, 'GA':mu*kappa, 'AT': mu, 'TA':mu, 'CG': mu*bias, 'GC':mu*bias, 'CT': mu*kappa, 'TC':mu*kappa*bias, 'GT': mu, 'TG':mu*bias}




# Simulate
print "simulating"
f_data, gc_content = setFreqs(freqfile, lambda_, 0., 1.) # last 2 args are gc min, gc max
simulate(f_data, seqfile, treefile, mu_dict, kappa, seqlength, None) # omega is last argument. when None, sim via mutsel


# Derive omega
print "deriving"
# can incorporate asymmetric if wish
derivedw = deriveOmega(f_data, mu_dict)

# Calculate entropy and setup the f_equal variable
f_equal = np.zeros(61)
f_equal[f_equal == 0.] = 1./61.
entropy_data = calcCodonEntropy(f_data)

# ML
print "ML"
fspecs = {'equal':'globalDNDS_inputf.bf', 'data': 'globalDNDS_inputf.bf', 'f3x4':'globalDNDS_f3x4.bf', 'cf3x4':'globalDNDS_cf3x4.bf'}
kspecs = {1.0: 'kappa_one', kappa:'kappa_true', 'free':'kappa_free'}

common_out_string = rep + '\t' + str(seqlength) + '\t' + str(mu) + '\t' + str(kappa) + '\t' + str(bias) + '\t' + str(lambda_) + '\t' + str(gc_content) + '\t' + str(entropy_data) + '\t' + str(derivedw) 


outf = open(outfile, 'w')
for freqspec in fspecs:
    try:
        hyfreq = eval('f_'+freqspec)
    except:
        hyfreq = None
    for kapspec in kspecs:
        mlw, mlk = runhyphy(fspecs[freqspec], "GY94", seqfile, treefile, cpu, kapspec, hyfreq)
        w_err = (derivedw - mlw) / derivedw 
        outf.write(common_out_string + '\t' + 'freq_'+str(freqspec) + '\t' + str(kspecs[kapspec]) + '\t' + str(mlw) + '\t' + str(w_err) + '\t' + str(mlk) + '\n')
outf.close()




