%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%sgTF DEMO: time-frequency transforms with different methods%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc;
nRun   = 5;                                                       %how many times to run test
nTimes = round(linspace(250,1000,10));                            %time points in random signal
Fs     = 250;                                                      %sampling rate
nChan  = 32;
nTrials= 100;
timing = zeros(nRun,numel(nTimes),9);                              %preallocate
for i=1:nRun
    for j=1:numel(nTimes)
        disp(['run = ' num2str(i) ', time = ' num2str(j)]);
        data = rand(nChan, nTimes(j), nTrials);
        %First Class: Linear Methods
        tic; TF1 = nf_stft(data,Fs); timing(i,j,1)=toc;            %spectrogram
        clear TF1
        tic; TF2 = nf_filterHilbert(data,Fs); timing(i,j,2)=toc;   %filter-Hilbert
        clear TF2
        tic; TF3 = nf_demodulation(data,Fs); timing(i,j,3)=toc;    %complex demodulation
        clear TF3
        tic; TF4 = nf_cwt(data,Fs); timing(i,j,4)=toc;             %Continuous Wavelet
        clear TF4
        tic; TF5 = nf_wavelet(data,Fs); timing(i,j,5)=toc;         %Morlet wavelet
        clear TF5
        tic; TF6 = nf_sTransform(data,Fs); timing(i,j,6)=toc;      %Stockwell Transform
        clear TF6
        %Second Class: Quadratic Distributions
        tic; TF7 = nf_ridBinomial(data,Fs); timing(i,j,7)=toc;     %Type-II Binomial RID
        clear TF7
        tic; TF8 = nf_ridBornJordan(data,Fs); timing(i,j,8)=toc;   %Type-II Born-Jordan RID
        clear TF8
        tic; TF9 = nf_ridRihaczek(data,Fs); timing(i,j,9)=toc;     %RID-Rihaczek TFD
        clear TF9
    end
end
colors = {'#e41a1c',...
    '#377eb8',...
    '#4daf4a',...
    '#984ea3',...
    '#ff7f00',...
    '#ffff33',...
    '#a65628',...
    '#f781bf',...
    '#999999'};
figure;
for i=1:9
    plot(nTimes,squeeze(mean(timing(:,:,i))),'color',colors{i}); hold on;
    shadedErrorBar(nTimes,squeeze(mean(timing(:,:,i))), ...
        squeeze(std(timing(:,:,i))),...
        {'color',colors{i},'markerfacecolor',colors{i}}); hold on;
end
set(gca,'YScale', 'log');



