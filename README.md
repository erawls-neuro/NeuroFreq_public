# NeuroFreq
NeuroFreq, a MATLAB toolbox for flexible time-frequency analysis of M/EEG data. 

<img src="./nf_logo.png" width="150" height="150">

Read my documentation at: https://neurofreq-public.readthedocs.io/en/latest/index.html. 

The NeuroFreq Toolbox is described in the accompanying preprint: https://www.biorxiv.org/content/10.1101/2023.11.01.565154v2. 

Contents:
1) utilities
    High-level functions for data preparation, TF-transformation, resampling, and averaging/baseline correction, are included in the /utilities folder. 
2) transforms
    Contains the TF transforms themselves. Transforms are optimized for 1/2/3D matrices consisting of time series, channels X times, or channels X times X trials. 
3) demo
    Contains all data and code necessary to replicate the demostration results from the NeuroFreq preprint.

There is a readme file in each subfolder describing these contents more closely.