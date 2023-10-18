function tfRes = nf_filterhilbert(data,Fs,freqs,fBandWidth,order,plt)
% GENERAL
% -------
% Calculates time-frequency of an input dataset (1/2/3D) using 
% filter-Hilbert.
% 
% Expected dimensions: channel (1), time samples (2), trials/segments (3;
% optional). 
%
% Allows filter bandwidth to change by frequency, mimicking 
% wavelet smoothing that changes by frequency. Uses butterworth filters of
% specified order.
%
% OUTPUT
% ------
% tfRes: structure with fields 
%   1) power
%   2) phase
%   3) frequencies
%   4) times
%   5) sampling rate
%   6) bandwidth
%   7) order
%
% INPUT
% -----
% 1) data: 1D(time), 2D(channelXtime) or 3D(channelXtimesample) (REQUIRED)
% 2) Fs: sampling rate of signal, in Hz (REQUIRED)
% 3) freqs: requested frequencies in Hz, defaults to 1:1:Fs/2
% 4) fBandWidth: bandwidth of butterworth filters, formatted 1 or [1 8] 
%       i.e. start-and stop-bandwidth, defaults to 1
% 5) order: order of butterworth filters, defaults to 3
% 6) plt: plot result? 0 or 1, defaults to 0
%
% -----
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
% Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA


%defaults
if nargin<6 || isempty(plt)
    plt=0;
end
if nargin<5 || isempty(order)
    order = 3;
    disp('setting filter order = 3 (default)');
end
if nargin<4 || isempty(fBandWidth)
    fBandWidth = 1;
    disp('setting filter bandwidth to 1 Hz (default)');
end
if nargin<3 || isempty(freqs) 
    freqs = 1:1:floor((Fs/2)-1);
    disp('setting freqs to 1:1:Fs/2 (default)');
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

%make data long in time
data=reshape(data,nChan,nTimes*nTrls); %concatenate times
hilbPow = zeros(nChan,numel(freqs),nTimes*nTrls); %preallocate
hilbPhas = zeros(nChan,numel(freqs),nTimes*nTrls); %preallocate


% parse foverlap
fLap = fBandWidth;
if length(fLap)==1
    disp(['Using ' num2str(fLap) ' Hz bandwidth for all filters']);
    bwidths = repmat(fLap,1,numel(freqs));
elseif length(fLap)==2
    disp(['Filter bandwidth will linearly scale from ' num2str(fLap(1)) ...
        ' to ' num2str(fLap(2))]);
    bwidths = fLap(1):((fLap(2)-fLap(1))/(numel(freqs)-1)):fLap(2);
end


%filter data
prog=1;
fprintf(1,'filter-Hilbert progress: %3d%%\n',prog);
for j=1:numel(freqs)
    lowpF = freqs(j)+(bwidths(j)/2);
    hipF = freqs(j)-(bwidths(j)/2);
    [a1,b1] = butter(order, hipF/(Fs/2), 'high');
    [a2,b2] = butter(order, lowpF/(Fs/2), 'low');
    %sensor loop
    for i=1:nChan
        %one sensor of data
        dataY=data(i,:);
        %apply filters
        fD = filtfilt(a1,b1,double(dataY)); %high-pass
        fD = filtfilt(a2,b2,double(fD)); %low-pass
        %get power/phase with hilbert transform
        hilbPow(i,j,:) = envelope(fD).^2;
        hilbPhas(i,j,:) = angle(hilbert(fD));
    end
    %update progress bar
    prog=100*(j/numel(freqs));
    fprintf(1,'\b\b\b\b%3.0f%%',prog);
end
fprintf(1,'\n');


%format
tfRes.power = squeeze(reshape(hilbPow,nChan,numel(freqs),nTimes,nTrls)); %power, reshape back
tfRes.phase = squeeze(reshape(hilbPhas,nChan,numel(freqs),nTimes,nTrls)); %phase, reshape back
tfRes.freqs=freqs;
tfRes.times=0:1/Fs:((1/Fs)*nTimes)-(1/Fs);
tfRes.nsensor=nChan;
tfRes.ntrls=nTrls;
tfRes.Fs=Fs;
tfRes.bandwidth = bwidths;
tfRes.order = order;
tfRes.method='filter-hilbert';
tfRes.scale = 'linear';

% plot results
if plt == 1
    nf_tfplot(tfRes);
end

end






