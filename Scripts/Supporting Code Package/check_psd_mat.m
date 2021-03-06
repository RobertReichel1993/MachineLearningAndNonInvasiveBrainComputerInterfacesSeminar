clear all
close all

datapath = 'rec/CourseRec_Marcel/*.mat';

% 121  ... Both feet
% 122  ... right hand
classlabel =  [121 122];
classnames = {'Both feet', 'Right Hand'};
channel_labels = {'FC3','FC1','FCz','FC2','FC4', 'C5','C3','C1','Cz', 'C2','C4','C6','CP3', 'CPz','CP4','Pz'};
fs = 256; 
data_window = [1 5];
time = data_window(1):1/fs:data_window(2)-1/fs;

[signal, events, event_stream] =  load_Data(datapath, classlabel);


%Bidirectional Filtering of the signal 
prefilt.fs =fs;  % Sampling Frequency
prefilt.order   = 4;    % Order
prefilt.Fc1 = 0.3;  % First Cutoff Frequency
prefilt.Fc2 = 128;    % Second Cutoff Frequency

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.bandpass('N,F3dB1,F3dB2', prefilt.order, prefilt.Fc1, prefilt.Fc2, prefilt.fs);
Hd = design(h, 'IIR', 'SOSScaleNorm','linf');
Sig = filtfilt(Hd.SoSMatrix,Hd.ScaleValues,signal);
% Sig = filter(Hd,signal); % for unidirectional filtering

%Epoch the data according to conditions


aCurTriggers =  events.trigger;
aCurClasslabels =  events.event_code;

[aAllSigOutIdx, aOutCHIdc] = PerformOutlierRejection(fs*data_window(1),fs*data_window(2), signal, aCurTriggers, fs,...
                                'EP_AMP_TH_MIN', -100,  'EP_AMP_TH_MAX',100 );
aCurTriggers(aAllSigOutIdx) = [];
aCurClasslabels(aAllSigOutIdx)  = [];

for class_idx = 1:size(classlabel, 2)
  
  [strial, sz] = trigg(Sig,aCurTriggers(aCurClasslabels == classlabel(class_idx)), data_window(1)*fs, data_window(2)*fs-1);
  trials{class_idx, :} = reshape(strial, sz);
  
end

%% Show Power Spectral Density Estimate

ylimiter = [-20,20];
xlimiter = [ 0 30];



for class_idx = 1:size(classlabel, 2)
  
  actual_condition =  trials{class_idx};
  
  for trial_idx = 1:size(actual_condition, 3)
  [tmp, f] = pwelch(actual_condition(:,:,trial_idx)', fs, 1,fs,fs);
  psd_trials(:,:,trial_idx) =  tmp;
  clear tmp
  end
  psd_mean(:,:,class_idx) = 20*log10(mean(psd_trials, 3));
  
end



channel_layout = [ 
                   0 1 1 1 1 1 0;
                   1 1 1 1 1 1 1;
                   0 1 0 1 0 1 1;]';
       
chidx = find(channel_layout == 1);



    figure
    
    
        suptitle_str = ['TestSubject - Power Spectral Density Estimate, Trial Average: ' classnames{1} ' vs. ' classnames{2} ];
        P = suptitle(suptitle_str);
        h = get(P,'Position');
        set(P,'Position',[h(1) h(2)+0.02 h(3)]);
    
    
    
    subplot(size(channel_layout,2),size(channel_layout,1),1)
    
    hold all
    for class_idx= 1:size(classlabel,2)
    
      g(class_idx)  = plot(1, psd_mean(1,1,(class_idx)), 'Linewidth', 2, 'DisplayName', classnames{(class_idx)} )
     
    end
    legend
    
    for channel_idx = 1:size(chidx,1)
    subplot(size(channel_layout,2),size(channel_layout,1), chidx(channel_idx))
     title([ 'Ch ' num2str(channel_idx) ' : '  ,channel_labels{channel_idx}] , 'FontSize', 10)
    hold all

    for class_idx= 1:size(classlabel,2)
    
    
    g(class_idx)  = plot(f, psd_mean(:,channel_idx,class_idx), 'Linewidth', 2, 'DisplayName', classnames{(class_idx)} )
    end
    
      set(gca,  'Ylim', ylimiter, 'XLim', xlimiter)
%      line([0 0], get(gca, 'YLim'));
%      line(get(gca, 'XLim'),[0 0]);
     xlabel ('Frequency (Hz)')
     ylabel ('dB/Hz')
    
    end








return

%%  Show Movement-Related Cortical potentials

ylimiter = [-8 6];
class_average = cellfun(@(x) median(x,3), trials, 'UniformOutput', 0);



channel_layout = [ 
                   0 1 1 1 1 1 0;
                   1 1 1 1 1 1 1;
                   0 1 0 1 0 1 1;]';
       
chidx = find(channel_layout == 1);



    figure
    
    
        suptitle_str = ['TestSubject - MRCP Comparison, Grand Average: ' classnames{1} ' vs. ' classnames{2} ];
        P = suptitle(suptitle_str);
        h = get(P,'Position');
        set(P,'Position',[h(1) h(2)+0.02 h(3)]);
    
    
    
    subplot(size(channel_layout,2),size(channel_layout,1),1)
    
    hold all
    for class_idx= 1:size(classlabel,2)
    
      g(class_idx)  = plot(1, class_average{class_idx,:}(1,1), 'Linewidth', 2, 'DisplayName', classnames{(class_idx)} )
     
    end
    legend
    
    for channel_idx = 1:size(chidx,1)
    subplot(size(channel_layout,2),size(channel_layout,1), chidx(channel_idx))
     title([ 'Ch ' num2str(channel_idx) ' : '  ,channel_labels{channel_idx}] , 'FontSize', 10)
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
    

% show the raw eeg

% eegplot_cp(signal', 125 , fs, 10,channel_labels, event_stream) 










% % get the datapath for loading the data
% if ~iscell( datapath )
%     [p,n,t] = fileparts(datapath);
%     datapath = dir( datapath );
%     files = sort( {datapath.name} )';
%     if ~isempty(p)
%         datapath = strcat( p, filesep, files );
%     end
%     datapath
% end
% clear n p t
% 
% signal = [];
% event_stream = [];
% for file_idx = 1:size(datapath,1)
% load(datapath{file_idx})
% signal = cat(1, signal, new_data(2:end,:)');
% event_stream = cat(1, event_stream, new_data(1,:)');
% clear new_data
% end 
% 
% 
% % show the raw eeg
% channel_labels = {'FC3','FC1','FCz','FC2','FC4', 'C5','C3','C1','Cz', 'C2','C4','C6','CP3', 'CPz','CP4','CPz'};
% % eegplot_cp(signal', 125 , fs, 10,channel_labels, event_stream) 
% 
% events.trigger = [];
% events.event_code = [];
% for class_idx = 1:size(classlabel,2) 
%  tmp  = find(event_stream == classlabel(class_idx));
%  events.trigger  = cat(1, events.trigger, tmp);
%  events.event_code =  cat(1, events.event_code, classlabel(class_idx)*ones(size(tmp,1),1));
%  clear tmp  
% end 



  





