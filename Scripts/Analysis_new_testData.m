%%
%Clearing out workspace
close all;
clear all;
clc;

%%
%Defining and adding paths to workspace
addpath('Supporting Code Package\Custom_Toolbox');
addpath('Supporting Code Package\reducedOutlierRejection');
addpath('Supporting Code Package\ERDS-Maps');
addpath('Supporting Code Package\eeglab');
addpath('Supporting Code Package\lda_20160129');
addpath('Supporting Code Package\csp_20160122');

channels = {'FC3','FC1','FCz','FC2','FC4','C5','C3','C1','Cz',...
    'C2','C4','C6','CP1','CPz','CP2','Pz'};

%Reading location file for electrodes
loc_file = '..\electrode_locations_used.xyz';
%The file is not read correctly
[eloc, e_labels, theta, radius, indices] = readlocs(fullfile(loc_file));

d = load('EEGdata_2021_01_28.mat');
data_raw = squeeze(d.ans.data(:, 4:19, :))';

onset_idx = find(squeeze(d.ans.data(:, 1, :))==4)';
labels = squeeze(d.ans.data(:, 2, :))';
labels = labels(onset_idx);
classes = unique(labels);
%Defining timings
window_mrcp = [-3 4];
window_erds = [-6.5 0 5];
%If no movement class is implemented
ref_window_AC23 = [-4.5 -3.7];
%If only hand & feet class
ref_window = [-4.5 -1.5];
%%
%Filtering data
%Saving sampling frequency because it is faster and easier to type
fs = 128;
%fs = events_AC21.sample_rate;
%Done to downsample data
%Analysis filter -> 4th order bandpass [0.1 40]
[b, a] = butter(4, [.1 40] ./ (fs / 2));
%Filtering between 0.3 and 3 Hz for MRCP
[b_mrcp, a_mrcp] = butter(4, [.3 3] ./ (fs / 2));
%Filtering everything and creating labels and onset_idx
%Bandpass filtering
data_AC21_erds = filtfilt(b, a, data_raw);
data_AC21_mrcp = filtfilt(b_mrcp, a_mrcp, data_raw);
%Finding triggers for when events start
triggers_AC21 = onset_idx;
%Finding event codes (hand or foot trial) (the trial start ones, e.g. 60, 61 and 62)
trials_AC21 = labels;

%Artifact rejection for Patient AC 21
[IdcsOfTaintedTrials_AC21, ~] = PerformOutlierRejection(window_mrcp(1) * fs, ...
    window_mrcp(2) * fs - 1, data_AC21_erds, triggers_AC21, fs);
%Now cutting out all bad trials
triggers_AC21(IdcsOfTaintedTrials_AC21) = [];
trials_AC21(IdcsOfTaintedTrials_AC21)  = [];

plot_Analysis(data_AC21_erds, triggers_AC21, trials_AC21, window_mrcp, ...
    window_erds, ref_window, channels, eloc, fs, 'TestWithMyData_');

% Calculation of features in Time Domain
downsample_fac = 16;
p_val = 0.05;
rep_fac = 10;
kfold_fac = 5;
freqs = [[8 12]; [10 14]; [14 19]; [17 22]; [20 25]; [23 28]; [26 31]];

%Patient AC21
%%Calculating features
%Calculating frequency domain features according to paper
[features_class_1_AC21_avrfreq, features_class_2_AC21_avrfreq] = calc_freq_features(data_AC21_erds, ...
    triggers_AC21, classes, trials_AC21, window_erds, fs, freqs);
%Calculate frequency features with CSP
[features_class_1_AC21_csp, features_class_2_AC21_csp] = analyse_csp_features(data_AC21_erds, ...
    triggers_AC21, classes, trials_AC21, window_erds, fs, 10, ...
    5, 'Accuracy plot CSP filtered data Patient AC21');

%Transforming csp features two different ways
features_class_1_AC21_csp_all = sum(features_class_1_AC21_csp);
features_class_2_AC21_csp_all = sum(features_class_2_AC21_csp);

features_class_1_AC21_csp_bins = zeros(size(freqs ,1), size(features_class_2_AC21_csp_all, 2), ...
    size(features_class_1_AC21_csp_all, 3));
