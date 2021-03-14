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


function [p_vals, sig_mask] = calc_p_values(data, triggers, classes, ...
    classes_idx, window_mrcp, fs, p_val)

    %Splitting into different classes
    data_mat = zeros(((window_mrcp(2) - window_mrcp(1)) * fs), length(triggers), ...
        size(data, 2));
    for cnt_labels = 1 : length(triggers)
       data_mat(:, cnt_labels, :) = ...
           data((triggers(cnt_labels) + (window_mrcp(1) * fs) : ...
           triggers(cnt_labels) + (window_mrcp(2) * fs - 1)), :, :);
    end

    %Creating data for different trial classes (hand and feet)
    data_class_1 = data_mat(:, classes_idx == classes(1), :);
    data_class_2 = data_mat(:, classes_idx == classes(2), :);

    alpha = p_val / size(data_mat, 2);
    %Now use Wilcoxon test to calculate p values for each electrode
    %First create array of zeroes to hold results (better computation time)
    p_vals = zeros(size(data_mat, 1), 1, size(data_mat, 3));
    sig_mask = zeros(size(data_mat, 1), 1, size(data_mat, 3));
    for electrode = 1 : size(data_mat, 3)
        for sample = 1 : size(data_mat, 1)
            p_vals(sample, :, electrode) = ranksum(data_class_1(sample, :, electrode), ...
                data_class_2(sample, :, electrode), 'alpha', alpha);
            %Search for indixes where p value is smaller than alpha
            if p_vals(sample, :, electrode) < alpha
                sig_mask(sample, :, electrode) = 1;
            else
                sig_mask(sample, :, electrode) = 0;
            end
        end
    end
    p_vals = squeeze(p_vals);
    sig_mask = squeeze(sig_mask);
end