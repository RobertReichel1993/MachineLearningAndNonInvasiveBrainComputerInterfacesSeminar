%This function takes the given data, splits it into trials as defined by
%the given triggers and classes, performs the Wilcoxon Rank Sum test to
%find statistical significantly different points between the two classes
%and then returns the data split into the two classes, the p-values for all
%timepoints of the trials and a significance mask, which indicates which
%array values are statistical significantly different given the chosen
%p-value
%
%Input:
%   data .......... The given data with the dimensions:
%                   [# of datapoints] x [# of channels]
%   triggers ...... The starting indices of all trials in the experiment
%   pos_classes ... The possible classes occuring in classes_idx
%   classes ....... An array indicating the corrseponding class for each
%                   trial indicated by triggers
%   window_mrcp ... The time window in which the MRCP is theorized to
%   happen
%   fs ............ The used sampling frequency
%   p_val ......... The p-value used for testing if differences are
%                   statistically significant
%
%Output:
%   p_vals ....... The p_values corresponding to each timepoint in the trials
%   sig_mask ..... The significance mask where 1 indicates statistical
%                   significance and 0 if not
%                   [# of datapoints per trial] x [# of channels]
% data_class_1 ... The data split into trials for class 1
%                   [# of datapoints per trial] x [# of trials in this class] x [# of channels]
% data_class_2 ... The data split into trials for class 2
%                   [# of datapoints per trial] x [# of trials in this class] x [# of channels]
%
%Dependencies: none

function [p_vals, sig_mask, data_class_1, data_class_2] = calc_p_values(data, ...
    triggers, pos_classes, classes, window_mrcp, fs, p_val)

    %Splitting into different classes
    data_mat = zeros(((window_mrcp(2) - window_mrcp(1)) * fs), length(triggers), ...
        size(data, 2));
    for cnt_labels = 1 : length(triggers)
       data_mat(:, cnt_labels, :) = ...
           data((triggers(cnt_labels) + (window_mrcp(1) * fs) : ...
           triggers(cnt_labels) + (window_mrcp(2) * fs - 1)), :, :);
    end

    %Creating data for different trial classes (hand and feet)
    data_class_1 = data_mat(:, classes == pos_classes(1), :);
    data_class_2 = data_mat(:, classes == pos_classes(2), :);

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