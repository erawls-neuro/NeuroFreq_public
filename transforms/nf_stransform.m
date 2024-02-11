function tfRes = nf_stransform(data,Fs,factor,plt)
% GENERAL
% -------
% Calculates time-frequency of an input dataset (1/2/3D) using the
% Stockwell transform (S-transform).
%
% S-transform is a middle ground between the CWT and STFT - it windows FFT
% components by frequency-domain Gaussians, and recovers time-domain data
% following windowing via inverse-FFT.
%
% Expected dimensions: channel (1), time samples (2), trials/segments (3;
% optional).
%
% OUTPUT
% ------
% tfRes: structure with fields
%   1) power
%   2) phase
%   3) frequencies
%   4) times
%   5) sampling rate
%   6) window
%
% INPUT
% -----
% 1) data: 1D(time), 2D(channelXtime) or 3D(channelXtimesample) (REQUIRED)
% 2) Fs: sampling rate of signal, in Hz (REQUIRED)
% 3) factor: Gaussian windowing factor. Usually 1, 3 for high resolution.
% 4) plt: plot result? 0 or 1, defaults to 0
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
%
%
%
% Change Log
% ------------
% 2/10/24 ER: change implementation of stransform to Stockwell's original
% 2/10/24 ER: add 'factor' option
% 2/10/24 ER: made compatible with analytic signals

%defaults
if nargin<4 || isempty(plt)
    plt=0;
end
if nargin<3 || isempty(factor)
    factor=1;
    disp('setting factor to 1 (default)');
end
if nargin<2 || isempty(Fs) || isempty(data)
    error('at least a signal and sampling rate are required inputs');
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

%figure out resolution
fout=0:floor(Fs/2)/fix(size(data,2)/2):floor(Fs/2);

%preallocate
stransPow = zeros(nChan,numel(fout),nTimes,nTrls); %preallocate
stransPhas = zeros(nChan,numel(fout),nTimes,nTrls); %preallocate

%do S-transform
prog=1;
fprintf(1,'S-transform progress: %3d%%\n',prog);

%sensor loop
for i=1:nChan
    %trial loop
    for j=1:nTrls
        %one sensor/trial of data
        dataY=squeeze(data(i,:,j));
        %do S-transform
        tmpPow = stransf(dataY,factor);
        %get power/phase
        stransPow(i,:,:,j) = abs(tmpPow).^2; %power
        stransPhas(i,:,:,j) = angle(tmpPow); %phase angle
    end
    %update progress bar
    prog=100*(i/nChan);
    fprintf(1,'\b\b\b\b%3.0f%%',prog);
end
fprintf(1,'\n');


%format
tfRes.power=squeeze(reshape(stransPow,nChan,numel(fout),nTimes,nTrls)); %power, reshape back
tfRes.phase=squeeze(reshape(stransPhas,nChan,numel(fout),nTimes,nTrls)); %phase, reshape back
tfRes.freqs=fout;
tfRes.times=0:1/Fs:((1/Fs)*nTimes)-(1/Fs);
tfRes.nsensor=nChan;
tfRes.ntrls=nTrls;
tfRes.Fs=Fs;
tfRes.factor=factor;
tfRes.method='stransform';
tfRes.scale = 'linear';

% plot results
if plt == 1
    nf_tfplot(tfRes);
end

end



% a clever implementation of s-transform uses the toeplitz matrix to avoid a
% for-loop - this idea is borrowed from 
% https://www.mathworks.com/matlabcentral/fileexchange/45848-stockwell-transform-s-transform
%unfortunately, this implementation fails for analytic signals
function stockTF = stran(data)
    %ensure h is a column vector
    if ~iscolumn(data)
        data = data(:);
    end
    len = numel(data);
    half_size = floor(len/2);
    oddSize = mod(len,2);
    %construct frequency vector
    freqs = [(0:half_size) (-half_size+1-oddSize:-1)]/len;
    %perform FFT
    hfft = fft(data);
    invFreqs = 1./freqs(2:half_size+1)';
    %generate the W matrix
    W = 2*pi*freqs(:).*invFreqs.';
    % Generate Gaussian filter
    Gauss = exp(-W'.^2/2);
    % Construct Toeplitz matrix and Gaussian window it
    topFFT = toeplitz(hfft(1:half_size+1)', hfft);
    topFFT = topFFT(2:half_size+1,:);
    stockTF = ifft(topFFT.*Gauss,[],2);
    % Prepend mean
    st0 = mean(data)*ones(1,len);
    stockTF = [st0; stockTF];
end


%a modified version of Stockwell's 1996 code
%he has a great sense of humor
function stockTF = stransf(data,factor)
%ensure h is a column vector
if ~iscolumn(data)
    data = data(:);
end
% Compute the length of the data.
n=length(data);
% Compute FFT's
vector_fft=fft(data);
vector_fft=[vector_fft,vector_fft];
% Preallocate the STOutput matrix
stockTF=zeros(fix(n/2)+1,n);
% Compute the mean
stockTF(1,:) = mean(data)*(1&[1:1:n]);
% Start loop to increment the frequency point
for banana=1:fix(n/2)
    number=banana+1;
    vector(1,:)=0:n-1;
    vector(2,:)=-n:-1;
    vector=vector.^2;
    vector=vector*(-factor*2*pi^2/banana^2);
    % Compute the Gaussion window
    gauss=sum(exp(vector));
    stockTF(number,:)=ifft(vector_fft(banana+1:banana+n).*gauss);
end   % a fruit loop!   aaaaa ha ha ha ha ha ha ha ha ha ha
end




