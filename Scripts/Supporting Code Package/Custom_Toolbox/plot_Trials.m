%This function reads in a gdf file and saves it as an .mat file and returns
%the data itself and, if the data is single precission, it automatically is
%converted into double precission values
%
%Input:
%   filename ... The name of the input file
%   path ....... The path to the gdf files
%
%Output:
%   data ... A struct containing all information from the gdf file
%
%Dependencies: eeglab toolbox
%
%Remarks:
%EEG.data -> data from channels
%EEG.times -> timepoints
%EEG.srate -> sample rate
%EEG.nbchan -> number of channels with names, locations, etc.
%EEG.chanlocs -> Channel locations
%EEG.event -> events (60, 61) for hand and foot and add. info


function [data, minima, maxima] = plot_Trials(data, triggers, classes, classes_idx, ...
    electrodes, times, fs, figtitle)

    time = times(1) : 1/fs : times(2)-1/fs;
    
    %Splitting into different classes
    data_mat = zeros(((times(2) - times(1)) * fs), length(triggers), ...
        size(data, 2));
    for cnt_labels = 1 : length(triggers)
       data_mat(:, cnt_labels, :) = ...
           data((triggers(cnt_labels) + times(1) * fs : ...
           triggers(cnt_labels) + (times(2) * fs - 1)), :, :);
    end

    %Plotting everything
    subplotmask = [2 3 4 5 6 8 9 10 11 12 13 14 16 17 18 20];
    for cnt_trials = 1 : length(triggers)
        minima(cnt_trials) = min(min(data_mat(:, cnt_trials , :)));
        maxima(cnt_trials) = min(max(data_mat(:, cnt_trials , :)));
        if minima(cnt_trials) < -100
            h = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
            for electrode = 1 : size(data, 2)
                subplot(3, 7, subplotmask(electrode));
                plot(time, data_mat(:, cnt_trials , electrode));
                xlabel('Time / s');
                ylabel('Potential / µV');
                ylim([-120 70]);
                %title(strcat('Trials for hand movement on ', electrodes{1}));
            end
        end 
    end
end