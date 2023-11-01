
nf_prepdata
===========

This function 1) mean centers each sensor/epoch of data, 2) removes quadratic trends, and 3) applies a cosine-square taper to the beginning and final 5% of datapoints, for each channel and trial of data. This preparation reduces spectral misspecification due to edge effects and quadratic trends. The function is called as follows:

.. code-block:: matlab
   
  EEG = nf_prepdata( EEG );

Where EEG can be either 1) an EEGLAB-formatted (.set) data structure or 2) a data matrix of dimensions channels X time points X trials. The prepared data is returned in the .data field of the EEGLAB .set if an EEGLAB .set is the input, and the prepared data is returned in a matrix if a matrix is the input.