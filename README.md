# NeuroFreq
NeuroFreq, a MATLAB Toolbox for Time-Frequency Analysis of M/EEG Data.

NeuroFreq is a utility for flexible time-frequency analysis of M/EEG data. The NeuroFreq Toolbox is described in the accompanying paper [I will insert preprint link here once it is preprinted].

The graphic user interface is invoked by typing 'neurofreq' at the MATLAB command line.

The high-level utilities for data preparation, TF-transformation, resampling, and averaging/baseline correction, are included in the /utilities folder. There is a readme file in this folder describing the utilities more closely.

The TF transforms themselves are optimized for 1/2/3D matrices consisting of time series, channels X times, or channels X times X trials. These functions are included in the /transforms folder. There is a readme file in this folder describing the utilities more closely.

Tools for visualizing the resulting TF transforms are located in the /visualization folder. There is a readme file in this folder describing these tools more closely.

Demonstrations of the toolbox that reproduce the results from the paper are found in the /demo/ folder.
