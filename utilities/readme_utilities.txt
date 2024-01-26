utilities/ README
——————————----------------------------------------------------------------
The utilities folder of NeuroFreq contains high-level functions for working 
directly with EEG and time-frequency data structures. These functions 
include utilities to prepare data for TF analysis, run TF analysis, and 
manipulate TF surfaces including resampling, averaging, and baseline 
correction.

Functions and workflow:

1) nf_prepdata:
Accepts either an input EEGLAB .set in memory or a 1/2/3D data tensor. In 
either case, the function will remove quadratic trends 
from single-trial data, center the data, and cosine-square taper 
single-trial segments. If an EEGLAB .set is input, then a prepared EEGLAB 
.set is returned; if a data tensor is input, a prepared data tensor is 
returned.

2) nf_tftransform:
Implements every TF transform from the tf_fun folder in one 
wrapper function. Accepts only EEGLAB formatted .set files as input 
- if you want to analyze data tensors directly, use the transform functions 
directly. Read the help for full details on available keyword-argument
pairs.

3) nf_resample:
Allows resampling of time and frequency axes for computed TF structures. 
Useful for downsampling full-resolution surfaces for computational 
efficiency.

4) nf_avebase:
Averages and optionally baseline corrects single trial TF structures. 
Trials are averaged together per sensor, and an optional dB/z-score/percent 
baseline correction is applied. Phase data are averaged as the inter-trial
phase coherence (ITPC) measuring phase consistency over trials.

5) nf_aggregate: 
Opens a directory window to select TF sets. Aggregates multiple data files 
into a single TF structure for group analysis.

6) nf_tfplot:
Plots a summary of TF structures averaged over trials and channels if
applicable.

7) nf_viewerapp:
Allows interacting with TF structures for M/EEG including topographic 
plots, surface plots, and scrolling through single trials. Since the TF 
structure requires channel locations for plotting, this function only 
applies to TF computed using the nf_tftransform function.



