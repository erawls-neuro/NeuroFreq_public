function TF = nf_tfspecparam(TF, varargin)
%
% GENERAL
% -------
% SPRiNT (Wilson et al., 2022) rewritten for use with TF structures output
% by tfUtility/tf_fun. Computes a time-resolved spectral parameterization
% using matspecparam.m.
%
% Accepts TF transforms calculated using any method. Automatically detects
% if power values are on a linear scale and converts to log scale.
%
% If code is used please cite:
% Wilson, L. E., da Silva Castanheira, J., & Baillet, S. (2022). 
% Time-resolved parameterization of aperiodic and periodic brain activity. 
% Elife, 11, e77348.
%
% Please also cite BrainStorm software:
% François Tadel, Sylvain Baillet, John C. Mosher, Dimitrios Pantazis, 
% Richard M. Leahy, "Brainstorm: A User-Friendly Application for MEG/EEG 
% Analysis", Computational Intelligence and Neuroscience, vol. 2011, 
% Article ID 879716, 13 pages, 2011. https://doi.org/10.1155/2011/879716
%
% The spectral parameterization method should be cited as 
%
% Donoghue, T., Haller, M., Peterson, E. J., Varma, P., Sebastian, P., 
% Gao, R., ... & Voytek, B. (2020). Parameterizing neural power spectra 
% into periodic and aperiodic components. Nature neuroscience, 23(12), 
% 1655-1665.
%
%
% OUTPUT
% ------
% SPRiNTdat - results of SPRiNT analysis. Same fields as TF, but includes
%   separate power/aperiodic/oscillatory fields. Also includes fields
%   'rsquare' and 'mse' to assess model fit.
%
% INPUT
% -----
% TF - output of tfUtility/tf_fun functions
% Various - any input arguments to matspecparam
%
%
% -----
% E. Rawls, erawls89@gmail.com, rawls017@umn.edu. 
% July 2023
% Copyright (c) 2023 by E. Rawls.
% 
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
%
%
% ===========
% Change Log:
% ===========
% 5/23/24: ER removed option "plot"

%parse input
p                      = inputParser;
%define valid inputs
validBinary            = @(x) x==0 || x==1;
validScalar            = @(x) length(x)==1;
valid2Scalar           = @(x) numel(x)==2 && isnumeric(x) && isvector(x);
expectedPeakType       = @(x) any(validatestring(x,{'gaussian' 'cauchy'}));
expectedAperiodicModes = @(x) any(validatestring(x,{'knee' 'fixed'}));
expectedFitorData      = @(x) any(validatestring(x,{'fit' 'data'}));
% defaults for specparam
defaultPeakWidthLimits = [.5 12];         %bandwidth limits for peaks
defaultMaxPeaks        = numel(TF.freqs); %max n peaks
defaultMinPeakHeight   = 0;               %min peak height in power
defaultAperiodicMode   = 'fixed';         %aperiodic can be 'fixed' 'knee'
defaultPeakThreshold   = 2.0;             %noise SD for Gaussian detection
defaultPeakType        = 'gaussian';      %can also be cauchy, but untested
defaultThreshAfter     = 1;               %threshold after fitting?
defaultOptim           = 1;               %use optimization toolbox?
defaultPlot            = 0;               %make plot?
defaultFitorData       = 'fit';           %return model fit or data?
% add parameters and parse
addRequired(p,'TF');
addParameter(p,'peakWidthLims',defaultPeakWidthLimits,valid2Scalar);
addParameter(p,'maxPeaks',defaultMaxPeaks,validScalar);
addParameter(p,'minPeakHeight',defaultMinPeakHeight,validScalar);
addParameter(p,'aPeriodicMode',defaultAperiodicMode,expectedAperiodicModes);
addParameter(p,'peakThreshold',defaultPeakThreshold,validScalar);
addParameter(p,'peakType',defaultPeakType,expectedPeakType);
addParameter(p,'threshAfter',defaultThreshAfter,validBinary);
addParameter(p,'optim',defaultOptim,validBinary);
% addParameter(p,'plt',defaultPlot,validBinary);
addParameter(p,'FoD',defaultFitorData,expectedFitorData);
parse(p,TF,varargin{:});
%done parsing!







%create options for SPRiNT
opt.peak_width_limits = p.Results.peakWidthLims;
opt.max_peaks         = p.Results.maxPeaks;
opt.min_peak_height   = p.Results.minPeakHeight;
opt.aperiodic_mode    = p.Results.aPeriodicMode;
opt.peak_threshold    = p.Results.peakThreshold;
opt.peak_type         = p.Results.peakType;
opt.thresh_after      = p.Results.threshAfter;
opt.hOT               = p.Results.optim;

%if TF is linear, log it
if strcmp(TF.scale,'linear')
    TF.power = log10(TF.power);
    TF.scale = 'log10';
end

%begin algo
tfSPRiNT.freqs = double(TF.freqs);
freqs          = double(TF.freqs);
if TF.nsensor==1
    data=TF.power;
    TF.power = reshape(data, [1 size(data,1) size(data,2) size(data,3)]);
end
nChan          = size(TF.power,1);
nTimes         = size(TF.power,3);
nTrls          = size(TF.power,4);
surf           = double(TF.power);

%Initalize FOOOF structs
aperiodic_data = zeros(nChan,numel(tfSPRiNT.freqs),nTimes,nTrls);
osc_data       = zeros(nChan,numel(tfSPRiNT.freqs),nTimes,nTrls);
rsquare        = zeros(nChan,nTimes,nTrls);
mae            = zeros(nChan,nTimes,nTrls);
FoD            = p.Results.FoD;

%Iterate across channels
prog=1;
fprintf(1,'SPRiNT progress: %3d%%\n',prog);
%turn off warnings - fmincon throws singular matrix warnings
if isempty(gcp)
    warning off;
else
    parfevalOnAll(@warning,0,'off','all');
end
for chan = 1:nChan
    for trl = 1:nTrls
        spec = squeeze(surf(chan,:,:,trl))'; % extract spectra for a given channel & trial
        % Iterate across time
        parfor time = 1:nTimes
            dataX = spec(time,:);
            parm_spec = nf_specparam( dataX, freqs, ...
                'aPeriodicMode', opt.aperiodic_mode, ...
                'minPeakHeight',opt.min_peak_height,...
                'peakThreshold',opt.peak_threshold,...
                'peakType',opt.peak_type,...
                'peakWidthLims',opt.peak_width_limits,...
                'threshAfter',opt.thresh_after,...
                'plt',0);
            % Return specparam results
            if strcmp(FoD,'fit') %return model fit
                aperiodic_data(chan,:,time,trl) = parm_spec.aPeriodicFit;
                osc_data(chan,:,time,trl)       = parm_spec.PeriodicFit;
            elseif strcmp(FoD,'data') %return modeled data
                aperiodic_data(chan,:,time,trl) = parm_spec.aPeriodicData;
                osc_data(chan,:,time,trl)       = parm_spec.PeriodicData;
            end
            rsquare(chan,time,trl)          = parm_spec.RSquare;
            mae(chan,time,trl)              = parm_spec.MAE;
        end
    end
    %update progress
    prog=100*(chan/nChan);
    fprintf(1,'\b\b\b\b%3.0f%%',prog);
end
fprintf(1,'\n');

%package outputs
TF.SPRiNT.ap_power  = squeeze(aperiodic_data);
TF.SPRiNT.osc_power = squeeze(osc_data);
TF.SPRiNT.rsquare   = rsquare;
TF.SPRiNT.mae       = mae;


end