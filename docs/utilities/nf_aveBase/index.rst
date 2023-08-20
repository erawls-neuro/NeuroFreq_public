
nf_aveBase
==========

Trial-level averaging and baseline correction of TF data. Averages together single trials of TF data prior to applying a baseline correction using either decibel, percent change, z-score, or no correction.  For TF decompositions that return phase estimates, this function averages phase over trials to estimate inter-trial phase coherence (ITPC). This function is called as:

.. code-block:: matlab
   
  TF = nf_aveBase( TF, ‘blmethod’, bltimes );

Where ‘blmethod’ can be ‘dB’, ‘percent’, ‘zscore’, or ‘none’ and bltimes includes the time samples to be included in the baseline. If ‘blmethod’ is left out then the function defaults to ‘dB’ correction and if bltimes is left out the function defaults to all times before 0 (event onset).