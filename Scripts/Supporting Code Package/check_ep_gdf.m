clear all
close all

filepath =  ['rec/Screening v20151125/*.gdf'];

% 770 Right hand
% 771 Both Feet
% 779 Rest
classlabel=[770 ,771, 779];
data_window = [-3 5];
ylimiter = [-20 20];

classnames = {'rHand', 'bFeet', 'Rest'};

[signal header events files] = gdf_multiread(filepath,'DATAFORMAT', 'MATRIX', 'UPSAMPLEMODE', 'NEAREST');
% Correct for NANS
iNumNANs = sum ( sum ( isnan ( signal ) ) );
iLen = size ( signal, 1 );

    if ( iNumNANs > 0 )
      fprintf ( '## CORRECTED [%d] NANs to [0]!!!\n', iNumNANs );
    signal ( isnan ( signal ) ) = 0;
    end


    
    
    
labels= struct2cell(header.signals);
labels = labels(1,:);

    



    
fs = events.sample_rate;
time = data_window(1):1/fs:data_window(2)-1/fs;



% Get all Condition triggers and their Classlabel in 2 Vectors
aCurTriggers = [];
aCurClasslabels = [];

for class_idx =  1:size(classlabel,2)
  aSingleClassTriggers  = double(events.position(events.event_code == classlabel(:,class_idx)));
  aCurTriggers = [aCurTriggers aSingleClassTriggers];
  aCurClasslabels = [aCurClasslabels  classlabel(class_idx)*ones(1,size(aSingleClassTriggers,2))];
  clear aSingleClassTriggers     
end





%Outlier Rejection

%% Outlier Rejection
% Parameters that can be adapted

%   default parameters
%   Bandpass Filter Width (Hz)     : FILTER_BAND = [3 35];
%   Bandpass Filter Order          : FILTER_ORDER = 4;
%   Channel Probalility Threshold  : CH_PROB_TH = 5;
%   Channel Kurtosis  Threshold    : CH_KURT_TH = 8;
%   Epoch Amplitude   Threshold Min: EP_AMP_TH_MIN = -100;
%   Epoch Amplitude   Threshold Max: EP_AMP_TH_MAX = +100;
%   Epoch Probability Threshold    : EP_PROB_TH = 4;
%   Epoch Kurtosus    Threshold    : EP_KURT_TH = 4;
%   Channel Varicance Threshold    : CH_VAR_FACT = 5;


[aAllSigOutIdx, aOutCHIdc] = PerformOutlierRejection(fs*data_window(1),fs*data_window(2), signal, aCurTriggers, fs,...
                                'EP_AMP_TH_MIN', -100,  'EP_AMP_TH_MAX',100 );
aCurTriggers(aAllSigOutIdx) = [];
aCurClasslabels(aAllSigOutIdx)  = [];



%Bidirectional Filtering of the signal 
prefilt.fs =fs;  % Sampling Frequency
prefilt.order   = 4;    % Order
prefilt.Fc1 = 0.3;  % First Cutoff Frequency
prefilt.Fc2 = 3;    % Second Cutoff Frequency

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.bandpass('N,F3dB1,F3dB2', prefilt.order, prefilt.Fc1, prefilt.Fc2, prefilt.fs);
Hd = design(h, 'IIR', 'SOSScaleNorm','linf');
Sig = filtfilt(Hd.SoSMatrix,Hd.ScaleValues,signal);
% Sig = filter(Hd,signal);



%Epoch the data according to conditions

for class_idx = 1:size(classlabel, 2)
  
  [strial sz] = trigg(Sig,aCurTriggers(aCurClasslabels == classlabel(class_idx)), data_window(1)*fs, data_window(2)*fs-1);
  trials{class_idx, :} = reshape(strial, sz);
  
end

class_average = cellfun(@(x) median(x,3), trials, 'UniformOutput', 0);









channel_layout = [ 0 0 0 0 1 0 0 0 0;
                   0 1 0 0 1 0 0 1 0;
                   1 1 1 1 1 1 1 1 1;
                   0 1 0 0 1 0 0 1 0;]';
       
chidx = find(channel_layout == 1);



    figure
    subplot(size(channel_layout,2),size(channel_layout,1),1)
    
    hold all
    for class_idx= 1:size(classlabel,2)
    
      g(class_idx)  = plot(1, class_average{class_idx,:}(1,1), 'Linewidth', 2, 'DisplayName', classnames{(class_idx)} )
     
    end
    legend
    
    for channel_idx = 1:size(chidx,1)
    subplot(size(channel_layout,2),size(channel_layout,1), chidx(channel_idx))
     title([ 'Ch ' num2str(channel_idx) ' : '  ,labels{channel_idx}] , 'FontSize', 10)
    hold all

    for class_idx= 1:size(classlabel,2)
    
    
    g(class_idx)  = plot(time, class_average{class_idx,:}(channel_idx,:), 'Linewidth', 2, 'DisplayName', classnames{(class_idx)} )
    end
    
     set(gca,  'Ylim', ylimiter, 'XLim', data_window)
     line([0 0], get(gca, 'YLim'));
     line(get(gca, 'XLim'),[0 0]);
     xlabel ('time (s)')
     ylabel ('µV')
    
    end
    

    
    return
    

marker =  zeros(size(signal, 1), 1);
marker(aCurTriggers) =  aCurClasslabels;


eegplot_cp(signal', 125 , fs, 10,labels, marker) 

%% EEG plot function

% signal (channels x time), channel width (e.g. 125),
% sample frequency, displaylength in seconds (e.g. 10),
% channel labels (cell with strings e.g {'C3', 'Cz','C4'}, 
% markers (like triggers) - vector of zeros the same length as signal,
% with values at the designated trigger points










