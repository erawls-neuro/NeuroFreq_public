
transforms
==========

The primary functionality of NeuroFreq is to perform efficient, high-quality TF decompositions with a wide variety of algorithms. Following optional data preparation, M/EEG time series data can be transformed to a TF representation using any of the included algorithms, including several implementations of linear and quadratic decomposition methods.

Linear TF Transforms
====================

Linear time-frequency methods offer a direct and efficient approach to time-frequency analysis. They provide a clear and computationally efficient representation of the signal's time-frequency content but often exhibit a fixed or rigid trade-off between time and frequency resolution. These methods often provide high frequency resolution at the expense of temporal resolution, or vice versa. Thus they are best suited for situations where such a trade-off is acceptable.


Quadratic TF Transforms
=======================

Quadratic time-frequency methods can provide high-resolution information in both time and frequency simultaneously, making them particularly suited for complex signals that exhibit rapid and non-stationary changes in frequency content. However, this comes at the cost of increased computational complexity and cross-term interference, which can result in time-frequency representations that are more challenging to interpret.

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   nf_stft/index
   nf_filterHilbert/index
   nf_demodulation/index
   nf_wavelet/index
   nf_cwt/index
   nf_sTransform/index
   nf_ridBinomial/index
   nf_ridBornJordan/index
   nf_ridRihaczek/index

