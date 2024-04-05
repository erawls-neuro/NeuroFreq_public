%
%
% plot results from mat_spec_param
%
%
function h = plotMatSpecParam( parm_spec )

h=figure;
subplot(1,3,1);
plot(parm_spec.f,parm_spec.data,'linewidth',5,'Color','b'); hold on;
plot(parm_spec.f,parm_spec.modelFit,'linewidth',5,'Color','r'); hold on;
text(parm_spec.f(1),...
    parm_spec.modelFit(1), ...
    ['\leftarrow RSquare = ' num2str(round(parm_spec.RSquare,2))]);
title('Full Spectrum');
xlabel('Frequency (Hz)');
ylabel('log-power');
subplot(1,3,2);
plot(parm_spec.f,parm_spec.aPeriodicData,'linewidth',5,'Color','b'); hold on;
plot(parm_spec.f,parm_spec.aPeriodicFit,'linewidth',5,'Color','r'); hold on;
text(parm_spec.f(1),...
    parm_spec.aPeriodicFit(1), ...
    ['\leftarrow Exponent = ' num2str(round(parm_spec.aperiodicParms(end),2))]);
title('Aperiodic Spectrum');
xlabel('Frequency (Hz)');
ylabel('log-power');
subplot(1,3,3);
plot(parm_spec.f,parm_spec.PeriodicData,'linewidth',5,'Color','b'); hold on;
plot(parm_spec.f,parm_spec.PeriodicFit,'linewidth',5,'Color','r'); hold on;
for i=1:size(parm_spec.peakParms,1)
    [~,pw]=min(abs( parm_spec.f - parm_spec.peakParms(i,1) ));
    text(parm_spec.peakParms(i,1),...
    parm_spec.PeriodicFit( pw ), ...
    ['\downarrow Frequency = ' num2str(round(parm_spec.peakParms(i,1),2)) ' Hz'], ...
    'Rotation',90);
end
title('Oscillatory Spectrum');
xlabel('Frequency (Hz)');
ylabel('log-power');
%annotate

end