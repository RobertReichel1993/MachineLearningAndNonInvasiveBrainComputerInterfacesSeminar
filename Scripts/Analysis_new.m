%%
%Clearing out workspace
close all;
clear all;
clc;

%%
%Defining and adding paths to workspace
path_data = '..\Data\rec';
addpath('Supporting Code Package\Custom_Toolbox');
addpath('Supporting Code Package\reducedOutlierRejection');
addpath('Supporting Code Package\ERDS-Maps');
addpath('Supporting Code Package\eeglab');
addpath('Supporting Code Package\lda_20160129');
addpath('Supporting Code Package\csp_20160122');
%Just for completenes sake
channels = {'FC3','FC1','FCz','FC2','FC4','C5','C3','C1','Cz',...
    'C2','C4','C6','CP1','CPz','CP2','Pz'};
%Reading location file for electrodes
loc_file = '..\electrode_locations_used.xyz';
%The file is not read correctly
[eloc, e_labels, theta, radius, indices] = readlocs(fullfile(loc_file));
%Defining cues
attention = 768; %Starting each run, ending previous imagination period
reference = 785; %Now the reference interval starts
start = 789; %Start the movement now
ending = 792; %End of the whole experiment run
hand = 61; %Instruction on what to do after start signal
foot = 60; %Instruction on what to do after start signal
poss_trig = [60 61 62];
%Defining timings
window_mrcp = [-2 4];
window_erds = [-5 0 4];
%If no movement class is implemented
ref_window_AC23 = [-4.5 -3.7];
%If only hand & feet class
ref_window = [-4.5 -3.6];
%%
%Loading data
cnt_1 = 1;
cnt_2 = 1;
cnt_3 = 1;
files_AC21 = {};
files_AC22 = {};
files_AC23 = {};
all_files = dir(path_data);
for i = 1 : length(all_files)
      if contains(convertCharsToStrings(all_files(i).name), 'AC21')
          files_AC21(cnt_1) = {char(strcat("..\Data\rec\", convertCharsToStrings(all_files(i).name)))};
          cnt_1 = cnt_1 + 1;
      elseif contains(convertCharsToStrings(all_files(i).name), 'AC22')
          files_AC22(cnt_2) = {char(strcat("..\Data\rec\", convertCharsToStrings(all_files(i).name)))};
          cnt_2 = cnt_2 + 1;
      elseif contains(convertCharsToStrings(all_files(i).name), 'AC23')
          files_AC23(cnt_3) = {char(strcat("..\Data\rec\", convertCharsToStrings(all_files(i).name)))};
          cnt_3 = cnt_3 + 1;
      end
end
[signal_AC21, header_AC21, events_AC21, files_AC21] = gdf_multiread(files_AC21);
[signal_AC22, header_AC22, events_AC22, files_AC22] = gdf_multiread(files_AC22);
[signal_AC23, header_AC23, events_AC23, files_AC23] = gdf_multiread(files_AC23);
%Transforming signals from cell arrays to matrixes
signal_AC21 = reshape(cell2mat(signal_AC21), [length(cell2mat(signal_AC21)) / 16, 16]);
signal_AC22 = reshape(cell2mat(signal_AC22), [length(cell2mat(signal_AC22)) / 16, 16]);
signal_AC23 = reshape(cell2mat(signal_AC23), [length(cell2mat(signal_AC23)) / 16, 16]);
%Now remove NaNs (Why are there NaNs in this data??)
signal_AC21(isnan(signal_AC21)) = 0;
signal_AC22(isnan(signal_AC22)) = 0;
signal_AC23(isnan(signal_AC23)) = 0;
%%
%Filtering data
%Saving sampling frequency because it is faster and easier to type
fs = events_AC21.sample_rate;
%Done to downsample data
%Analysis filter -> 4th order bandpass [0.1 40]
[b, a] = butter(4, [.1 40] ./ (fs / 2));
%Filtering between 0.3 and 3 Hz for MRCP
[b_mrcp, a_mrcp] = butter(4, [.3 3] ./ (fs / 2));
%Filtering everything and creating labels and onset_idx
%Bandpass filtering
data_AC21_erds = filtfilt(b, a, signal_AC21);
data_AC21_mrcp = filtfilt(b_mrcp, a_mrcp, signal_AC21);
data_AC22_erds = filtfilt(b, a, signal_AC22);
data_AC22_mrcp = filtfilt(b_mrcp, a_mrcp, signal_AC22);
data_AC23_erds = filtfilt(b, a, signal_AC23);
data_AC23_mrcp = filtfilt(b_mrcp, a_mrcp, signal_AC23);
%Finding triggers for when events start
triggers_AC21 = events_AC21.position(ismember(events_AC21.event_code, ...
    poss_trig));
triggers_AC22 = events_AC22.position(ismember(events_AC22.event_code, ...
    poss_trig));
triggers_AC23 = events_AC23.position(ismember(events_AC23.event_code, ...
    poss_trig));
%Finding event codes (hand or foot trial) (the trial start ones, e.g. 60, 61 and 62)
trials_AC21 = double(events_AC21.event_code(ismember(events_AC21.event_code, ...
    poss_trig)));
trials_AC22 = double(events_AC22.event_code(ismember(events_AC22.event_code, ...
    poss_trig)));
trials_AC23 = double(events_AC23.event_code(ismember(events_AC23.event_code, ...
    poss_trig)));
%Shifting triggers by delay
triggers_AC21 = double(triggers_AC21) + double(round(3.6 * fs));
triggers_AC22 = double(triggers_AC22) + double(round(3.6 * fs));
triggers_AC23 = double(triggers_AC23) + double(round(3.7 * fs));
%%
%Artifact rejection for Patient AC 21
[IdcsOfTaintedTrials, ~] = PerformOutlierRejection(window_mrcp(1) * fs, ...
    window_mrcp(2) * fs - 1, data_AC21_erds, triggers_AC21, fs);
%Now cutting out all bad trials
triggers_AC21(IdcsOfTaintedTrials) = [];
trials_AC21(IdcsOfTaintedTrials)  = [];
%Artifact rejection for Patient AC 22
[IdcsOfTaintedTrials, ~] = PerformOutlierRejection(window_mrcp(1) * fs, ...
    window_mrcp(2) * fs - 1, data_AC22_erds, triggers_AC22, fs);
%Now cutting out all bad trials
triggers_AC22(IdcsOfTaintedTrials) = [];
trials_AC22(IdcsOfTaintedTrials)  = [];
%Artifact rejection for Patient AC 23
[IdcsOfTaintedTrials, ~] = PerformOutlierRejection(window_mrcp(1) * fs, ...
    window_mrcp(2) * fs - 1, data_AC23_erds, triggers_AC23, fs);
%Now cutting out all bad trials
triggers_AC23(IdcsOfTaintedTrials) = [];
trials_AC23(IdcsOfTaintedTrials)  = [];
%%
% Analysis of Data
%%{
%Patient AC21
plot_Analysis(data_AC21_erds, triggers_AC21, trials_AC21, window_mrcp, ...
    window_erds, ref_window, channels, eloc, fs, 'AC21');
%Patient AC22
plot_Analysis(data_AC22_erds, triggers_AC22, trials_AC22, window_mrcp, ...
    window_erds, ref_window, channels, eloc, fs, 'AC22');
%Patient AC23
plot_Analysis(data_AC23_erds, triggers_AC23, trials_AC23, window_mrcp, ...
    window_erds, ref_window_AC23, channels, eloc, fs, 'AC23');
%%}
%%
% Calculation of features in Time Domain
downsample_fac = 16;
p_val = 0.5;
rep_fac = 10;
kfold_fac = 5;
freqs = [[8 12]; [10 14]; [14 19]; [17 22]; [20 25]; [23 28]; [26 31]];
%%
%%{
%Patient AC21
%%Calculating features
%Calculating frequency domain features according to paper
[features_class_1_AC21_avrfreq, features_class_2_AC21_avrfreq] = calc_freq_features(data_AC21_erds, ...
    triggers_AC21, [60 61], trials_AC21, window_erds, fs, freqs);
%Calculate frequency features with CSP
[features_class_1_AC21_csp, features_class_2_AC21_csp] = analyse_csp_features(data_AC21_erds, ...
    triggers_AC21, [60 61], trials_AC21, window_erds, fs, 10, ...
    5, 'Accuracy plot CSP filtered data Patient AC21');

%Transforming csp features two different ways
features_class_1_AC21_csp_all = sum(features_class_1_AC21_csp);
features_class_2_AC21_csp_all = sum(features_class_2_AC21_csp);

features_class_1_AC21_csp_bins = zeros(size(freqs ,1), size(features_class_1_AC21_csp_all, 2), ...
    size(features_class_1_AC21_csp_all, 3));
features_class_2_AC21_csp_bins = zeros(size(freqs ,1), size(features_class_2_AC21_csp_all, 2), ...
    size(features_class_2_AC21_csp_all, 3));
for bin = 1 : size(freqs, 1)
    features_class_1_AC21_csp_bins(bin, :, :) = mean(...
        features_class_1_AC21_csp(freqs(bin, 1) : features_class_1_AC21_csp(bin, 2), :, :), 1);
    features_class_2_AC21_csp_bins(bin, :, :) = mean(...
        features_class_2_AC21_csp(freqs(bin, 1) : features_class_2_AC21_csp(bin, 2), :, :), 1);
end

%Calculating features for method 1 (my "interesting" idea)
[features_class_1_AC21_m1, features_class_2_AC21_m1] = get_features_significantPoints(data_AC21_mrcp, ...
    triggers_AC21, [60 61], trials_AC21, window_mrcp, fs, p_val,channels, ...
    'Significance window sanity check Robert Method, Patient AC 21');
%Calculating features for method 2 (Valeria's Method)
[features_class_1_AC21_m2, features_class_2_AC21_m2] = get_features_significanceWindow(data_AC21_mrcp, ...
    triggers_AC21, [60 61], trials_AC21, window_mrcp, fs, p_val, downsample_fac, channels, ...
    'Significance window sanity check Valerias Method, Patient AC 21');
%Calculating features for method 3 (As in paper Method)
[features_class_1_AC21_paper, features_class_2_AC21_paper, ~] = get_features_paper(data_AC21_mrcp, ...
    triggers_AC21, [60 61], trials_AC21, window_mrcp, fs, downsample_fac, channels, ...
    'Significance window sanity check Paper Method, Patient AC 21');

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

save('..\Data\Results Patient AC21', 'acc_AC21_freq_paper', 'acc_AC21_freq_csp_all', ...
    'acc_AC21_freq_csp_bins', 'acc_AC21_time_paper', ...
    'acc_AC21_time_robert', 'acc_AC21_time_valeria');

save('..\Data\Features Patient AC21', 'features_class_1_AC21_avrfreq', ...
    'features_class_2_AC21_avrfreq', ...
    'features_class_1_AC21_csp_all', 'features_class_1_AC21_csp_all', ...
    'features_class_1_AC21_csp_bins', 'features_class_1_AC21_csp_bins', ...
    'features_class_1_AC21_m1', 'features_class_2_AC21_m1', ...
    'features_class_1_AC21_m2', 'features_class_2_AC21_m2', ...
    'features_class_1_AC21_paper', 'features_class_2_AC21_paper');
%%}
%%
%Patient AC22
%%{
%%Calculating features
%Calculating frequency domain features according to paper
[features_class_1_AC22_avrfreq, features_class_2_AC22_avrfreq] = calc_freq_features(data_AC22_erds, ...
    triggers_AC22, [60 61], trials_AC22, window_erds, fs, freqs);
%Calculate frequency features with CSP
[features_class_1_AC22_csp, features_class_2_AC22_csp, ~] = analyse_csp_features(data_AC22_erds, ...
    triggers_AC22, [60 61], trials_AC22, window_erds, fs, 10, ...
    5, 'Accuracy plot CSP filtered data Patient AC22');

%Transforming csp features two different ways
features_class_1_AC22_csp_all = sum(features_class_1_AC22_csp);
features_class_2_AC22_csp_all = sum(features_class_2_AC22_csp);

features_class_1_AC22_csp_bins = zeros(size(freqs ,1), size(features_class_1_AC22_csp_all, 2), ...
    size(features_class_1_AC22_csp_all, 3));
features_class_2_AC22_csp_bins = zeros(size(freqs ,1), size(features_class_2_AC22_csp_all, 2), ...
    size(features_class_2_AC22_csp_all, 3));
for bin = 1 : size(freqs , 1)
    features_class_1_AC22_csp_bins(bin, :, :) = mean(...
        features_class_1_AC22_csp(freqs(bin, 1) : features_class_1_AC22_csp(bin, 2), :, :), 1);
    features_class_2_AC22_csp_bins(bin, :, :) = mean(...
        features_class_2_AC22_csp(freqs(bin, 1) : features_class_2_AC22_csp(bin, 2), :, :), 1);
end

%Calculating features for method 1 (my "interesting" idea)
[features_class_1_AC22_m1, features_class_2_AC22_m1] = get_features_significantPoints(data_AC22_mrcp, ...
    triggers_AC22, [60 61], trials_AC22, window_mrcp, fs, p_val,channels, ...
    'Significance window sanity check Robert Method, Patient AC 22');
%Calculating features for method 2 (Valeria's Method)
[features_class_1_AC22_m2, features_class_2_AC22_m2] = get_features_significanceWindow(data_AC22_mrcp, ...
    triggers_AC22, [60 61], trials_AC22, window_mrcp, fs, p_val, downsample_fac, channels, ...
    'Significance window sanity check Valerias Method, Patient AC 22');
%Calculating features for method 3 (As in paper Method)
[features_class_1_AC22_paper, features_class_2_AC22_paper, ~] = get_features_paper(data_AC22_mrcp, ...
    triggers_AC22, [60 61], trials_AC22, window_mrcp, fs, downsample_fac, channels, ...
    'Significance window sanity check Paper Method, Patient AC 22');

%%Classification with single-domain features
%Classification and kfolding for frequency features from paper
[acc_AC22_freq_paper] = permute_and_kfold(features_class_1_AC22_avrfreq, ...
    features_class_2_AC22_avrfreq, rep_fac, kfold_fac);
%Classification and kfolding for frequency features from CSP across all
%frequencies
[acc_AC22_freq_csp_all] = permute_and_kfold(features_class_1_AC22_csp_all, ...
    features_class_2_AC22_csp_all, rep_fac, kfold_fac);
%Classification and kfolding for frequency features from CSP across defined
%frequency bins
[acc_AC22_freq_csp_bins] = permute_and_kfold(features_class_1_AC22_csp_bins, ...
    features_class_2_AC22_csp_bins, rep_fac, kfold_fac);
%Classification and kfolding for time domain features, Method Paper
[acc_AC22_time_paper] = permute_and_kfold(features_class_1_AC22_paper, ...
    features_class_2_AC22_paper, rep_fac, kfold_fac);
%Classification and kfolding for time domain features, Method Robert
[acc_AC22_time_robert] = permute_and_kfold(features_class_1_AC22_m1, ...
    features_class_2_AC22_m1, rep_fac, kfold_fac);
%Classification and kfolding for time domain features, Method Valeria
[acc_AC22_time_valeria] = permute_and_kfold(features_class_1_AC22_m2, ...
    features_class_2_AC22_m2, rep_fac, kfold_fac);

save('..\Data\Results Patient AC22', 'acc_AC22_freq_paper', 'acc_AC22_freq_csp_all', ...
    'acc_AC22_freq_csp_bins', 'acc_AC22_time_paper', 'acc_AC22_time_robert', ...
    'acc_AC22_time_valeria');

save('..\Data\Features Patient AC22', 'features_class_1_AC22_avrfreq', ...
    'features_class_2_AC22_avrfreq', ...
    'features_class_1_AC22_csp_all', 'features_class_1_AC22_csp_all', ...
    'features_class_1_AC22_csp_bins', 'features_class_1_AC22_csp_bins', ...
    'features_class_1_AC22_m1', 'features_class_2_AC22_m1', ...
    'features_class_1_AC22_m2', 'features_class_2_AC22_m2', ...
    'features_class_1_AC22_paper', 'features_class_2_AC22_paper');
%%}
%%
%Patient AC23
%%{
%%Calculating features
%Calculating frequency domain features according to paper
[features_class_1_AC23_avrfreq, features_class_2_AC23_avrfreq] = calc_freq_features(data_AC23_erds, ...
    triggers_AC23, [60 61], trials_AC23, window_erds, fs, freqs);
%Calculating frequency domain features according to paper
[~, features_class_3_AC23_avrfreq] = calc_freq_features(data_AC23_erds, ...
    triggers_AC23, [60 62], trials_AC23, window_erds, fs, freqs);
%Classification with frequency domain features according to paper
[acc_AC23_freq_paper_class_1_2] = permute_and_kfold(features_class_1_AC23_avrfreq, ...
    features_class_2_AC23_avrfreq, rep_fac, kfold_fac);
%Classification with frequency domain features according to paper
[acc_AC23_freq_paper_class_1_3] = permute_and_kfold(features_class_1_AC23_avrfreq, ...
    features_class_3_AC23_avrfreq, rep_fac, kfold_fac);
%Classification with frequency domain features according to paper
[acc_AC23_freq_paper_class_2_3] = permute_and_kfold(features_class_2_AC23_avrfreq, ...
    features_class_3_AC23_avrfreq, rep_fac, kfold_fac);

%Calculate frequency features with CSP for 
[features_class_1_AC23_csp, features_class_2_AC23_csp] = analyse_csp_features(data_AC23_erds, ...
    triggers_AC23, [60 61], trials_AC23, window_erds, fs, 10, ...
    5, 'Accuracy plot CSP filtered data Patient AC23, classes 60 and 61');
%Transforming csp features two different ways
features_class_1_AC23_csp_all_12 = sum(features_class_1_AC23_csp);
features_class_2_AC23_csp_all_12 = sum(features_class_2_AC23_csp);
%Preallocating storage space
features_class_1_AC23_csp_bins_12 = zeros(size(freqs ,1), size(features_class_1_AC23_csp_all_12, 2), ...
    size(features_class_1_AC23_csp_all_12, 3));
features_class_2_AC23_csp_bins_12 = zeros(size(freqs ,1), size(features_class_2_AC23_csp_all_12, 2), ...
    size(features_class_2_AC23_csp_all_12, 3));
%Averaging over frequency bins
for bin = 1 : size(freqs , 1)
    features_class_1_AC23_csp_bins_12(bin, :, :) = mean(...
        features_class_1_AC23_csp(freqs(bin, 1) : features_class_1_AC23_csp(bin, 2), :, :), 1);
    features_class_2_AC23_csp_bins_12(bin, :, :) = mean(...
        features_class_2_AC23_csp(freqs(bin, 1) : features_class_2_AC23_csp(bin, 2), :, :), 1);
end
%Classification with CSP features for average across all freqencies
[acc_AC23_freq_csp_class_1_2_all] = permute_and_kfold(features_class_1_AC23_csp_all_12, ...
    features_class_2_AC23_csp_all_12, rep_fac, kfold_fac);
%Classification with CSP features for average across frequency bins
[acc_AC23_freq_csp_class_1_2_bins] = permute_and_kfold(features_class_1_AC23_csp_bins_12, ...
    features_class_2_AC23_csp_bins_12, rep_fac, kfold_fac);

%Calculate frequency features with CSP for 
[features_class_1_AC23_csp, features_class_3_AC23_csp] = analyse_csp_features(data_AC23_erds, ...
    triggers_AC23, [60 62], trials_AC23, window_erds, fs, 10, ...
    5, 'Accuracy plot CSP filtered data Patient AC23, classes 60 and 62');
%Transforming csp features two different ways
features_class_1_AC23_csp_all_13 = sum(features_class_1_AC23_csp);
features_class_3_AC23_csp_all_13 = sum(features_class_3_AC23_csp);
%Preallocating storage space
features_class_1_AC23_csp_bins_13 = zeros(size(freqs ,1), size(features_class_1_AC23_csp_all_13, 2), ...
    size(features_class_1_AC23_csp_all_13, 3));
features_class_3_AC23_csp_bins_13 = zeros(size(freqs ,1), size(features_class_3_AC23_csp_all_13, 2), ...
    size(features_class_3_AC23_csp_all_13, 3));
%Averaging over frequency bins
for bin = 1 : size(freqs , 1)
    features_class_1_AC23_csp_bins_13(bin, :, :) = mean(...
        features_class_1_AC23_csp(freqs(bin, 1) : features_class_1_AC23_csp(bin, 2), :, :), 1);
    features_class_3_AC23_csp_bins_13(bin, :, :) = mean(...
        features_class_3_AC23_csp(freqs(bin, 1) : features_class_3_AC23_csp(bin, 2), :, :), 1);
end
%Classification with CSP features for average across all freqencies
[acc_AC23_freq_csp_class_1_3_all] = permute_and_kfold(features_class_1_AC23_csp_all_13, ...
    features_class_3_AC23_csp_all_13, rep_fac, kfold_fac);
%Classification with CSP features for average across frequency bins
[acc_AC23_freq_csp_class_1_3_bins] = permute_and_kfold(features_class_1_AC23_csp_bins_13, ...
    features_class_3_AC23_csp_bins_13, rep_fac, kfold_fac);

%Calculate frequency features with CSP for 
[features_class_2_AC23_csp, features_class_3_AC23_csp] = analyse_csp_features(data_AC23_erds, ...
    triggers_AC23, [61 62], trials_AC23, window_erds, fs, 10, ...
    5, 'Accuracy plot CSP filtered data Patient AC23, classes 61 and 62');
%Transforming csp features two different ways
features_class_2_AC23_csp_all_23 = sum(features_class_2_AC23_csp);
features_class_3_AC23_csp_all_23 = sum(features_class_3_AC23_csp);
%Preallocating storage space
features_class_2_AC23_csp_bins_23 = zeros(size(freqs ,1), size(features_class_2_AC23_csp_all_23, 2), ...
    size(features_class_2_AC23_csp_all_23, 3));
features_class_3_AC23_csp_bins_23 = zeros(size(freqs ,1), size(features_class_3_AC23_csp_all_23, 2), ...
    size(features_class_3_AC23_csp_all_23, 3));
%Averaging over frequency bins
for bin = 1 : size(freqs , 1)
    features_class_2_AC23_csp_bins_23(bin, :, :) = mean(...
        features_class_2_AC23_csp(freqs(bin, 1) : features_class_2_AC23_csp(bin, 2), :, :), 1);
    features_class_3_AC23_csp_bins_23(bin, :, :) = mean(...
        features_class_3_AC23_csp(freqs(bin, 1) : features_class_3_AC23_csp(bin, 2), :, :), 1);
end
%Classification with CSP features for average across all freqencies
[acc_AC23_freq_csp_class_2_3_all] = permute_and_kfold(features_class_2_AC23_csp_all_23, ...
    features_class_3_AC23_csp_all_23, rep_fac, kfold_fac);
%Classification with CSP features for average across frequency bins
[acc_AC23_freq_csp_class_2_3_bins] = permute_and_kfold(features_class_2_AC23_csp_bins_23, ...
    features_class_3_AC23_csp_bins_23, rep_fac, kfold_fac);

%Calculating features for method 1 (my "interesting" idea)
[features_class_1_AC23_m1_12, features_class_2_AC23_m1_12] = get_features_significantPoints(data_AC23_mrcp, ...
    triggers_AC23, [60 61], trials_AC23, window_mrcp, fs, p_val,channels, ...
    'Significance window sanity check Robert Method, Patient AC 23, classes 60 and 61');
%Classification and kfolding for time domain features, Method Robert
[acc_AC23_time_robert_class_1_2] = permute_and_kfold(features_class_1_AC23_m1_12, ...
    features_class_2_AC23_m1_12, rep_fac, kfold_fac);
%Calculating features for method 1 (my "interesting" idea)
[features_class_1_AC23_m1_13, features_class_3_AC23_m1_13] = get_features_significantPoints(data_AC23_mrcp, ...
    triggers_AC23, [60 62], trials_AC23, window_mrcp, fs, p_val,channels, ...
    'Significance window sanity check Robert Method, Patient AC 23, classes 60 and 62');
%Classification and kfolding for time domain features, Method Robert
[acc_AC23_time_robert_class_1_3] = permute_and_kfold(features_class_1_AC23_m1_13, ...
    features_class_3_AC23_m1_13, rep_fac, kfold_fac);
%Calculating features for method 1 (my "interesting" idea)
[features_class_2_AC23_m1_23, features_class_3_AC23_m1_23] = get_features_significantPoints(data_AC23_mrcp, ...
    triggers_AC23, [61 62], trials_AC23, window_mrcp, fs, p_val,channels, ...
    'Significance window sanity check Robert Method, Patient AC 23, classes 61 and 62');
%Classification and kfolding for time domain features, Method Robert
[acc_AC23_time_robert_class_2_3] = permute_and_kfold(features_class_2_AC23_m1_23, ...
    features_class_3_AC23_m1_23, rep_fac, kfold_fac);

%Calculating features for method 2 (Valeria's Method)
[features_class_1_AC23_m2_12, features_class_2_AC23_m2_12] = get_features_significanceWindow(data_AC23_mrcp, ...
    triggers_AC23, [60 61], trials_AC23, window_mrcp, fs, p_val, downsample_fac, channels, ...
    'Significance window sanity check Valerias Method, Patient AC 23, classes 60 and 61');
%Classification and kfolding for time domain features, Method Valeria
[acc_AC23_time_valeria_class_1_2] = permute_and_kfold(features_class_1_AC23_m2_12, ...
    features_class_2_AC23_m2_12, rep_fac, kfold_fac);
%Calculating features for method 2 (Valeria's Method)
[features_class_1_AC23_m2_13, features_class_3_AC23_m2_13] = get_features_significanceWindow(data_AC23_mrcp, ...
    triggers_AC23, [60 62], trials_AC23, window_mrcp, fs, p_val, downsample_fac, channels, ...
    'Significance window sanity check Valerias Method, Patient AC 23, classes 60 and 62');
%Classification and kfolding for time domain features, Method Valeria
[acc_AC23_time_valeria_class_1_3] = permute_and_kfold(features_class_1_AC23_m2_13, ...
    features_class_3_AC23_m2_13, rep_fac, kfold_fac);
%Calculating features for method 2 (Valeria's Method)
[features_class_2_AC23_m2_23, features_class_3_AC23_m2_23] = get_features_significanceWindow(data_AC23_mrcp, ...
    triggers_AC23, [61 62], trials_AC23, window_mrcp, fs, p_val, downsample_fac, channels, ...
    'Significance window sanity check Valerias Method, Patient AC 23, classes 62 and 62');
%Classification and kfolding for time domain features, Method Valeria
[acc_AC23_time_valeria_class_2_3] = permute_and_kfold(features_class_2_AC23_m2_23, ...
    features_class_3_AC23_m2_23, rep_fac, kfold_fac);

%Calculating features for method 3 (As in paper Method)
[features_class_1_AC23_paper_12, features_class_2_AC23_paper_12, ~] = get_features_paper(data_AC23_mrcp, ...
    triggers_AC23, [60 61], trials_AC23, window_mrcp, fs, downsample_fac, channels, ...
    'Significance window sanity check Paper Method, Patient AC 23, classes 60 and 61');
%Classification and kfolding for frequency features from paper
[acc_AC23_time_paper_class_1_2] = permute_and_kfold(features_class_1_AC23_paper_12, ...
    features_class_2_AC23_paper_12, rep_fac, kfold_fac);
%Calculating features for method 3 (As in paper Method)
[features_class_1_AC23_paper_13, features_class_3_AC23_paper_13, ~] = get_features_paper(data_AC23_mrcp, ...
    triggers_AC23, [60 62], trials_AC23, window_mrcp, fs, downsample_fac, channels, ...
    'Significance window sanity check Paper Method, Patient AC 23, classes 60 and 62');
%Classification and kfolding for frequency features from paper
[acc_AC23_time_paper_class_1_3] = permute_and_kfold(features_class_1_AC23_paper_13, ...
    features_class_3_AC23_paper_13, rep_fac, kfold_fac);
%Calculating features for method 3 (As in paper Method)
[features_class_2_AC23_paper_23, features_class_3_AC23_paper_23, ~] = get_features_paper(data_AC23_mrcp, ...
    triggers_AC23, [61 62], trials_AC23, window_mrcp, fs, downsample_fac, channels, ...
    'Significance window sanity check Paper Method, Patient AC 23, classes 61 and 62');
%Classification and kfolding for frequency features from paper
[acc_AC23_time_paper_class_2_3] = permute_and_kfold(features_class_2_AC23_paper_23, ...
    features_class_3_AC23_paper_23, rep_fac, kfold_fac);

save('..\Data\Results Patient AC23', ...
    'acc_AC23_freq_paper_class_1_2', 'acc_AC23_freq_paper_class_1_3', 'acc_AC23_freq_paper_class_2_3', ...
    'acc_AC23_freq_csp_class_1_2_bins', 'acc_AC23_freq_csp_class_1_3_bins', 'acc_AC23_freq_csp_class_2_3_bins', ...
    'acc_AC23_freq_csp_class_1_2_all', 'acc_AC23_freq_csp_class_1_3_all', 'acc_AC23_freq_csp_class_2_3_all', ...
    'acc_AC23_time_paper_class_1_2', 'acc_AC23_time_paper_class_1_3', 'acc_AC23_time_paper_class_2_3', ...
    'acc_AC23_time_robert_class_1_2', 'acc_AC23_time_robert_class_1_3', 'acc_AC23_time_robert_class_2_3', ...
    'acc_AC23_time_valeria_class_1_2', 'acc_AC23_time_valeria_class_1_3', 'acc_AC23_time_valeria_class_2_3');

save('..\Data\Features Patient AC23', 'features_class_1_AC23_avrfreq', ...
    'features_class_2_AC23_avrfreq', 'features_class_3_AC23_avrfreq', ...
    'features_class_1_AC23_csp_bins_12', 'features_class_2_AC23_csp_bins_12', ...
    'features_class_1_AC23_csp_bins_13', 'features_class_3_AC23_csp_bins_13', ...
    'features_class_2_AC23_csp_bins_23', 'features_class_3_AC23_csp_bins_23', ...
    'features_class_1_AC23_m1_12', 'features_class_2_AC23_m1_12', ...
    'features_class_1_AC23_m1_13', 'features_class_3_AC23_m1_13', ...
    'features_class_2_AC23_m1_23', 'features_class_3_AC23_m1_23', ...
    'features_class_1_AC23_m2_12', 'features_class_2_AC23_m2_12', ...
    'features_class_1_AC23_m2_13', 'features_class_3_AC23_m2_13', ...
    'features_class_2_AC23_m2_23', 'features_class_3_AC23_m2_23', ...
    'features_class_1_AC23_paper_12', 'features_class_2_AC23_paper_12', ...
    'features_class_1_AC23_paper_13', 'features_class_3_AC23_paper_13', ...
    'features_class_2_AC23_paper_23', 'features_class_3_AC23_paper_23');
%%}