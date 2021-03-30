%This function uses the given EEG data to calculate features for
%classification in the time domain. The used method is comparison between
%execution and rest trials of MRCPs, where the timepoints are used to
%perform a Wilcoxon Rank Sum Test to estimate, if the amplitude values are
%different for different time points. The features in this method are then
%all significant timepoints.
%
%Input:
%   data .......... The given data with the dimensions:
%                   [# of datapoints] x [# of channels]
%   triggers ...... The starting indices of all trials in the experiment
%   classes ....... An array indicating all possible classes in
%                   classes_idx
%   classes_idx ... An array indicating the corrseponding class for each
%                   trial indicated by triggers
%   window_mrcp ... The time window in which the MRCP is theorized to
%                   happen
%   fs ............ The used sampling frequency
%   p_val ......... The p-value used for calculating the significance level
%                   of the data points
%
%Output:
%   features_class_1 ... Features for the frequency domain for class 1
%                        [number of features] x [number of trials] x [number of channels]
%   features_class_2 ... Features for the frequency domain for class 2
%                        [number of features] x [number of trials] x [number of channels]
%
%Dependencies: none


function [features_class_1, features_class_2] = get_features_significantPoints(data, ...
    triggers, classes, classes_idx, window_mrcp, fs, p_val)

    [~, sig_mask, data_class_1, data_class_2] = calc_p_values(data, ...
    triggers, classes, classes_idx, window_mrcp, fs, p_val);
    
    %define significance window
    sig_idx = find(sum(sig_mask, 2));
    %Getting features
    features_class_1 = data_class_1(sig_idx, :, :);
    features_class_2 = data_class_2(sig_idx, :, :);
end