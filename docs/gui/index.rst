
neurofreq
=========

To ease learning the simple syntax utilized by NeuroFreq, an an easy-to-use interface is provided. The GUI provides buttons to load an EEGLAB-formatted .set into memory, prepare the data for TF decomposition, and run any of the above TF decomposition algorithms with modifiable parameters. Single-trial and averaged/baseline-corrected TF surfaces and topos can be viewed by clicking the respective ‘plot’ buttons. TF data can be saved using the interface, and will be saved to the same directory and with the same name as the original file, with ‘tf.mat’ appended. The TF structure saved by the GUI contains an additional field ‘history’, which contains each command that was executed to achieve the final TF result. The guy is brought up by typing:

.. code-block:: matlab
   neurofreq()

At the command line.