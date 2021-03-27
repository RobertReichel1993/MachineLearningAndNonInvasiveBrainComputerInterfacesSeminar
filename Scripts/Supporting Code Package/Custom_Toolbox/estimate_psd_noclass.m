%This function estimates the Power Spectral Density (PSD) of the given
%input signals and then visualizes the PSD over the frequency range to
%compare between two classes for a two class classification problem.
%
%Input:
%   data_hand ... The data for the first class
%                       [number of channels] x [number of datapoints per trial] x [number of trials in class 1]
%   data_feet ... The data for the second class
%                       [number of channels] x [number of datapoints per trial] x [number of trials in class 2]
%   fs .......... The sampling frequency of the signals
%   overlap ..... The overlap in window length for PSD calculation
%                       in percent (0 to 1)
%
%Output:
%   psd ... The calculated power spectral density across the frequency
%           range from 0 to fs/2 averaged across the trials.
%           The output has the dimention:
%           [number of frequency components] x [number of classes] x [number of channels]
%
%Dependencies: none

function [psd_mat] = estimate_psd_noclass(data, triggers, classes, classes_idx, ...
    times, fs)
    %Splitting into different classes
    data_mat = zeros(((times(2) - times(1)) * fs), length(triggers), ...
        size(data, 2));
    for cnt_labels = 1 : length(triggers)
       data_mat(:, cnt_labels, :) = ...
           data((triggers(cnt_labels) + times(1) * fs : ...
           triggers(cnt_labels) + (times(2) * fs - 1)), :, :);
    end
    
    %Creating data for different trial classes (hand and feet)
    data_class_1 = data_mat(:, classes_idx == classes(1), :);
    data_class_2 = data_mat(:, classes_idx == classes(2), :);

    psd_mat = zeros(((fs / 2) + 1), size(data_mat, 2), size(data_mat, 3));
    
    for trial = 1 : size(data_mat, 2)
        for electrode = 1 : size(data_mat, 3)
            psd_mat(:, trial, electrode) = 20 * log10(pwelch(data_mat(:, trial, electrode), fs, 0.5));
    end
end