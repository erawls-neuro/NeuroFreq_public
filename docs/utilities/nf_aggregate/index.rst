
nf_aggregate
============

NeuroFreq includes a function to gather multiple single-subject datasets into a multi-subject set. The new set will contain fields describing the number of subjects, and will fail if all included TF sets do not have consistent dimensionality (channels/freqs/times/conditions). nf_aggregate should usually be used to aggregate averaged TF datasets. See the "tutorials" section for a direct example of this function. The function is called as:

.. code-block:: matlab
   
  TF = nf_aggregate;

This call will open a menu to select datasets to aggregate.