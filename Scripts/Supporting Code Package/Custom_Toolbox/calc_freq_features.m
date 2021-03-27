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


function [features_class_1, features_class_2] = calc_freq_features(data, triggers, classes, classes_idx, ...
    window_erds, fs, bins)
    
    psd_mat = estimate_psd_noclass(data, triggers, classes, classes_idx, ...
    window_erds, fs);
    stepsize = round(size(psd_mat, 1) / fs, 1);
    f_bins = bins ./ stepsize;
    features = zeros(size(bins, 1), size(psd_mat, 2), size(psd_mat, 3));

    for bin = 1 : size(bins, 1)
        features(bin, :, :) = mean(psd_mat(f_bins(bin, 1) : f_bins(bin, 2), :, :), 1);
    end

    features_class_1 = features(:, classes_idx == classes(1), :);
    features_class_2 = features(:, classes_idx == classes(2), :);
end