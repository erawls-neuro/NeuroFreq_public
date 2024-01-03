function TF = nf_avebase( TF, method, blTimes, trlvec, plt )
% GENERAL
% -------
% Averages/baselines TF structures from tftransform or from tf_fun. 
% Power is averaged and baseline corrected according to either dB, %, or
% z-score. If the signal contains phase, phase is processed into ITC.
%
% OUTPUT
% ------
% TF - structure output by tfUtility.m and tf_fun functions (averaged)
%
% INPUT
% -----
% 1) TF - structure output by tfUtility.m and tf_fun functions
% 2) method - 'none', 'zscore', 'db', 'percent'
% 3) blTimes - [min max] times for baseline, in ms
% 4) trlvec - vector describing which trials to average together. Each 
%     unique value in the vector is taken to be a different trial type.
% 5) plt - plot result? 0 or 1
%
%
% E. Rawls, erawls89@gmail.com, rawls017@umn.edu. 
% July 2023
% Copyright (c) 2023 by E. Rawls.
% 
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA



if nargin<5 || isempty(plt)
    plt=0;
end
if nargin<4 || isempty(trlvec)
    disp('No trial vector supplied - averaging all trials together');
    trlvec = ones(1, size(TF.power,ndims(TF.power)));
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

%check if already averaged
if TF.ntrls==1
    error('TF is already averaged (ntrls = 1)');
end
if TF.nsensor==1
    flagsens=1;
else
    flagsens=0;
end

%get trial info
conds = unique(trlvec,'stable');

%preallocate power/phase
sz = size(TF.power);
sz=sz(1:end-1);
newpower = zeros([sz,numel(conds)]);
%if we have phase
if isfield(TF,'phase')
    newphase = zeros([sz,numel(conds)]);
end
%if tf is parameterized
if isfield(TF,'SPRiNT') %parameterized
    newosc = zeros([sz,numel(conds)]);
    newap = zeros([sz,numel(conds)]);
end

%loop thru conditions
for n=1:numel(conds)
    if flagsens==0
        %get only condition-specific power
        condP = TF.power(:,:,:,find(trlvec==conds(n)));
        %average power over trials
        newpower(:,:,:,n) = corrP(condP,blTimes,method,flagsens);
        %get parameterized
        if isfield(TF,'SPRiNT') %parameterized
            condap = TF.SPRiNT.ap_power(:,:,:,find(trlvec==conds(n)));
            condosc = TF.SPRiNT.osc_power(:,:,:,find(trlvec==conds(n)));
            newap(:,:,:,n) = corrP(condap,blTimes,method,flagsens);
            newosc(:,:,:,n) = corrP(condosc,blTimes,method,flagsens);
        end
        %get ITC
        if isfield(TF,'phase')
            condphase = TF.phase(:,:,:,find(trlvec==conds(n)));
            newphase(:,:,:,n) = squeeze(abs(mean(exp(1i*condphase),4)));
        end
    else
        %get only condition-specific power
        condP = TF.power(:,:,find(trlvec==conds(n)));
        %average power over trials
        newpower(:,:,n) = corrP(condP,blTimes,method,flagsens);
        %get parameterized
        if isfield(TF,'SPRiNT') %parameterized
            condap = TF.SPRiNT.ap_power(:,:,find(trlvec==conds(n)));
            condosc = TF.SPRiNT.osc_power(:,:,find(trlvec==conds(n)));
            newap(:,:,n) = corrP(condap,blTimes,method,flagsens);
            newosc(:,:,n) = corrP(condosc,blTimes,method,flagsens);
        end
        %get ITC
        if isfield(TF,'phase')
            condphase = TF.phase(:,:,find(trlvec==conds(n)));
            newphase(:,:,n) = squeeze(abs(mean(exp(1i*condphase),3)));
        end
    end
    %set trials/erp
    TF.trlerp(n)=numel(find(trlvec==conds(n)));
end
TF.conds = n;
%add to output
TF.ntrls = 1;
TF.power = newpower;
if isfield(TF,'phase')
    TF.phase = newphase;
end
if isfield(TF,'SPRiNT')
    TF.SPRiNT.osc_power = newosc;
    TF.SPRiNT.ap_power = newap;
end

%plot results
if plt==1
    nf_tfplot(TF);
end

end




function power = corrP(power,blTimes,method,flagsens) %average power over trials
tfPow = squeeze(mean( power,ndims(power) ));
if flagsens==0
    blPow = repmat(squeeze(mean( tfPow(:,:,blTimes), 3)), [1,1,size(power,3)]);
    blPowSTD = repmat(squeeze(std(permute(tfPow,[3,1,2]))), [1,1,size(power,3)]);
else
    blPow = repmat(squeeze(mean( tfPow(:,blTimes), 2)), [1,size(power,2)]);
    blPowSTD = repmat(squeeze(std(permute(tfPow,[2,1]))), [1,size(power,2)]);
end
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

