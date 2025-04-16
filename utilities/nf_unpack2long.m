function tab = nf_unpack2long( TF )
% GENERAL
% -------
% Unpacks a TF structure to long format for further analysis.
%
%
% OUTPUT
% ------
% TFtab - long table for EEG-TF data.
%
% INPUT
% -----
% 1) TF - structure output by nf_tftransform.m and tf_fun functions
%
%
% E. Rawls, erawls89@gmail.com, rawls017@umn.edu.
% Jul 2023
% Copyright (c) 2023 by E. Rawls.
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA

nsensor = TF.nsensor;
freqs = TF.freqs;
times = TF.times;
if isfield(TF, 'conds')
    ntrls = TF.conds;
else
    ntrls = TF.ntrls;
end
loc = cell(nsensor,numel(freqs),numel(times),ntrls);
fr = zeros(nsensor,numel(freqs),numel(times),ntrls);
ti = zeros(nsensor,numel(freqs),numel(times),ntrls);
tr = zeros(nsensor,numel(freqs),numel(times),ntrls);

if isfield(TF,'behavior')
    fields = fieldnames( TF.behavior ,'-full');
    beh = cell( numel(fields),nsensor,numel(freqs),numel(times),ntrls );
end

for i=1:nsensor
    for j=1:numel(freqs)
        for k=1:numel(times)
            for l=1:ntrls
                
                loc{i,j,k,l} = TF.chanlocs(i).labels;
                fr(i,j,k,l) = TF.freqs(j);
                ti(i,j,k,l) = TF.times(k);
                tr(i,j,k,l) = l;
                
                if isfield(TF,'behavior')
                    for p=1:numel(fields)
                        beh{p,i,j,k,l} = getfield(TF.behavior(l),fields{p});
                    end
                end
                
            end
        end
    end
end

tab=table;
tab.channel = loc(:);
tab.frequency = fr(:);
tab.time = ti(:);
tab.trial = tr(:);
if isfield(TF,'behavior')
    for p=1:numel(fields)
        tab.(fields{p}) = squeeze(beh(p,:))';
    end
end
tab.power = TF.power(:);
tab.phase = TF.phase(:);
if isfield(TF,'SPRiNT')
    tab.ap_power = TF.SPRiNT.ap_power(:);
    tab.osc_power = TF.SPRiNT.osc_power(:);
end
if isfield(TF,'erprem')
    tab.erprem_power = TF.erprem.erprempow(:);
    tab.erp_power = TF.erprem.erppow(:);
    tab.erprem_phase = TF.erprem.erpremphase(:);
end


end

