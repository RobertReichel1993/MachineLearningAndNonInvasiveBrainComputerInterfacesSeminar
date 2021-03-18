%This function creates topoplots of the signals given in data
%
%Input:
%   data ....... The given data with the dimensions:
%                   [# of datapoints] x [# of channels]
%   triggers ... The starting indices of all trials in the experiment
%   eloc ....... The location of the EEG electrodes as read from the
%                   eeglab function "readlocs"
%   fs ......... The used sampling frequency
%   figtitle ... The title under which the created figures are supposed
%                   to be saved, once as .jpeg and once as .fig file
%
%Output:
%   data ... The data used in the calculations, not really needed
%
%Dependencies: eeglab (from the supporting code package, not the whole
%                       eeglab package)

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