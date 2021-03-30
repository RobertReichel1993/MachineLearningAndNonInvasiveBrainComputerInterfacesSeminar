%This function uses the given EEG data to calculate features for
%classification in the time domain. The method uses a sliding window over
%of 1 second over the whole MRCP window and uses all timepoints inside that
%window of the downsampled signal as features and then chooses the best
%performing window and returns the corresponding features.
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
%   d_fac ......... The downsampling factor by which the signal frequency
%                   is reduced
%
%Output:
%   features_class_1 ... Features for the frequency domain for class 1
%                        [number of features] x [number of trials] x [number of channels]
%   features_class_2 ... Features for the frequency domain for class 2
%                        [number of features] x [number of trials] x [number of channels]
%   shift_max .......... The index, by which the window is shifted to get
%                           the best performing window (maybe for further evaluation)
%
%Dependencies: none


function [features_class_1, features_class_2, shift_max] = get_features_paper(data, ...
    triggers, classes, classes_idx, window_mrcp, fs, d_fac)

    fs = fs / d_fac;
    data = downsample(data, d_fac);
    triggers = round(triggers ./ d_fac);

    %Splitting into different classes
    data_mat = zeros(((window_mrcp(2) - window_mrcp(1)) * fs), length(triggers), ...
        size(data, 2));
    for cnt_labels = 1 : length(triggers)
       data_mat(:, cnt_labels, :) = ...
           data((triggers(cnt_labels) + window_mrcp(1) * fs : ...
           triggers(cnt_labels) + (window_mrcp(2) * fs - 1)), :, :);
    end
    
    accs = zeros(1, fs * (window_mrcp(2) - window_mrcp(1)) - 9);
    for w_shift = 1 : fs * (window_mrcp(2) - window_mrcp(1)) - 9
        f_c_1 = data_mat(w_shift : w_shift + 9, classes_idx == classes(1), :);
        f_c_2 = data_mat(w_shift : w_shift + 9, classes_idx == classes(2), :);
        
        accs(w_shift) = mean(permute_and_kfold(f_c_1, f_c_2, 10, 5));
    end
    [~, shift_max] = max(accs);
    features_class_1 = data_mat(shift_max : shift_max + 9, classes_idx == classes(1), :);
    features_class_2 = data_mat(shift_max : shift_max + 9, classes_idx == classes(2), :);
end