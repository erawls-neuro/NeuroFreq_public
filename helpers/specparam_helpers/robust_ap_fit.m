function aperiodic_params = robust_ap_fit(freqs, power_spectrum, aperiodic_mode, aperiodic_guess)
%       Fit the aperiodic component of the power spectrum robustly, ignoring outliers.
%
%       Parameters
%       ----------
%       freqs : 1xn array
%           Frequency values for the power spectrum, in linear scale.
%       power_spectrum : 1xn array
%           Power values, in log10 scale.
%       aperiodic_mode : {'fixed','knee'}
%           Defines absence or presence of knee in aperiodic component.
%       aperiodic_guess: double
%           SPRiNT specific - feeds previous timepoint aperiodic slope as
%           guess
%
%       Returns
%       -------
%       aperiodic_params : 1xn array
%           Parameter estimates for aperiodic fit.


    % if no guess
    if nargin<4
        aperiodic_guess = -(power_spectrum(end)-power_spectrum(1))./log10(freqs(end)./freqs(1));
    end
    
    % Do a quick, initial aperiodic fit
    popt = simple_ap_fit(freqs, power_spectrum, aperiodic_mode, aperiodic_guess);
    initial_fit = gen_aperiodic(freqs, popt, aperiodic_mode);

    % Flatten power_spectrum based on initial aperiodic fit
    flatspec = power_spectrum - initial_fit;

    % Flatten outliers - any points that drop below 0
    flatspec(flatspec(:) < 0) = 0;

    % Use percential threshold, in terms of # of points, to extract and re-fit
    perc_thresh = prctile(flatspec, 0.025);
    perc_mask = flatspec <= perc_thresh;
    freqs_ignore = freqs(perc_mask);
    spectrum_ignore = power_spectrum(perc_mask);

    % Second aperiodic fit - using results of first fit as guess parameters

    options = optimset('Display', 'off', 'TolX', 1e-4, 'TolFun', 1e-6, ...
        'MaxFunEvals', 5000, 'MaxIter', 5000);
    guess_vec = popt;

    switch (aperiodic_mode)
        case 'fixed'  % no knee
            aperiodic_params = fminsearch(@error_expo_nk_function, guess_vec, options, freqs_ignore, spectrum_ignore);
        case 'knee'
            aperiodic_params = fminsearch(@error_expo_function, guess_vec, options, freqs_ignore, spectrum_ignore);
    end
end