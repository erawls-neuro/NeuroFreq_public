function h = nf_tfplot( TF )
%
% GENERAL
% -------
% Plot a time-frequency structure returned by either tfUtility.m or any of
% the tf_fun functions.
%
% Averages over all channels for plotting, and optionally baselines the
% average. Additionally plots the inter-trial phase coherence, if there is
% a phase field.
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
% Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

%first, a normal plot
h{1}=simple_tf_plot(TF);
sgtitle(h{1},'Total Power');
%check for parameterized
if isfield(TF,'SPRiNT') %parameterized
    TF.power=TF.SPRiNT.osc_power;
    h{2} = simple_tf_plot(TF);
    sgtitle(h{2},'Oscillatory Power');
    TF.power=TF.SPRiNT.ap_power;
    h{3} = simple_tf_plot(TF);
    sgtitle(h{3},'Aperiodic Power');
end
%check for ERP-removed
if isfield(TF,'erprem') %ERP-removed
    TF.power=TF.erprem.erppow;
    h{4} = simple_tf_plot(TF);
    sgtitle(h{4},'ERP Power');
    TF.power=TF.erprem.erprempow;
    TF.phase=TF.erprem.erpremphase;
    h{5} = simple_tf_plot(TF);
    sgtitle(h{5},'ERP Removed Power');
end
%check for CPM
if isfield(TF,'cpm') %CPM
    TF.power=TF.CPM.PLmean;
    h{6} = simple_tf_plot(TF);
    sgtitle(h{6},'Phase-locked Power');
    TF.power=TF.CPM.NPLmean;
    h{7} = simple_tf_plot(TF);
    sgtitle(h{7},'Non-phase-locked Power');
end
    
function h=simple_tf_plot(TF)
    
    %figure;
    h=figure(1000*round(rand,3));
    
    %pull data
    powDat = TF.power;
    if isfield(TF,'phase')
        phasDat = TF.phase;
    end
    
    %multiple trials/channels?
    nChans = TF.nsensor;
    nTrls = TF.ntrls;

    %average power if appropriate
    if nTrls>1
        powDat = squeeze(mean(powDat,ndims(powDat))); %last dimension
    end
    if nChans>1
        powDat = squeeze(mean(powDat)); %first dimension
    end

    %average phase if appropriate
    if isfield(TF,'phase')
        if nTrls>1
            phasDat = squeeze(abs(mean(exp(1i*TF.phase),ndims(phasDat))));
        end
        if nChans>1
            phasDat = squeeze(mean(phasDat));
        end
    end
    
%     %continue to average over outer dimensions!
     if ~ismatrix(powDat)
         keyboard;
     end
