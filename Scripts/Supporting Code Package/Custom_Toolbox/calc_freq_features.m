%This function reads in a gdf file and saves it as an .mat file and returns
%the data itself and, if the data is single precission, it automatically is
%converted into double precission values
%
%Input:
%   data ........... The given data with the dimensions:
%                    [# of datapoints] x [# of channels]
%   triggers ....... The starting indices of all trials in the experiment
%   classes ........ An array indicating the corrseponding class for each
%                    trial indicated by triggers
%   classes_idx .... An array indicating the corrseponding class for each
%                    trial indicated by triggers
%   window_erds .... The time window in which the ERDS is theorized to
%                    happen
%   fs ............. The used sampling frequency
%   bins ........... The frequency bins in which the psd averages are to be
%                    calculated to be used as features
%
%Output:
%   features_class_1 ... Features for the frequency domain for class 1
%                        [number of features] x [number of trials] x [number of channels]
%   features_class_2 ... Features for the frequency domain for class 2
%                        [number of features] x [number of trials] x [number of channels]
%
%Dependencies: none

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