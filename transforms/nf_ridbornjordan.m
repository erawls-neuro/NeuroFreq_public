function tfRes = nf_ridbornjordan(data,Fs,fRes,kernel,makePos,plt)
% GENERAL
% -------
% Calculates time-frequency of an input dataset (1/2/3D) using Cohen's
% class RID with Born-Jordan kernel. Includes inline functions written 
% by Jeff O'Neill for RID calculation. 
%
% Expected dimensions: channel (1), time samples (2), trials/segments (3;
% optional).
%
% Born-Jordan distribution does not provide phase estimates.
%
% OUTPUT
% ------
% tfRes: structure with fields 
%   1) power
%   2) frequencies
%   3) times
%   4) sampling rate
%
% INPUT
% -----
% 1) data: 1D(time), 2D(channelXtime) or 3D(channelXtimesample) (REQUIRED)
% 2) Fs: sampling rate of signal, in Hz (REQUIRED)
% 3) fRes: frequency spacing of output, defaults to 2*N(times) freqs
% 4) kernel: rectangular window length in seconds, defaults to 2*N(times)
% 5) makePos: make result positive? 0 or 1, defaults to 0
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
%
%
%
% Change Log
% ------------
% 2/10/24 ER: made compatible with analytic signals

%defaults
nTimes = size(data,2);
if nargin<6 || isempty(plt)
    plt=0;
end
if nargin<5 || isempty(makePos)
    makePos=0;
    disp('returning both positive and negative values (default)');
end
if nargin<4 || isempty(kernel)
    kernel=2*nTimes;
    disp('setting window length to 2*N (default)');
else
    kernel = round(kernel*Fs);
end
if nargin<3 || isempty(fRes)
    fout = linspace(0,Fs/2,nTimes);
    disp('setting frequencies output to 2*N (default)');
else
    fout = 0:fRes:Fs/2; %user-specified resolution
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

%preallocate
ridPowDat = zeros(nChan,numel(fout),nTimes,nTrls); %preallocate

%make window
kernel=min(2*numel(fout),kernel);
if mod(kernel,2)==1
    kernel=kernel-1;
end

%progress
prog=1;
fprintf(1,'Born-Jordan RID progress: %3d%%\n',prog);

%sensor loop
for eloc = 1:nChan
    %trial loop
    for trl = 1:nTrls
        %get one sensor of data
        dataY = squeeze(data(eloc,:,trl));
        %Jeff O'Neills toolbox - Born-Jordan RID
        tmpPow = born_jordan2(dataY,Fs,2*numel(fout),kernel);
        ridPowDat(eloc,:,:,trl) = tmpPow(((length(tmpPow(:,1))/2)+1):end,:);
    end
    %track progress
    prog=100*(eloc/size(data,1));
    fprintf(1,'\b\b\b\b%3.0f%%',prog);
end
fprintf(1,'\n');

if makePos==1
%set all of surface to minimal non-zero value
 tfThresh = squeeze(ridPowDat(:));
 tfThresh(tfThresh<=0)=[];
 ridPowDat(ridPowDat<min(tfThresh)) = min(tfThresh);
end
 %format
tfRes.power = squeeze(ridPowDat); %power
tfRes.freqs = fout;
tfRes.times=0:1/Fs:((1/Fs)*nTimes)-(1/Fs);
tfRes.nsensor=nChan;
tfRes.ntrls=nTrls;
tfRes.Fs=Fs;
tfRes.kernel=kernel;
tfRes.makePos=makePos;
tfRes.method='bornjordan2';
tfRes.scale = 'linear';

% plot results
if plt == 1
    nf_tfplot(tfRes);
end

end












function [tfd, t, f] = born_jordan2(x, fs, nfreq, wlen)
% born_jordan2 -- Compute samples of the type II Born_Jordan distribution.
%
%  Usage
%    [tfd, t, f] = born_jordan2(x, fs, nfreq, wlen)
%
%  Inputs
%    x     signal vector
%    fs    sampling frequency of x (optional, default is 1 sample/second)
%    nfreq number of samples to compute in frequency (optional, default
%          is twice the length of x)
%    wlen  length of the rectangular lag window on the auto-correlation
%          function, must be less than or equal to nfreq (optional, default
%          is twice the length of x)
%
%  Outputs
%    tfd  matrix containing the Born_Jordan distribution of signal x.  If x has
%         length N, then tfd will be nfreq by N. (optional)
%    t    vector of sampling times (optional)
%    f    vector of frequency values (optional)
%
% If no output arguments are specified, then the Born_Jordan distribution is 
% displayed using ptfd(tfd, t, f).

% Copyright (C) -- see DiscreeTFDs/Copyright

% specify defaults
x = x(:);
N = length(x);

error(nargchk(1, 4, nargin));
if (nargin < 4) 
  wlen = 2*N;
end
if (nargin < 3)
  nfreq = 2*N;
end
if (nargin < 2)
  fs = 1;
end

if (nfreq < wlen)
  error('wlen must be less than or equal to nfreq!');
end
if (wlen > 2*N)
  error('wlen must be less than or equal to twice the length of the signal!');
end
w = wlen/2;

% make the born jordan kernel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ker = zeros(w);
for tau = 1:w
  ker(tau,1:tau) = ones(1,tau)/tau;
end


% Do the computations.
%%%%%%%%%%%%%%%%%%%%%%

% make the acf for positive tau
acf = lacf2(x, w);

% convolve with the kernel
acf2 = fft(acf.');
ker = [ker zeros(w,N-w)];
ker2 = fft(ker.');
gacf = ifft(acf2.*ker2);
gacf = gacf.';

% make the gacf for negative lags
gacf = [gacf ; zeros(nfreq-wlen+1,N) ; conj(flipud(gacf(2:w,:)))];

%compute the tfd
tfd = real(fft(gacf));
tfd = tfdshift(tfd)/nfreq;

t = 1/fs * (0:N-1);
f = -fs/2:fs/nfreq:fs/2;
f = f(1:nfreq);

if (nargout == 0)
  ptfd(tfd, t, f);
  clear tfd
end


end


function out = tfdshift(in)
% tfdshift -- Shift the spectrum of a TFD by pi radians.
%
%  Usage
%    out = tfdshift(in)
%
%  Inputs
%    in   time-frequency distribution
%
%  Outputs
%    out  shifted time-frequency distribution

% Copyright (C) -- see DiscreteTFDs/Copyright

error(nargchk(1, 1, nargin));

N = size(in, 1);
M = ceil(N/2);
out = [in(M+1:N,:) ; in(1:M,:)];
end

function lacf = lacf2(x, mlag)
% lacf2 -- Compute samples of the type II local acf.
%
%  Usage
%    lacf = lacf2(x, mlag)
%
%  Inputs
%    x     signal vector
%    mlag   maximum lag to compute.  must be <= length(x).
%           (optional, defaults to length(x))
%
%  Outputs
%    lacf  matrix containing the lacf of signal x.  If x has
%         length N, then lacf will be nfreq by N. (optional)
%
% This function has a tricky sampling scheme, so be careful if you use it.

% Copyright (C) -- see DiscreteTFDs/Copyright

% specify defaults
x = x(:);
N = length(x);

error(nargchk(1, 2, nargin));
if (nargin < 2) 
  mlag = N;
end

if (mlag > N)
  error('mlag must be <= length(x)')
end

% make the acf for positive tau
lacf = zeros(mlag, N);
for t=1:N,
  mtau = min(mlag, N-t+1);
  lacf(1:mtau, t) = conj(x(t))*x(t:t+mtau-1);
end
end







