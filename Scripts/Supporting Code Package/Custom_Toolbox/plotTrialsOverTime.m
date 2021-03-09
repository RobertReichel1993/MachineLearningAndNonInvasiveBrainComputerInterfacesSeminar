%This function reads in a gdf file and saves it as an .mat file and returns
%the data itself and, if the data is single precission, it automatically is
%converted into double precission values
%
%Input:
%   data ... The data to analyze
%   trigg
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


function [stuff] = plotTrialsOverTime(data, triggers, electrodes, times, ...
    fs, fname)
    %Splitting into different classes
    data_mat = zeros(((times(2) - times(1)) * fs), length(triggers), ...
        size(data, 2));
    for cnt_labels = 1 : length(triggers)
       data_mat(:, cnt_labels, :) = ...
           data((triggers(cnt_labels) + times(1) * fs : ...
           triggers(cnt_labels) + (times(2) * fs - 1)), :, :);
    end

    fig = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    subplotmask = [2 3 4 5 6 8 9 10 11 12 13 14 16 17 18 20];
    for electrode = 1 : size(data, 2)
        subplot(3, 7, subplotmask(electrode));
        imagesc(data_mat(:, :, electrode)');
        title(electrodes{electrode});
        xlabel('Time [ms]');
        ylabel('Number of trials [A.U.]');
    end
    stuff = 0;
    saveas(fig, strcat(fullfile('../Plots/', fname)), 'jpeg');
    saveas(fig, strcat(fullfile('../Plots/', fname)), 'fig');
end