.. _index

*******************************
NeuroFreq Project Documentation
*******************************

.. meta::
    :description: Neurofreq documentation
    :keywords: EEG, MEG, time-frequency


.. _dsg-introduction:

Introduction
============
Time-frequency (TF) analysis of M/EEG data enables rich understanding of cortical dynamics underlying cognition, health, and disease. 

There are many algorithms for time-frequency decomposition of M/EEG neural data, but they are implemented in an inconsistent manner and most existing toolboxes either 1) contain only one or a few transforms, or 2) are not adapted to analyze multichannel, multitrial M/EEG data. This makes entry into time-frequency daunting for new practitioners and limits the ability of the community to flexibly compare the performance of multiple TF methods on M/EEG data. 

This documentation introduces the NeuroFreq toolbox for MATLAB, which includes multiple TF transformation algorithms that are implemented in a consistent fashion and produce consistent output. The toolbox includes TF decomposition algorithms of both linear and quadratic classes, utilities for resampling, averaging, and baseline correction of TF representations, and tools for visualizing and interacting with single-trial or averaged TF representations over multiple channels.

The source code of this project is located in its repository on GitHub <https://github.com/erawls-neuro/NeuroFreq_public>.

