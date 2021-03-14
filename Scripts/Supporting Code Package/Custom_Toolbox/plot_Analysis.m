%This function reads in a gdf file and saves it as an .mat file and returns
%the data itself and, if the data is single precission, it automatically is
%converted into double precission values
%
%Input:
%   filename ... The name of the input file
%   path ....... The path to the gdf files
%
%Output:
%   data ... A struct containing all information from the gdf file
%
%Dependencies: eeglab toolbox
%
%Remarks:
%EEG.data -> data from channels
%EEG.times -> timepoints
%EEG.srate -> sample rate
%EEG.nbchan -> number of channels with names, locations, etc.
%EEG.chanlocs -> Channel locations
%EEG.event -> events (60, 61) for hand and foot and add. info


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