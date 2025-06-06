function tfce = nf_indsamples_TFCE(dataX,dataY,chanlocs,faxis,taxis,nperm,par)
%
% GENERAL
% -------
% Uses routines from ept-TFCE to run a mass-univariate
% TFCE-corrected set of tests on input data series. Dimensions 
% of input dataX MUST be subjects first. The dimensions may otherwise be
% subjectXtime, subjectsXfrequencies, subjectsXchannelsXtimes,
% subjectsXchannelsXfrequencies, or subjectsXchannelsXfrequenciesXtimes.
% The code will determine from the other arguments what the dimensions are.
%
% INPUTS
% ------
% 1) dataX - a matrix of data for statistical testing (must be subjects X
%   channels X frequencies X time, any dimensions except subject may be
%   missing)
% 2) dataY - a matrix of data for statistical testing (must be subjects X
%   channels X frequencies X time, any dimensions except subject may be
%   missing)
% 3) chanlocs - channel locations (EEGLAB format; may be missing)
% 4) faxis - frequency axis, may be missing, in Hz
% 5) taxis - time points considered for testing, may be missing
% 6) nperm - number of permutations for cluster testing, recommend 10,000
% 7) par - parallelize? recommended. 0 = no, 1 = yes (default 0)
%
%
% OUTPUTS
% -------
% 1) tfce - a structure containing results of testing. Can be passed
% directly to nf_plottfce for plotting.
%
% -----
% E. Rawls, erawls89@gmail.com, rawls017@umn.edu. 
% Nov. 2023
% Copyright (c) 2023 by E. Rawls.
% 
% This program is free software; you can redistribute it and/or modify
% it under the terms of version 3 of the GNU General Public License as 
% published by the Free Software Foundation.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

if nargin < 7 || isempty(par)
    par = 0;
end
if nargin < 6 || isempty(nperm)
    nperm = 1000;
end
if nargin < 5 || isempty(taxis)
    taxis = [];
    disp('no time axis supplied - assuming data have no time dimension.');
end
if nargin < 4 || isempty(faxis)
    faxis = [];
    disp('no frequency axis supplied - assuming data have no frequency dimension.');
end
if nargin < 3 || isempty(chanlocs)
    chanlocs = [];
    disp('no channel locations supplied - assuming single-channel data.');
end
if nargin < 2 || isempty(dataX) || isempty(dataY)
    error('at least data must be supplied...see help for dimensions and other inputs.');
end

% run stats
if ~isempty(chanlocs)
    if ~par
        tfc = ept_TFCE_indsamples( dataX, dataY, chanlocs, 'nperm', nperm);
    else
        tfc = ept_TFCE_indsamples_par( dataX, dataY, chanlocs, 'nperm', nperm);
    end
else
    if ~par
        tfc = ept_TFCE_indsamples( dataX, dataY, [], 'nperm', nperm, 'flag_ft', 1);
    else
        tfc = ept_TFCE_indsamples_par( dataX, dataY, [], 'nperm', nperm, 'flag_ft', 1);
    end
end

%add outputs
tfce.obs = {squeeze(mean(dataX)), squeeze(mean(dataY))};
tfce.sd = {squeeze(std(dataX)), squeeze(std(dataY))};
tfce.df = {size(dataX,1)-1, size(dataY,1)-1};
if ~isempty(taxis)
    e3 = 1;
    tfce.times = taxis;
end
if ~isempty(faxis)
    e2 = 1;
    tfce.freqs = faxis;
end
if ~isempty(chanlocs)
    e1 = 1;
    tfce.chanlocs = chanlocs;
end
tfce.tstat = tfc.Obs;
tfce.p_vals = tfc.P_Values;

%figure out type for plotting
if e1==1 && e2==1 && e3==1
    tfce.type = 'twosample_chXfsXts';
elseif e1==1 && e2==1
    tfce.type = 'twosample_chXts';
elseif e1==1 && e3==1
    tfce.type = 'twosample_chXts';
elseif e2==1 && e3==1
    tfce.type = 'twosample_tf';
elseif e3==1
    tfce.type = 'twosample_ts';
elseif e2==1
    tfce.type = 'twosample_ts';
end

%display methods text
disp(['Recommended methods text: Significance testing with correction for ' ...
    'multiple comparisons was conducted using threshold-free cluster ' ...
    'enhancement (TFCE; Mensen & Khatami, 2013) using functions from the ' ...
    'ept-TFCE toolbox (Mensen & Khatami, 2013)']);



end









