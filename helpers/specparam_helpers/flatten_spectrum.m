function spectrum_flat = flatten_spectrum(freqs, power_spectrum, robust_aperiodic_params, aperiodic_mode)
%       Flatten the power spectrum by removing the aperiodic component.
%
%       Parameters
%       ----------
%       freqs : 1xn array
%           Frequency values for the power spectrum, in linear scale.
%       power_spectrum : 1xn array
%           Power values, in log10 scale.
%       robust_aperiodic_params : 1x2 or 1x3 array (see aperiodic_mode)
%           Parameter estimates for aperiodic fit.
%       aperiodic_mode : 1 or 2
%           Defines absence or presence of knee in aperiodic component.
%
%       Returns
%       -------
%       spectrum_flat : 1xn array
%           Flattened (aperiodic removed) power spectrum.


spectrum_flat = power_spectrum - gen_aperiodic(freqs,robust_aperiodic_params,aperiodic_mode);

end