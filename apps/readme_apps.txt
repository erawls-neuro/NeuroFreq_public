apps/ README
——————————----------------------------------------------------------------
The apps folder of NeuroFreq contains applications for computing, saving,
plotting, and interacting with time-frequency data structures.

Functions:

1) neurofreq:
A GUI to guide first-time users through NeuroFreq. Provides options for 
calculating TF transforms, and various post-processing utilities. Output 
datasets include syntax used for replicability.

2) nf_viewerapp:
Allows interacting with TF structures for M/EEG including topographic 
plots, surface plots, and scrolling through single trials. Since the TF 
structure requires channel locations for plotting, this function only 
applies to TF computed using the nf_tftransform function.




 