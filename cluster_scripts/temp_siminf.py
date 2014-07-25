# SJS.
# Generic code for simulating and deriving omega via math, hyphy ML.
# Be sure to cp src/ directory (simulator), hyphy files, and the functions_simandinf.py script into working directory
# NOTE: very little to no sanity checking for input args

######## Input parameters ########
import sys
if (len(sys.argv) != 5):
    print "\n\nUsage: python run_siminf.py <rep> <treefile> <simdir> <cpu> \n."
    sys.exit()
rep = sys.argv[1]
treefile = sys.argv[2]
simdir = sys.argv[3]
cpu = sys.argv[4]
sys.path.append(simdir)
from functions_simandinf import *




# set up output sequence and parameter files
seqfile1 = "seqs1_"+str(rep)+".fasta"
seqfile2 = "seqs2_"+str(rep)+".fasta"
outfile1 = "params1_"+str(rep)+".fasta"
outfile2 = "params2_"+str(rep)+".fasta"


# More important parameters
mu = 1e-5
seqlength = 500000
kappa = rn.uniform(1.0, 5.0) # kappa
lambda_ = rn.uniform(0.5, 3.5) # sets strength of selection, effectively. This parameter will be the stddev for the normal distribution from which we draw scaled selection coefficients. Larger stddev = larger fitness differences among amino acids.


# Simulate
print "simulating"
f_data1, f_data2 = setFreqs2(lambda_) # last 2 args are gc min, gc max
simulate(f_data1, seqfile1, treefile, mu, kappa, seqlength, None) # omega is last argument. when None, sim via mutsel
simulate(f_data2, seqfile1, treefile, mu, kappa, seqlength, None) # omega is last argument. when None, sim via mutsel


# Derive omega
print "deriving"
mu_dict = {'AT':mu, 'AC':mu, 'AG':mu*kappa, 'CG':mu, 'CT':mu*kappa, 'GT':mu}
derivedw1 = deriveOmega(f_data1, mu_dict)
derivedw2 = deriveOmega(f_data2, mu_dict)


# Calculate entropies and other frequencies for hyphy specification
f_equal = np.zeros(61)
f_equal[f_equal == 0.] = 1./61.
f_f3x4 = calc_f3x4(f_data)
entropy_data = calcCodonEntropy(f_data)
entropy_equal = 4.11087386417 # known, no need to calculate
entropy_f3x4 = calcCodonEntropy(f_f3x4)

# ML
print "ML"
fspecs = {'equal':'equal_freqs', 'f3x4':'f3x4_freqs', 'data':'data_freqs'}
kspecs = {kappa:'kappa_true'} #, 'free':'kappa_free'}

common_out_string1 = rep + '\t' + str(kappa) + '\t' + str(lambda_) + '\t' + str(entropy_data) + '\t' + str(derivedw1)
common_out_string2 = rep + '\t' + str(kappa) + '\t' + str(lambda_) + '\t' + str(entropy_data) + '\t' + str(derivedw2)


outf1 = open(outfile1, 'w')
for freqspec in fspecs:
    hyfreq = eval('f_'+freqspec)
    for kapspec in kspecs:
        mlw, mlk = runhyphy("globalDNDS.bf", "GY94", seqfile, treefile, cpu, kapspec, hyfreq)
        w_err = (derivedw - mlw) / derivedw
        if mlk is not None:
            k_err = (kappa - mlk) / kappa
        else:
            # set these as numbers so R won't read those columns in as character.
            mlk = -10000
            k_err = -10000   
        outf1.write(common_out_string1 + '\t' + str(fspecs[freqspec]) + '\t' + str(kspecs[kapspec]) + '\t' + str(mlw) + '\t' + str(w_err) + '\n') #'\t' + str(mlk) + '\t' + str(k_err) + '\n')
outf1.close()

outf2 = open(outfile2, 'w')
for freqspec in fspecs:
    hyfreq = eval('f_'+freqspec)
    for kapspec in kspecs:
        mlw, mlk = runhyphy("globalDNDS.bf", "GY94", seqfile, treefile, cpu, kapspec, hyfreq)
        w_err = (derivedw - mlw) / derivedw
        if mlk is not None:
            k_err = (kappa - mlk) / kappa
        else:
            # set these as numbers so R won't read those columns in as character.
            mlk = -10000
            k_err = -10000   
        outf2.write(common_out_string2 + '\t' + str(fspecs[freqspec]) + '\t' + str(kspecs[kapspec]) + '\t' + str(mlw) + '\t' + str(w_err) + '\n') #'\t' + str(mlk) + '\t' + str(k_err) + '\n')
outf2.close()



