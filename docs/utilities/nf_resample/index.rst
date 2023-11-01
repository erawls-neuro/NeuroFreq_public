
nf_resample
===========

Resamples TF representations to new time or frequency vectors using linear interpolation. This function is useful for TF methods that produce a redundant frequency sampling, such as the S-transform or CWT, and can also be used to reduce the number of time or frequency points in a representation in order to reduce the number of statistical tests carried out at a later step. This function is called as:

.. code-block::
   
  TF = nf_resample( TF, tVec, fVec );

Where tVec contains the new times to resample to and fVec contains the new frequencies to resample to. Either tVec or fVec can be left blank, in which case only one dimension of the TF representation is resampled.  	