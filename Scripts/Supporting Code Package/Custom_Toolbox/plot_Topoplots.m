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


function [data] = plot_Topoplots(data, triggers, eloc, fs, figtitle)
    %Creating full screen figure
    fig = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    %Looping over 10 screenshots of the data
    cnt_max = 10;
    for cnt_tp = 1 : cnt_max
        subplot(2, 5, cnt_tp);
        tmp = strcat(string(cnt_tp / cnt_max), {' '}, 's after stimulus onset');
        title(tmp);
        topoplot(data(triggers(1) + round(fs * (cnt_tp - 1) / ...
            cnt_max), :), eloc, 'interplimits', 'electrodes');
    end
    saveas(fig, fullfile('../Plots/', figtitle), 'jpeg');
    saveas(fig, fullfile('../Plots/', figtitle), 'fig');
end