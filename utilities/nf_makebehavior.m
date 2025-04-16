function TF = nf_makebehavior( TF, tab )
% GENERAL
% -------
% Make a NeuroFreq-style 'behavior' file from a table of task stimuli and
% behaviors. Table must have column headers and a number of rows equal to
% the number of trials in the input EEG.
%
%
% OUTPUT
% ------
% TF - TF structure including behavior.
%
% INPUT
% -----
% 1) TF - structure output by nf_tftransform.m and tf_fun functions
% 2) tab - table of task conditions, stimuli, and behaviors
%
%
% E. Rawls, erawls89@gmail.com, rawls017@umn.edu.
% Aug 2023
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

behavior = readtable( tab );
vars = behavior.Properties.VariableNames;
behav=[];
if isfield(TF,'conds')
    if TF.conds ~= size(behavior,1)
        error('behavior must have the same number of entries as TF has trials');
    end
else
    if TF.ntrls ~= size(behavior,1)
        error('behavior must have the same number of entries as TF has trials');
    end
end
for h=1:size(behavior,1)
    for j=1:length(vars)
        behav(h).(vars{j}) = table2array(behavior(h,j));
    end
end
TF.behavior = behav;


end