%         powDat = squeeze(mean(powDat,ndims(powDat)));
%         if isfield(TF,'phase')
%             phasDat = squeeze(mean(phasDat,ndims(phasDat)));
%         end
%     end

    %get marginals
    powTMarg = mean(powDat);
    powFMarg = mean(powDat,2);
    powLim = [prctile( powDat(:), 3 ), prctile( powDat(:), 97 )];
    if isfield(TF,'phase')
        phasTMarg = mean(phasDat);
        phasFMarg = mean(phasDat,2);
        phasLim = [-prctile( abs(phasDat(:)), 97 ), prctile( abs(phasDat(:)), 97 )];
    end
    
    %plot it
    if isfield(TF,'phase')
        %plot marginals
        subplot(3,7,[1,8]);
        plot(powFMarg,TF.freqs,'color','k','linewidth',5); axis tight;
        xlabel('power');
        ylabel('freqs (Hz)');
        subplot(3,7,[16,17]);
        plot(TF.times,powTMarg,'color','k','linewidth',5); axis tight;
        xlabel('time (seconds)');
        ylabel('power');
        subplot(3,7,[5,12]);
        plot(phasFMarg,TF.freqs,'color','k','linewidth',5); axis tight;
        xlabel('ITPC');
        ylabel('freqs (Hz)');
        subplot(3,7,[20,21]);
        plot(TF.times,phasTMarg,'color','k','linewidth',5); axis tight;
        xlabel('time (seconds)');
        ylabel('ITPC');
        %plot contour
        subplot(3,7,[2,3,9,10]);
        contourf(TF.times,TF.freqs,powDat,100,'linestyle','none');
        caxis(powLim);
        title('Power');
        cbar;
        subplot(3,7,[6,7,13,14]);
        contourf(TF.times,TF.freqs,phasDat,100,'linestyle','none');
        caxis(phasLim);
        title('Inter-Trial Phase Coherence');
        cbar;
        colormap('parula');
    else
        %plot marginals
        subplot(3,3,[1,4]);
        plot(powFMarg,TF.freqs,'color','k','linewidth',5); axis tight;
        xlabel('power');
        ylabel('freqs (Hz)');
        subplot(3,3,[8,9]);
        plot(TF.times,powTMarg,'color','k','linewidth',5); axis tight;
        xlabel('time (seconds)');
        ylabel('power');
        %plot contour
        subplot(3,3,[2,3,5,6]);
        
        contourf(TF.times,TF.freqs,powDat,100,'linestyle','none');
        caxis(powLim);
        title('Power');
        cbar;
        colormap('parula');
    end
    
