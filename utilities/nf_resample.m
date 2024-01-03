function TF = nf_resample( TF, tVec, fVec )
%
% GENERAL
% -------
% Resamples TF structures to new time/frequency vectors using 
% interpolation.
%
% OUTPUT
% ------
% TF - structure output by tfUtility.m and tf_fun functions
%
% INPUT
% -----
% 1) TF - structure output by tfUtility.m and tf_fun functions
% 2) tVec - new time vector. data is interpolated to new times.
% 3) fVec - new freq vector. data is interpolated to new freqs
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

if nargin<3
    fVec = [];
end
if nargin<2
    tVec = [];
end
if nargin<1 || isempty(TF)
    error('at least a TF structure is a required input');
end
%time resample
if ~isempty(tVec)
    %check for uniform time sampling
    if length(unique(round(diff(tVec),5)))>1
        error('use uniform time sampling!');
    end
    disp(['resampling data to ' num2str(1/mean(diff(tVec))) ' Hz sampling rate in time.']);
    %power first
    tfP=TF.power; %get power
    if TF.nsensor>1
        tfP=interp1(TF.times,permute(tfP,[3,1,2,4]),tVec); %times,chans,freqs,trls
        tfP = permute(tfP,[2,3,1,4]);
    else
        tfP=interp1(TF.times,permute(tfP,[2,1,3]),tVec); %times,freqs,trls
        tfP = permute(tfP,[2,1,3]);
    end
    TF.power=tfP;
    %now phase if it exists
    if isfield(TF,'phase')
        tfR=TF.phase; %get phase
        if TF.nsensor>1
            tfR=wrapToPi(interp1(TF.times,unwrap(permute(tfR,[3,1,2,4])),tVec)); %times,chans,freqs,trials
            tfR = permute(tfR,[2,3,1,4]); %chans,freqs,times,trials
        else
            tfR=wrapToPi(interp1(TF.times,unwrap(permute(tfR,[2,1,3])),tVec)); %times,freqs,trials
            tfR = permute(tfR,[2,1,3]); %freqs,times,trials
        end
        TF.phase=tfR;
    end
    TF.times=tVec;
    TF.Fs=1/mean(diff(tVec));
end
%frequency resample
if ~isempty(fVec)
    disp('resampling data in frequency.');
    %power first
    tfP=TF.power; %get power
    if TF.nsensor>1
        tfP=interp1(TF.freqs,permute(tfP,[2,1,3,4]),fVec); %freqs,chans,times,trls
        tfP = permute(tfP,[2,1,3,4]); %chans,freqs,times,trials
    else
        tfP=interp1(TF.freqs,tfP,fVec); %freqs,times,trls
    end 
    TF.power=tfP;
        
    %now phase if it exists
    if isfield(TF,'phase')
        tfR=TF.phase; %get phase
        if TF.nsensor>1
            tfR=wrapToPi(interp1(TF.freqs,unwrap(permute(tfR,[2,1,3,4])),fVec));
            tfR = permute(tfR,[2,1,3,4]);
        else
            tfR=wrapToPi(interp1(TF.freqs,unwrap(tfR),fVec));           
        end
        TF.phase=tfR;
    end
    TF.freqs=fVec;
end

end





