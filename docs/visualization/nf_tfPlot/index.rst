
nf_tfPlot
=========

Plots a TF structure computed with nf_tfTransform or any of the individual functions in the transforms folder. In the case of multiple trials or channels, both are averaged over for plotting. If the transform includes phase, the inter-trial phase coherence (ITPC) is plotted as well. This plot is shown with the function:

.. code-block:: matlab
   TF = nf_tfPlot( TF );