features_class_2_AC21_csp_bins = zeros(size(freqs ,1), size(features_class_2_AC21_csp_all, 2), ...
    size(features_class_2_AC21_csp_all, 3));
for bin = 1 : size(freqs, 1)
    features_class_1_AC21_csp_bins(bin, :, :) = mean(...
        features_class_1_AC21_csp(freqs(bin, 1) : features_class_1_AC21_csp(bin, 2), :, :), 1);
    features_class_2_AC21_csp_bins(bin, :, :) = mean(...
        features_class_2_AC21_csp(freqs(bin, 1) : features_class_2_AC21_csp(bin, 2), :, :), 1);
end

add_info = 'popogugale';

%Calculating features for method 1 (my "interesting" idea)
[features_class_1_AC21_m1, features_class_2_AC21_m1] = get_features_significantPoints(data_AC21_mrcp, ...
    triggers_AC21, classes, trials_AC21, window_mrcp, fs, p_val,channels, ...
    strcat('Significance window sanity check Robert Method, Patient AC 21', add_info));
%Calculating features for method 2 (Valeria's Method)
[features_class_1_AC21_m2, features_class_2_AC21_m2] = get_features_significanceWindow(data_AC21_mrcp, ...
    triggers_AC21, classes, trials_AC21, window_mrcp, fs, p_val, downsample_fac, channels, ...
    strcat('Significance window sanity check Valerias Method, Patient AC 21', add_info));
%Calculating features for method 3 (As in paper Method)
[features_class_1_AC21_paper, features_class_2_AC21_paper, ~] = get_features_paper(data_AC21_mrcp, ...
    triggers_AC21, classes, trials_AC21, window_mrcp, fs, downsample_fac, channels, ...
    strcat('Significance window sanity check Paper Method, Patient AC 21', add_info));

%%Classification with single-domain features
%Classification and kfolding for frequency features from paper
[acc_AC21_freq_paper] = permute_and_kfold(features_class_1_AC21_avrfreq, ...
    features_class_2_AC21_avrfreq, rep_fac, kfold_fac);
%Classification and kfolding for frequency features from CSP across all
%frequencies
[acc_AC21_freq_csp_all] = permute_and_kfold(features_class_1_AC21_csp_all, ...
    features_class_2_AC21_csp_all, rep_fac, kfold_fac);
%Classification and kfolding for frequency features from CSP across defined
%frequency bins
[acc_AC21_freq_csp_bins] = permute_and_kfold(features_class_1_AC21_csp_bins, ...
    features_class_2_AC21_csp_bins, rep_fac, kfold_fac);
%Classification and kfolding for time domain features, Method Paper
[acc_AC21_time_paper] = permute_and_kfold(features_class_1_AC21_paper, ...
    features_class_2_AC21_paper, rep_fac, kfold_fac);
%Classification and kfolding for time domain features, Method Robert
[acc_AC21_time_robert] = permute_and_kfold(features_class_1_AC21_m1, ...
    features_class_2_AC21_m1, rep_fac, kfold_fac);
%Classification and kfolding for time domain features, Method Valeria
[acc_AC21_time_valeria] = permute_and_kfold(features_class_1_AC21_m2, ...
    features_class_2_AC21_m2, rep_fac, kfold_fac);

save(strcat('..\Data\Results TestWithMyData', add_info), 'acc_AC21_freq_paper', 'acc_AC21_freq_csp_all', ...
    'acc_AC21_freq_csp_bins', 'acc_AC21_time_paper', ...
    'acc_AC21_time_robert', 'acc_AC21_time_valeria');

save(strcat('..\Data\Features TestWithMyData', add_info), 'features_class_1_AC21_avrfreq', ...
    'features_class_2_AC21_avrfreq', ...
    'features_class_1_AC21_csp_all', 'features_class_1_AC21_csp_all', ...
    'features_class_1_AC21_csp_bins', 'features_class_1_AC21_csp_bins', ...
    'features_class_1_AC21_m1', 'features_class_2_AC21_m1', ...
    'features_class_1_AC21_m2', 'features_class_2_AC21_m2', ...
    'features_class_1_AC21_paper', 'features_class_2_AC21_paper');