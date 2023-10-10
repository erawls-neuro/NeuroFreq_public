function tfRes = nf_cwt(data,Fs,plt)
% GENERAL
% -------
% Calculates time-frequency of an input dataset (1/2/3D) using matlab 
% built-in function cwt.m.
% 
% Expected dimensions: channel (1), time samples (2), trials/segments (3;
% optional). 
%
% Uses Morlet wavelets in all cases.
%
% OUTPUT
% ------
% tfRes: structure with fields 
%   1) power
%   2) phase
%   3) frequencies
%   4) times
%   5) sampling rate
%
% INPUT
% -----
% 1) data: 1D(time), 2D(channelXtime) or 3D(channelXtimesample) (REQUIRED)
% 2) Fs: sampling rate of signal, in Hz (REQUIRED)
% 3) plt: plot result? 0 or 1, defaults to 0
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
% Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA

%defaults
if nargin<3 || isempty(plt)
    plt=0;
end
if nargin<2 || isempty(Fs) || isempty(data)
    error('at least a signal and sampling rate are required');
end

%get all sizes
nChan = size(data,1);
nTimes = size(data,2);
%multiple trials?
if ndims(data)==3
    nTrls = size(data,3);
else
    nTrls = 1;
end

%make data long over trials
data=reshape(data,nChan,nTimes*nTrls); %concatenate times

%test run - figure out returned frequencies for preallocation
[~,f] = cwt(single(data(1,:)),Fs,'amor'); %test frequencies
cwtPow = zeros(nChan,numel(f),nTimes*nTrls); %preallocate
cwtPhas = zeros(nChan,numel(f),nTimes*nTrls); %preallocate

%progress
prog=1;
fprintf(1,'CWT progress: %3d%%\n',prog);
%sensor loop
for i=1:nChan
    %one sensor of data
    dataY=data(i,:);
    %continuous wavelet
    [convDat,f] = cwt(single(dataY),Fs,'amor');
    cwtPow(i,:,:) = flipud(abs(convDat).^2);
    cwtPhas(i,:,:) = flipud(angle(convDat));
    %update progress
    prog=100*(i/nChan);
    fprintf(1,'\b\b\b\b%3.0f%%',prog);
end
fprintf(1,'\n');

%format
tfRes.power = squeeze(reshape(cwtPow,nChan,numel(f),nTimes,nTrls)); %power, reshape back
tfRes.phase = squeeze(reshape(cwtPhas,nChan,numel(f),nTimes,nTrls)); %phase, reshape back
tfRes.freqs=flipud(f)';
tfRes.times=0:1/Fs:((1/Fs)*nTimes)-(1/Fs);
tfRes.nsensor=nChan;
tfRes.ntrls=nTrls;
tfRes.Fs=Fs;
tfRes.method='cwt';
tfRes.scale = 'linear';

% plot results
if plt == 1
    nf_tfplot(tfRes);
end

end







