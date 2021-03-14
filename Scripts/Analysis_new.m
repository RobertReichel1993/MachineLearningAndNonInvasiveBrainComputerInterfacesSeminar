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
poss_trig = [60 61];
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
%Patient AC21
plot_Analysis(data_AC21_erds, triggers_AC21, trials_AC21, window_mrcp, ...
    window_erds, ref_window, channels, eloc, fs, 'AC21');
%Patient AC22
plot_Analysis(data_AC22_erds, triggers_AC22, trials_AC22, window_mrcp, ...
    window_erds, ref_window, channels, eloc, fs, 'AC22');
%Patient AC23
plot_Analysis(data_AC23_erds, triggers_AC23, trials_AC23, window_mrcp, ...
    window_erds, ref_window_AC23, channels, eloc, fs, 'AC23');
%%
% Calculation of features in Time Domain
%Downsampling
d_fac = 16;
fs = fs / d_fac;
data_AC21_erds = downsample(data_AC21_erds, d_fac);
triggers_AC21 = round(triggers_AC21 ./ d_fac);
data_AC22_erds = downsample(data_AC22_erds, d_fac);
triggers_AC22 = round(triggers_AC22 ./ d_fac);
data_AC23_erds = downsample(data_AC23_erds, d_fac);
triggers_AC23 = round(triggers_AC23 ./ d_fac);
%Defining p_value
p_val = 0.50;
%Patient AC21
[p_vals_AC21, sig_mask_AC21] = calc_p_values(data_AC21_mrcp, ...
    triggers_AC21, [60 61], trials_AC21, window_mrcp, fs, p_val);
%Patient AC22
[p_vals_AC22, sig_mask_AC22] = calc_p_values(data_AC22_mrcp, ...
    triggers_AC22, [60 61], trials_AC22, window_mrcp, fs, p_val);
%Patient AC23
[p_vals_AC23, sig_mask_AC23] = calc_p_values(data_AC23_mrcp, ...
    triggers_AC23, [60 61], trials_AC23, window_mrcp, fs, p_val);
%For patient AC21 and AC23, no significant difference up to p = 0.5!
any(any(sig_mask_AC21, 1))
%At p = 0.19, there is a difference with this patient
any(any(sig_mask_AC22, 1))
any(any(sig_mask_AC23, 1))