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

%Just for completenes sake
channels = {'FC3','FC1','FCz','FC2','FC4','C5','C3','C1','Cz',...
    'C2','C4','C6','CP1','CPz','CP2','Pz'};

%Defining cues
attention = 768; %Starting each run, ending previous imagination period
reference = 785; %Now the reference interval starts
start = 789; %Start the movement now
ending = 792; %End of the whole experiment run
hand = 61; %Instruction on what to do after start signal
foot = 60; %Instruction on what to do after start signal
poss_trig = [60 61];

%Defining timings
%From other code
window_mrcp = [-2 4];
window_erds = [-5 0 4];

ref_window_AC23 = [-4.5 -3.7]; % if no movement class is implemented
ref_window_pat = [-4.5 -3.6]; % if only hand & feet class
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
%Finding events and triggers (the trial start ones, e.g. 60, 61 and 62)
triggers_AC21 = events_AC21.position(ismember(events_AC21.event_code, ...
    poss_trig));
triggers_AC22 = events_AC22.position(ismember(events_AC22.event_code, ...
    poss_trig));
triggers_AC23 = events_AC23.position(ismember(events_AC23.event_code, ...
    poss_trig));

trials_AC21 = double(events_AC21.event_code(ismember(events_AC21.event_code, ...
    poss_trig)));
trials_AC22 = double(events_AC22.event_code(ismember(events_AC22.event_code, ...
    poss_trig)));
trials_AC23 = double(events_AC23.event_code(ismember(events_AC23.event_code, ...
    poss_trig)));

%Shifting events and triggers by delay
triggers_AC21 = double(triggers_AC21) + double(round(3.6 * fs));
triggers_AC22 = double(triggers_AC22) + double(round(3.6 * fs));
triggers_AC23 = double(triggers_AC23) + double(round(3.7 * fs));
%%
%Artifact rejection for all experiments
[IdcsOfTaintedTrials, ~] = PerformOutlierRejection(window_mrcp(1) * fs, ...
    window_mrcp(2) * fs - 1, data_AC21_erds, triggers_AC21, fs);
%Now cutting out all bad trials
triggers_AC21(IdcsOfTaintedTrials) = [];
trials_AC21(IdcsOfTaintedTrials)  = [];

[IdcsOfTaintedTrials, ~] = PerformOutlierRejection(window_mrcp(1) * fs, ...
    window_mrcp(2) * fs - 1, data_AC22_erds, triggers_AC22, fs);
%Now cutting out all bad trials
triggers_AC22(IdcsOfTaintedTrials) = [];
trials_AC22(IdcsOfTaintedTrials)  = [];

[IdcsOfTaintedTrials, ~] = PerformOutlierRejection(window_mrcp(1) * fs, ...
    window_mrcp(2) * fs - 1, data_AC23_erds, triggers_AC23, fs);
%Now cutting out all bad trials
triggers_AC23(IdcsOfTaintedTrials) = [];
trials_AC23(IdcsOfTaintedTrials)  = [];

%Defining p_value
p_val = 0.50;
%%
%Patient AC21
[features_class_1_AC21_m1, features_class_2_AC21_m1] = get_features_method1(data_AC21_mrcp, ...
    triggers_AC21, [60 61], trials_AC21, window_mrcp, fs, p_val);

[features_class_1_AC21_m2, features_class_2_AC21_m2] = get_features_method2(data_AC21_mrcp, ...
    triggers_AC21, [60 61], trials_AC21, window_mrcp, fs, p_val, 16);
%%
%Patient AC22
[features_class_1_AC22_m1, features_class_2_AC22_m1] = get_features_method1(data_AC22_mrcp, ...
    triggers_AC22, [60 61], trials_AC22, window_mrcp, fs, p_val);

[features_class_1_AC22_m2, features_class_2_AC22_m2] = get_features_method2(data_AC22_mrcp, ...
    triggers_AC22, [60 61], trials_AC22, window_mrcp, fs, p_val, 16);
%%
%Patient AC23
[features_class_1_AC23_m1, features_class_2_AC23_m1] = get_features_method1(data_AC23_mrcp, ...
    triggers_AC23, [60 61], trials_AC23, window_mrcp, fs, p_val);

[features_class_1_AC23_m2, features_class_2_AC23_m2] = get_features_method2(data_AC23_mrcp, ...
    triggers_AC23, [60 61], trials_AC23, window_mrcp, fs, p_val, 16);

