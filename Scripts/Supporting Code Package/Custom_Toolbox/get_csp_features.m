%This function calculates features for classification by calculating the
%PSD for the different trials and classes.
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
%   num_filters .... Number of selected CSP filters in total (e.g. 2
%                    filters means biggest and smallest Eigenvalue)
%
%Output:
%   features_class_1 ... Features for the frequency domain for class 1
%                        [number of features] x [number of trials] x [number of channels]
%   features_class_2 ... Features for the frequency domain for class 2
%                        [number of features] x [number of trials] x [number of channels]
%
%Dependencies: none

function [features_class_1, features_class_2] = get_csp_features(data, ...
    triggers, classes, classes_idx, window_erds, fs, num_filters)
    
    %Splitting into different classes
    data_mat = zeros(((window_erds(2) - window_erds(1)) * fs), length(triggers), ...
        size(data, 2));
    for cnt_labels = 1 : length(triggers)
       data_mat(:, cnt_labels, :) = ...
           data((triggers(cnt_labels) + window_erds(1) * fs : ...
           triggers(cnt_labels) + (window_erds(2) * fs - 1)), :, :);
    end
    
    %Training CSP filter
    data_class_1 = permute(data_mat(:, classes_idx == classes(1), :), [1, 3, 2]);
    data_class_2 = permute(data_mat(:, classes_idx == classes(2), :), [1, 3, 2]);
    model = csp_train(data_class_1, data_class_2, 'shrinkage', 0.2);
    %Selecting filter parameters
    filters = logical([ones(1, num_filters) zeros(1, size(data_mat, 3) ...
        - 2 * num_filters) ones(1, num_filters)]);
    %Filtering data
    data_csp = csp_filter(model, filters, data);
    
    %Splitting into different classes
    data_mat = zeros(((window_erds(2) - window_erds(1)) * fs), length(triggers), ...
        size(data_csp, 2));
    for cnt_labels = 1 : length(triggers)
       data_mat(:, cnt_labels, :) = ...
           data_csp((triggers(cnt_labels) + window_erds(1) * fs : ...
           triggers(cnt_labels) + (window_erds(2) * fs - 1)), :, :);
    end
    %Estimating PSD over CSP filtered data
    psd_mat = estimate_psd_noclass(data, triggers, classes, classes_idx, ...
        window_erds, fs);
    
    %Splitting data into classes
    features_class_1 = psd_mat(:, classes_idx == classes(1), :);
    features_class_2 = psd_mat(:, classes_idx == classes(2), :);
end