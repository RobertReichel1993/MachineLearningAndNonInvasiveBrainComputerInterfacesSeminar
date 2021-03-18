%This file plots all the plots needed for a basic analysis of the given EEG
%data in the time and frequency domain, containing ERDS maps, Topoplots,
%MRCP plots and the pandpower.
%
%Input:
%   data .......... The given data with the dimensions:
%                   [# of datapoints] x [# of channels]
%   triggers ...... The starting indices of all trials in the experiment
%   events ........ An array indicating the corrseponding class for each
%                   trial indicated by triggers
%   window_mrcp ... The time window in which the MRCP is theorized to
%                   happen
%   window_erds ... The time window in which the ERDS is theorized to
%                   happen
%   ref_window .... The time window for the reference period of the ERDS
%                   maps
%   channels ...... The names of the EEG channels given in a struct of
%                   strings
%   eloc .......... The location of the EEG electrodes as read from the
%                   eeglab function "readlocs"
%   fs ............ The used sampling frequency
%   patient ....... The name of the current patient
%
%Output:
%   data ... The data used in the analysis, usually not really needed
%
%Dependencies: eeglab (from the supporting code package, not the whole
%                       eeglab package)

function [data] = plot_Analysis(data, triggers, events, window_mrcp, ...
    window_erds, ref_window, channels, eloc, fs, patient)
    %Patient AC23
    %Creating structure for data info
    erds_info.Classlabel = events;
    erds_info.TRIG = triggers;
    erds_info.SampleRate = fs;
    f_borders = [4, 30];
    %Calculating and plotting ERDS-Maps for all classes (can we do it for three classes??)
    plotErdsMap(calcErdsMap([data(:, 7) data(:, 11) data(:, 9)], ...
        erds_info, window_erds, f_borders, 'ref', ref_window, 'sig', ...
        'boot', 'alpha', 0.05, 'class', [60 61 62], 'montage', [1 1 1]), ....
        fullfile('../Plots/', ...
        strcat('ERDS map for patient ', patient, ', Time of cue')), 1);
    %Calculating bandpower and vizualising it
    plot_Bandpower(data, triggers, [60 61], events, ...
        channels, window_mrcp, fs, ...
        strcat('Bandpower for patient ', patient, ', Time of cue'));
    %Calculating and plotting MRCP
    plot_MRCP(data, triggers, [60 61], events, ...
        channels, window_mrcp, fs, ...
        strcat('MRCP for patient ', patient, ', Time of cue'));
    %Plotting topoplot
    plot_Topoplots(data, triggers, eloc, fs, ...
        strcat('Topoplot for patient ', patient, ', Time of cue'));
    %Plotting trials over time
    plotTrialsOverTime(data, triggers, channels, window_mrcp, fs, ...
        strcat('Trials over time for patient ', patient, ', Time of cue'));
end