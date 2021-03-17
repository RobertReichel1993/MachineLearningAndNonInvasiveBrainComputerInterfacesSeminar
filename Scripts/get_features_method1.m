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


function [features_class_1, features_class_2] = get_features_method1(data, ...
    triggers, classes, classes_idx, window_mrcp, fs, p_val)

    [~, sig_mask, data_class_1, data_class_2] = calc_p_values(data, ...
    triggers, classes, classes_idx, window_mrcp, fs, p_val);
    
    %define significance window
    sig_idx = find(sum(sig_mask, 2));
    %Getting features
    features_class_1 = data_class_1(sig_idx, :, :);
    features_class_2 = data_class_2(sig_idx, :, :);
end