% else %it is parameterized
%     
%     dataX = TF.power;
%     dataY = TF.SPRiNT.ap_power;
%     dataZ = TF.SPRiNT.osc_power;
%     
%     %multiple trials?
%     if ndims(dataX)==4
%         nTrls = size(dataX,4);
%     else
%         nTrls = 1;
%     end
%     
%     %average if appropriate
%     if nTrls>1
%         powDat1 = squeeze(mean(mean(dataX,4)));
%         powDat2 = squeeze(mean(mean(dataY,4)));
%         powDat3 = squeeze(mean(mean(dataZ,4)));
%         if isfield(TF,'phase')
%             phasDat = squeeze(mean(abs(mean(exp(1i*TF.phase),4))));
%         end
%     else
%         powDat1 = squeeze(mean(dataX));
%         powDat2 = squeeze(mean(dataY));
%         powDat3 = squeeze(mean(dataZ));
%         if isfield(TF,'phase')
%             phasDat = squeeze(mean(TF.phase));
%         end
%     end
%     
%     %get marginals
%     powTMarg1 = mean(powDat1);
%     powFMarg1 = mean(powDat1,2);
%     powTMarg2 = mean(powDat2);
%     powFMarg2 = mean(powDat2,2);
%     powTMarg3 = mean(powDat3);
%     powFMarg3 = mean(powDat3,2);
%     powLim1 = [prctile( powDat1(:), 3 ), prctile( powDat1(:), 97 )];
%     powLim2 = [prctile( powDat2(:), 3 ), prctile( powDat2(:), 97 )];
%     powLim3 = [prctile( powDat3(:), 3 ), prctile( powDat3(:), 97 )];
%     if isfield(TF,'phase')
%         phasTMarg = mean(phasDat);
%         phasFMarg = mean(phasDat,2);
%         phasLim = [-prctile( abs(phasDat(:)), 97 ), prctile( abs(phasDat(:)), 97 )];
%     end
%     
%     %plot it
%     h=figure;
%     if isfield(TF,'phase')
%         %plot marginals
%         subplot(3,15,[1,16]);
%         plot(powFMarg1,TF.freqs,'color','k','linewidth',5); axis tight;
%         xlabel('power');
%         ylabel('freqs (Hz)');
%         subplot(3,15,[32,33]);
%         plot(TF.times,powTMarg1,'color','k','linewidth',5); axis tight;
%         xlabel('time (seconds)');
%         ylabel('power');
%         subplot(3,15,[5,20]);
%         plot(powFMarg2,TF.freqs,'color','k','linewidth',5); axis tight;
%         xlabel('power');
%         ylabel('freqs (Hz)');
%         subplot(3,15,[36,37]);
%         plot(TF.times,powTMarg2,'color','k','linewidth',5); axis tight;
%         xlabel('time (seconds)');
%         ylabel('power');
%         subplot(3,15,[9,24]);
%         plot(powFMarg3,TF.freqs,'color','k','linewidth',5); axis tight;
%         xlabel('power');
%         ylabel('freqs (Hz)');
%         subplot(3,15,[40,41]);
%         plot(TF.times,powTMarg3,'color','k','linewidth',5); axis tight;
%         xlabel('time (seconds)');
%         ylabel('power');
%         subplot(3,15,[13,28]);
%         plot(phasFMarg,TF.freqs,'color','k','linewidth',5); axis tight;
%         xlabel('ITPC');
%         ylabel('freqs (Hz)');
%         subplot(3,15,[44,45]);
%         plot(TF.times,phasTMarg,'color','k','linewidth',5); axis tight;
%         xlabel('time (seconds)');
%         ylabel('ITPC');
%         
%         %plot contours
%         subplot(3,15,[2,3,17,18]);
%         contourf(TF.times,TF.freqs,powDat1,100,'linestyle','none');
%         caxis(powLim1);
%         title('total power');
%         cbar;
%         subplot(3,15,[6,7,21,22]);
%         contourf(TF.times,TF.freqs,powDat2,100,'linestyle','none');
%         caxis(powLim2);
%         title('aperiodic power');
%         cbar;
%         subplot(3,15,[10,11,25,26]);
%         contourf(TF.times,TF.freqs,powDat3,100,'linestyle','none');
%         caxis(powLim3);
%         title('oscillatory power');
%         cbar;
%         subplot(3,15,[14,15,29,30]);
%         contourf(TF.times,TF.freqs,phasDat,100,'linestyle','none');
%         caxis(phasLim);
%         title('inter-trial phase coherence');
%         cbar;
%         colormap('parula');
%         
%     else
%         %plot marginals
%         subplot(3,11,[1,12]);
%         plot(powFMarg1,TF.freqs,'color','k','linewidth',5); axis tight;
%         xlabel('power');
%         ylabel('freqs (Hz)');
%         subplot(3,11,[24,25]);
%         plot(TF.times,powTMarg1,'color','k','linewidth',5); axis tight;
%         xlabel('time (seconds)');
%         ylabel('total power');
%         subplot(3,11,[5,16]);
%         plot(powFMarg2,TF.freqs,'color','k','linewidth',5); axis tight;
%         xlabel('power');
%         ylabel('freqs (Hz)');
%         subplot(3,11,[28,29]);
%         plot(TF.times,powTMarg2,'color','k','linewidth',5); axis tight;
%         xlabel('time (seconds)');
%         ylabel('aperiodic power');
%         subplot(3,11,[9,20]);
%         plot(powFMarg3,TF.freqs,'color','k','linewidth',5); axis tight;
%         xlabel('power');
%         ylabel('freqs (Hz)');
%         subplot(3,11,[32,33]);
%         plot(TF.times,powTMarg3,'color','k','linewidth',5); axis tight;
%         xlabel('time (seconds)');
%         ylabel('oscillatory power');
%         
%         %plot contours
%         subplot(3,11,[2,3,13,14]);
%         contourf(TF.times,TF.freqs,powDat1,100,'linestyle','none');
%         caxis(powLim1);
%         title('total power');
%         cbar;
%         subplot(3,11,[6,7,17,18]);
%         contourf(TF.times,TF.freqs,powDat2,100,'linestyle','none');
%         caxis(powLim2);
%         title('aperiodic power');
%         cbar;
%         subplot(3,11,[10,11,21,22]);
%         contourf(TF.times,TF.freqs,powDat3,100,'linestyle','none');
%         caxis(powLim3);
%         title('oscillatory power');
%         cbar;
%         colormap('parula');
%     end
%     
% end
