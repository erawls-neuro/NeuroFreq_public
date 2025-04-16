utilities/ README
——————————----------------------------------------------------------------
The utilities folder of NeuroFreq contains high-level functions for working 
directly with EEG and time-frequency data structures. These functions 
include utilities to prepare data for TF analysis, run TF analysis, and 
manipulate TF surfaces including resampling, averaging, and baseline 
correction.

Functions:

1) nf_aggregate: 
Opens a directory window to select TF sets. Aggregates multiple data files 
into a single TF structure for group analysis.

2) nf_avebase:
Averages and optionally baseline corrects single trial TF structures. 
Trials are averaged together per sensor, and an optional dB/z-score/percent 
baseline correction is applied. Phase data are averaged as the inter-trial
phase coherence (ITPC) measuring phase consistency over trials.

3) nf_corr_TFCE
Uses TFCE to correlate EEG with an external variable. Can be single trials
or averaged subject level data and variables, as long as dimensions are
correct. For multivariate correlations (e.g. corr(subjectXchannelXtime,
subjectXchannelXtime), uses very efficient vectorization techniques.
returns a standard 'stats' structure that can be plotted.

4) nf_glm_TFCE
Uses TFCE to regress EEG onto an set of external variables. Can be single 
trials or averaged subject level data and variables, as long as dimensions 
are correct. returns a standard 'stats' structure that can be plotted.

5) nf_indsamples_TFCE
Uses TFCE to t-test EEG against another EEG set. Can be single trials
or averaged subject level data, as long as dimensions are
correct. returns a standard 'stats' structure that can be plotted.

6) nf_makebehavior
Creates a standard NeuroFreq behavior structure from a csv file of a task
(for example, stimuli, RTs, accuracy, etc.). Must have column headers. Adds
.behavior field to TF structure which is automatically carried forward
through further processing.

7) nf_onesample_TFCE
Uses TFCE to t-test EEG against h0. Can be single trials
or averaged subject level data, as long as dimensions are
correct. returns a standard 'stats' structure that can be plotted.

8) nf_prepdata:
Accepts either an input EEGLAB .set in memory or a 1/2/3D data tensor. In 
either case, the function will 1) remove quadratic trends 
from single-trial data, 2) center the data, 3) cosine-square taper 
single-trial segments, and 4) convert signal to analytic using the Hilbert 
transform. If an EEGLAB .set is input, then a prepared EEGLAB 
.set is returned; if a data tensor is input, a prepared data tensor is 
returned.

9) nf_resample:
Resample time and frequency axes for computed TF structures. Useful for 
downsampling full-resolution surfaces for computational efficiency.

10) nf_rmerp
Removes phase-locked or evoked activity from each frequency. This
removal gets rid of any phase-locking in the data and removes contribution
of the ERP or evoked potential to TF results.

11) nf_specparam
Parameterizes power spectra into periodic and aperiodic components. 

12) nf_stregress
Computes single-trial correlation/regression on input EEG/TF data.

13) nf_tfplot:
Plots a summary of TF structures averaged over trials and channels.

14) nf_tfspecparam
Uses the SPRiNT method (Wilson et al., 2022, eLife) to parameterize TF 
surfaces computed by NeuroFreq.

15) nf_tftransform:
Implements every TF transform from the tf_fun folder in one 
wrapper function. Accepts only EEGLAB formatted .set files as input 
- if you want to analyze data tensors directly, use the transform functions 
directly. Read the help for full details on available keyword-argument
pairs.

16) nf_unpack2long
Unpacks a TF set to long format. Columns include 'channel', 'frequency',
'times', etc so it is highly redundant. Still the best way to extract data
for further decimation/processing/averaging in R.

17) nf_viewerapp:
Allows interacting with TF structures for M/EEG including topographic 
plots, surface plots, and scrolling through single trials. Since the TF 
structure requires channel locations for plotting, this function only 
applies to TF computed using the nf_tftransform function.



