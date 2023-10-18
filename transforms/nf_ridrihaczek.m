function tfRes = nf_ridrihaczek(data,Fs,fRes,cwkernel,makePos,plt)
% GENERAL
% -------
% Calculates time-frequency of an input dataset (1/2/3D) using Cohen's
% class RID Rihaczek Distribution. Includes inline functions written
% by Selin Aviyente for RID-Rihazcek calculation. The TF.power field
% contains the real part of the Rihaczek distribution corresponding to the
% real signal energy, since the imaginary part of the distribution has mean
% 0 and thus does not contribute to the marginals.
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
%
% INPUT
% -----
% 1) data: 1D(time), 2D(channelXtime) or 3D(channelXtimesample) (REQUIRED)
% 2) Fs: sampling rate of signal, in Hz (REQUIRED)
% 3) fRes: frequency resolution of outputin Hz, defaults to N(times) freqs
% 4) cwkernel: Choi-Williams parameter, defaults to 0.001
% 5) makePos: make distribution positive? 0 or 1, defaults to 0 
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

%defaults
if nargin<6 || isempty(plt)
    plt=0;
end
if nargin<5 || isempty(makePos)
    makePos=0;
    disp('returning both positive and negative values');
end
if nargin<4 || isempty(cwkernel)
    cwkernel = 0.001;
    disp('setting Choi-Williams kernel to 0.001 (default)');
end
if nargin<3 || isempty(fRes)
    nTimes = size(data,2);
    fout = linspace(0,Fs/2,nTimes);
    disp('setting frequencies output to 2*N (default)');
else
    fout = 0:fRes:Fs/2; %user-specified resolution
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

%preallocate
ridPowDat = zeros(nChan,numel(fout),nTimes,nTrls); %preallocate
ridPhasDat = zeros(nChan,numel(fout),nTimes,nTrls); %preallocate

%fix odd times, RID-Rihaczek hates this
if mod(nTimes,2)==1
    data=cat(2,data,data(:,end,:));
    flag=1;
else
    flag=0;
end


%progress
prog=1;
fprintf(1,'RID-Rihazcek progress: %3d%%\n',prog);
%sensor loop
for eloc = 1:nChan
    %trial loop
    for trl = 1:nTrls
        %get one sensor/trial of data
        dataY = squeeze(data(eloc,:,trl));
        RID_Rih = rid_rihaczek(dataY,2*numel(fout),cwkernel);
        if flag==1
            RID_Rih(:,end)=[]; %remove possible trailing point
        end
        ridPowDat(eloc,:,:,trl) = abs( real(RID_Rih(1:numel(fout),:)) );
        ridPhasDat(eloc,:,:,trl) = angle( RID_Rih(1:numel(fout),:) );
    end
    %track progress
    prog=100*(eloc/size(data,1));
    fprintf(1,'\b\b\b\b%3.0f%%',prog);
end
fprintf(1,'\n');
times=0:1/Fs:((1/Fs)*nTimes)-(1/Fs);

if makePos==1
    %set all of surface to minimal non-zero value
    tfThresh = squeeze(ridPowDat(:));
    tfThresh(tfThresh<=0)=[];
    ridPowDat(ridPowDat<min(tfThresh)) = min(tfThresh);
end
%format
tfRes.power   = squeeze(ridPowDat); %power
tfRes.phase   = squeeze(ridPhasDat); %phase
tfRes.freqs   = fout;
tfRes.times   = times;
tfRes.nsensor = nChan;
tfRes.ntrls   = nTrls;
tfRes.Fs      = Fs;
tfRes.cwkernel= cwkernel;
tfRes.makePos = makePos;
tfRes.method  ='RID-Rihaczek';
tfRes.scale   = 'linear';

% plot results
if plt == 1
    nf_tfplot(tfRes);
end

end






%CHWI_KRN Choi-Williams kernel function.
function K=chwi_krn(D,L,A)
%CHWI_KRN Choi-Williams kernel function.
%   K = CHWI_KRN(D,L,A) returns the values K of the Choi-Williams kernel
%   function evaluated at the doppler-values in matrix D and the lag-
%   values in matrix L. Matrices D and L must have the same size. The
%   values in D should be in the range between -1 and +1 (with +1 being
%   the Nyquist frequency). The parameter A is optional and controls the
%   "diagonal bandwidth" of the kernel. Matrix K is of the same size as
%   the matrices D and L. Parameter A defaults to 10 if omitted.

%   Copyright (c) 1998 by Robert M. Nickel
%   $Revision: 1.1.1.1 $
%   $Date: 2001/03/05 09:09:36 $
if nargin<3; A=[]; end
if isempty(A); A=10; end
K=exp((-1/(A*A))*(D.*D.*L.*L));
end

%reduced interference Rihaczek distribution
function tfd=rid_rihaczek(x,fbins,window)
tbins = length(x);
amb = zeros(tbins);

for tau = 1:tbins
    amb(tau,:) = ifft( conj(x) .* x([tau:tbins 1:tau-1]) );
end
ambTemp = [amb(:,tbins/2+1:tbins) amb(:,1:tbins/2)];
amb1 = [ambTemp(tbins/2+1:tbins,:); ambTemp(1:tbins/2,:)];
D=(-1:2/(tbins-1):1)'*(-1:2/(tbins-1):1);
L=D;
K=chwi_krn(D,L,window);
[s,d]=size(amb1);
df=K(1:s,1:d);
ambf = amb1 .* df;
A = zeros(fbins,tbins);
if tbins ~= fbins
    for tt = 1:tbins
        A(:,tt) = datawrap(ambf(:,tt), fbins);
    end
else
    A = ambf;
end
tfd = fft2(A);
end


