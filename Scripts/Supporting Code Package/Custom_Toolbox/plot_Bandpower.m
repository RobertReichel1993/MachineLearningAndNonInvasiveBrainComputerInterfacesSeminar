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


function [stuff] = plot_Bandpower(data, triggers, classes, classes_idx, ...
    electrodes, times, fs, fname)
    %Splitting into different classes
    data_mat = zeros(((times(2) - times(1)) * fs), length(triggers), ...
        size(data, 2));
    for cnt_labels = 1 : length(triggers)
       data_mat(:, cnt_labels, :) = ...
           data((triggers(cnt_labels) + times(1) * fs : ...
           triggers(cnt_labels) + (times(2) * fs - 1)), :, :);
    end
    
    %Creating data for different trial classes (hand and feet)
    data_class_1 = data_mat(:, classes_idx == classes(1), :);
    data_class_2 = data_mat(:, classes_idx == classes(2), :);
    
    data_class_1 = permute(data_class_1, [3, 1, 2]);
    data_class_2 = permute(data_class_2, [3, 1, 2]);

    %Estimating PSD and visualizing it
    fig = figure();
    subplotmask = [2 3 4 5 6 8 9 10 11 12 13 14 16 17 18 20];
    for electrode = 1 : size(data, 2)
        subplot(3, 7, subplotmask(electrode));
        [psd, frange] = estimate_psd(data_class_1(electrode, :, :), ...
            data_class_2(electrode, :, :), ...
            electrodes(electrode), fs, 0.5, ...
            fullfile('../Plots/', strcat(fname, string(electrode))));
        plot(frange, psd(:, 1), frange,psd(:, 2), 'LineWidth', 2);
        title(electrodes{electrode});
        xlabel('Frequency [Hz]');
        ylabel('Power density [Db]');
        xlim([0 40]);
        %legend('Class 1','Classe 2');
    end
    stuff = 0;
    saveas(fig, strcat(fullfile('../Plots/', fname)), 'jpeg');
    saveas(fig, strcat(fullfile('../Plots/', fname)), 'fig');
end