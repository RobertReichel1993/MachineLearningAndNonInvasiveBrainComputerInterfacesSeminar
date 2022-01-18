%This function analyses the features gathered through CSP filtering the
%given data and calculating the 
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
%   rep_fac ........ Number of repetitions of the K-fold algorithm
%   kfold_fac ...... The factor k for the K-fold algorithm
%   figtitle ... The title under which the created figures are supposed
%                   to be saved, once as .jpeg and once as .fig file
%
%Output:
%   features_class_1 ... Best performing features for the frequency domain for class 1
%                        [number of features] x [number of trials] x [number of channels]
%   features_class_2 ... Best performing features for the frequency domain for class 2
%                        [number of features] x [number of trials] x [number of channels]
%   fs ................. The sampling frequency used for calculation (in
%       case of downsampling, this could change)
%
%Dependencies: none

function [data_modified, classes_modified, triggers_modified] = add_artificial_restperiod(data, ...
    triggers, pos_classes, classes, window_erds, fs)
    
    min_len = min(length(classes(classes == pos_classes(1))), length(classes(classes == pos_classes(2))));
    rest_data = zeros((4 * fs), length(triggers), size(data, 2));
    %Splitting into different classes
    data_mat = zeros(((window_erds(2) - window_erds(1)) * fs), length(triggers), ...
        size(data, 2));
    for cnt_labels = 1 : length(triggers)
       data_mat(:, cnt_labels, :) = ...
           data((triggers(cnt_labels) + window_erds(1) * fs : ...
           triggers(cnt_labels) + (window_erds(2) * fs - 1)), :, :);
       
       snr = 50;
       %Cutting out rest period and adding gaussian noise to make signals
       %not look conpletely the same
       rest_data(:, cnt_labels, :) = awgn(data((triggers(cnt_labels) + window_erds(2) * fs : ...
           triggers(cnt_labels) + ((window_erds(2) + 4) * fs - 1)), :, :), snr);
    end
    
    filler = zeros(2560, 1, 16);
    %Adding same number of rest periods than trial periods
    rest_periods = rest_data(:, 1 : min_len, :);
    data_rest = ones(2 * 2560 + 4 * fs, min_len, size(data, 2)) * 824.1698;
    for cnt = 1 : min_len
        data_rest(:, cnt, :) = cat(1, filler, rest_periods(:, cnt, :), filler);
    end
    classes_modified = cat(2, classes, ones(1, min_len) * 62);
    others = max(triggers) : min(diff(triggers)) : (max(triggers) + ((min(diff(triggers))) * min_len)) - 1;
    triggers_modified = cat(2, triggers, others);
    data_rest = reshape(data_rest, [], 16);
    data_modified = cat(1, data, data_rest);
end