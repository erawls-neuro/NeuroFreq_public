
nf_ridRihaczek
==============

The Reduced Interference Distribution Rihaczek smoothes the Rihaczek distribution by applying a Choi-Williams (exponential) kernel in in the ambiguity domain. The RID-Rihaczek is computed using

.. code-block:: matlab
   
  TF = nf_ridRihaczek( data, Fs, fRes, kernel, makePos, plt );

where data is a 1/2/3D tensor of dimensions channels X time X trials, Fs is the sampling rate of the data in Hz, fRes is the desired frequency resolution of the output in Hz (e.g. 0.5 produces a TF representation with frequency steps equal to 0.5 Hz), kernel is the kernel parameter (default .001), makePos is 0 or 1 indicating whether the distribution should return only positive energy, and plt is 0 or 1 indicating whether or not the user would like a summary plot to be produced following transformation. Note that only interference terms can take on negative values, so makePos can potentially return a clearer TF representation. 

Defaults are: fRes = as many frequency samples as time samples, kernel = 0.001, makePos = 1, plt = 0. Data and Fs are required.

When RID-Rihaczek is run on the demo synthetic data using

.. code-block:: matlab
  
  TF = nf_ridRihaczek( data, 500 );

We obtain the following result:

.. image:: fig_ridrihaczek_synthetic.png
  :width: 600