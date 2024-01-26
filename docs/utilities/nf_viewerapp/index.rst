
nf_viewerapp
============

NeuroFreq includes a viewer app that allows interacting with TF structures for M/EEG including topographic plots, surface plots, and scrolling through single trials. Since the TF structure requires channel locations for plotting, this function only applies to TF computed using the nf_tftransform function. The viewing app is called as follows:

.. code-block:: matlab
   
  TF = nf_viewerapp( TF );

Where 1) TF is the output of nf_tftransform (single subject) or of nf_aggregate (multi-subject).