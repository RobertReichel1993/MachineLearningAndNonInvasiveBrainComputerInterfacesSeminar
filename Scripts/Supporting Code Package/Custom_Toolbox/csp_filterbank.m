%This function calculates features for classification by calculating the
%PSD for the different trials and classes.
%
%Input:
%   data ........... The given data with the dimensions:
%                    [# of datapoints] x [# of channels]
%   triggers ....... The starting indices of all trials in the experiment
%   classes ........ An array indicating the possible classes
%   classes_idx ........ An array indicating the corrseponding class for each
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

function [features_class_1, features_class_2, freq_bands] = csp_filterbank(data, ...
    triggers, classes, classes_idx, window_erds, fs, num_filters, num_bands, ...
    frange)
    
    %Filtering data into frequency bands
    %result: matrix of dims (no.of samples)x(no. of channels)x(no. of filter bands)
    [data_bands, freq_bands] = filterbank(data, num_bands, frange, fs);

    %Splitting into classes
    data_mat = zeros(((window_erds(2) - window_erds(1)) * fs), length(triggers), ...
        size(data, 2), num_bands);
    for band = 1 : num_bands
        for cnt_labels = 1 : length(triggers)
           data_mat(:, cnt_labels, :, band) = ...
               data((triggers(cnt_labels) + window_erds(1) * fs : ...
               triggers(cnt_labels) + (window_erds(2) * fs - 1)), :, :);
        end
    end
    
    %Creating data for different trial classes (hand and feet)
    data_class_1 = data_mat(:, classes_idx == classes(1), :, :);
    data_class_2 = data_mat(:, classes_idx == classes(2), :, :);
    %Saving dimensions for easier handling and writing
    data_dims = size(data_bands);
    % permuting the dimensions for easier manipulation
    data_class_1 = permute(data_class_1, [1, 3, 2, 4]);
    data_class_2 = permute(data_class_2, [1, 3, 2, 4]);
    
    %Now training CSP filter for each possible frequency band
    %Preallocating matrices to save the filtered data and filters
    data_csp = zeros(data_dims(1), num_filters, data_dims(3)); % reminder: sb is the size vector
    csp_model = zeros(data_dims(2), data_dims(2));
    csp_mat = zeros(data_dims(2), num_filters, num_bands);
    %Now define additional filter (which eigenvectors are used for filtering)
    filt_sel = logical([ones(1, num_filters/2) zeros(1, data_dims(2) - num_filters) ones(1, num_filters/2)]);
    %Iterate over frequency bands and filter each band
    for band = 1 : num_bands
        csp_model = csp_train(data_class_1(:, :, :, band), data_class_2(:, :, :, band),...
        'shrinkage', 0.2);
        %Filter the data with the CSP
        data_csp(:, :, band) = csp_filter(csp_model, filt_sel, ...
            data_bands(:, :, band));
        csp_mat(:, :, band) = csp_model(:, filt_sel);
    end

    %Splitting into classes
    data_mat_csp = zeros(((window_erds(2) - window_erds(1)) * fs), length(triggers), ...
        size(data_csp, 2), num_bands);
    
    for band = 1 : num_bands
        for cnt_labels = 1 : length(triggers)
           data_mat_csp(:, cnt_labels, :, band) = ...
               data_csp((triggers(cnt_labels) + window_erds(1) * fs : ...
               triggers(cnt_labels) + (window_erds(2) * fs - 1)), :, band);
        end
    end
    
    %Creating data for different trial classes (hand and feet)
    %Dimensions are now (# datapoints) x (# el in class) x (# channels) x (# freq bands)
    data_class_1_csp = data_mat_csp(:, classes_idx == classes(1), :, :);
    data_class_2_csp = data_mat_csp(:, classes_idx == classes(2), :, :);
    
    %Calculating the band power
    %The feature matrices are shaped (# trials) x (# channels) x (# bands)
    features_class_1 = 20 * log10(squeeze(sum(data_class_1_csp.^2, 1)));
    features_class_2 = 20 * log10(squeeze(sum(data_class_2_csp.^2, 1)));
    
end