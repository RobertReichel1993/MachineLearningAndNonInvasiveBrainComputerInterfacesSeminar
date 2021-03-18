%This function creates plots of the bandpower of the signals given in data
%
%Input:
%   data ......... The given data with the dimensions:
%                   [# of datapoints] x [# of channels]
%   triggers ..... The starting indices of all trials in the experiment
%   electrodes ... The names of the EEG channels given in a struct of
%                   strings
%   times ........ The time window in which the MRCP is theorized to
%                   happen
%   fs ........... The used sampling frequency
%   fname ........ The title under which the created figures are supposed
%                   to be saved, once as .jpeg and once as .fig file
%
%Output:
%   stuff ... Currently not needed, included for debugging purposes
%
%Dependencies: none

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