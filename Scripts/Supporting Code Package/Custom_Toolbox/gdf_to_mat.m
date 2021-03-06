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


function [data] = gdf_to_mat(path, filename)
    path_all = strcat(path, filename);
    
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','AC21_1','gui','off'); 
    [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = pop_biosig(path_all);
    %EEG.data -> data from channels
    %EEG.times -> timepoints
    %EEG.srate -> sample rate
    %EEG.nbchan -> number of channels with names, locations, etc.
    %EEG.chanlocs -> Channel locations
    %EEG.event -> events (60, 61) for hand and foot and add. info

    if ~isa(EEG.data, 'double')
        data.eeg = double(EEG.data);
    else
        data.eeg = EEG.data;
    end
    data.time = EEG.times;
    data.fs = EEG.srate;
    data.chaninfo = EEG.nbchan;
    data.chanlocs = EEG.chanlocs;
    data.events = EEG.event;
    data.urevent = EEG.urevent;
    
    tmp = strsplit(filename, '.');
    tmp = strcat(tmp(1), '.mat');
    save(strcat('..\Data\rec.mat\', char(tmp)), 'data');
end