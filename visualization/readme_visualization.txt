visualization/ README
——————————----------------------------------------------------------------
The visualization folder of NeuroFreq contains functions for plotting and 
interacting with time-frequency data structures.

Functions:

1) nf_tfPlot:
Plots a TF structure computed with nf_tfTransform or any of the 
individual functions in the transforms folder. In the case of multiple 
trials or channels, both are averaged over for plotting. If the transform 
includes phase, the inter-trial phase coherence (ITPC) is plotted as well.

2) nf_viewerApp:
Allows interacting with TF structures for M/EEG including topographic 
plots, surface plots, and scrolling through single trials. Since the TF 
structure requires channel locations for plotting, this function only 
applies to TF computed using the nf_tfTransform function. A second input 
argument can be either 'power' or 'phase' to determine what data are 
plotted, although note that phase plots do not make much sense in 
single-trial data.




