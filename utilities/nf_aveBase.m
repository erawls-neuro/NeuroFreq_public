function TF = nf_aveBase( TF, method, blTimes, plt )
% GENERAL
% -------
% Averages/baselines TF structures from tfUtility or from tf_fun. 
% Power is averaged and baseline corrected according to either dB, %, or
% z-score. If the signal contains phase, phase is processed into ITC.
%
% OUTPUT
% ------
% TF - structure output by tfUtility.m and tf_fun functions (averaged)
%
% INPUT
% -----
% TF - structure output by tfUtility.m and tf_fun functions
% method - 'none', 'zscore', 'db', 'percent'
% blTimes - [min max] times for baseline, in ms
%
%
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



if nargin<4 || isempty(plt)
    plt=0;
end
if nargin<3 || isempty(blTimes)
    disp('no times provided, using all times before 0');
    blTimes = find( TF.times<=0 );
else
    blTimes = find( (TF.times>=blTimes(1)) + (TF.times<=blTimes(end)) == 2);
end
if nargin<2 || isempty(method)
    method='none';
else
    method=lower(method);
end
if nargin<1 || isempty(TF)
    error('at least a TF structure is required input');
end

%average power over trials
TF.power = corrP(TF.power,blTimes,method);
%get parameterized
if isfield(TF,'SPRiNT') %parameterized
   TF.SPRiNT.ap_power = corrP(TF.SPRiNT.ap_power,blTimes,method);
   TF.SPRiNT.osc_power = corrP(TF.SPRiNT.osc_power,blTimes,method);
end
%get ITC
if isfield(TF,'phase')
    TF.phase = squeeze(abs(mean(exp(1i*TF.phase),4)));
end
%set ntrials
TF.ntrls=1;
%plot results
if plt==1
        nf_tfPlot(TF);
end

end




function power = corrP(power,blTimes,method) %average power over trials
tfPow = squeeze(mean( power,4 ));
blPow = repmat(squeeze(mean( tfPow(:,:,blTimes), 3)), [1,1,size(power,3)]);
blPowSTD = repmat(squeeze(std(permute(tfPow,[3,1,2]))), [1,1,size(power,3)]);
%correct power
switch method
    case 'zscore'
        disp('baselining with z-score');
        tfPow = (tfPow-blPow)./blPowSTD;
    case 'db'
        disp('baselining with decibel');
        tfPow = 10*log10( tfPow./blPow );
    case 'percent'
        disp('baselining using %-change');
        tfPow = 100*(tfPow-blPow)./blPow;
    case 'none'
        disp('NOT baselining power estimates');
end
power = tfPow;

end




