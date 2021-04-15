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

function [features_class_1, features_class_2, fs] = analyse_csp_features(data, ...
    triggers, classes, classes_idx, window_erds, fs, rep_fac, ...
    kfold_fac, figtitle)

    %Preallocating storage space
    accs = zeros(rep_fac, floor(size(data, 2) / 2));
    %Calculating accuracies dependent on number of CSP filters applied
    for num_filter = 1 : floor(size(data, 2) / 2)
        [features_class_1, features_class_2] = get_csp_features(data, ...
            triggers, classes, classes_idx, window_erds, fs, num_filter);

        accs(:, num_filter) = permute_and_kfold(features_class_1, ...
            features_class_2, rep_fac, kfold_fac);
    end
    %Calculating mean accuracies
    acc_means = mean(accs);
    [~, idx_max] = max(acc_means);
    %Plotting results
    fig = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    plot(1 : floor(size(data, 2) / 2), acc_means);
    xlabel('Number of used CSP filters');
    ylabel('Classification accuracy');
    saveas(fig, fullfile('../Plots/', figtitle), 'jpeg');
    saveas(fig, fullfile('../Plots/', figtitle), 'fig');
    
    %Calculating maximum accuracy features
    [features_class_1, features_class_2] = get_csp_features(data, ...
            triggers, classes, classes_idx, window_erds, fs, idx_max);
end