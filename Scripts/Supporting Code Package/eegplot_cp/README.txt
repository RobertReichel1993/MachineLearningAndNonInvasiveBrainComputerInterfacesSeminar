How to use:

marker =  zeros(size(signal, 1), 1);
marker(YourTriggertodisplay) =  YourClasslabeltodisplay;

eegplot_cp(signal, 125 , fs, 10,labels, marker) 

%% EEG plot function

% Input:

%- signal (channels x time)
%- channel width (e.g. 125),
%- sample frequency, 
%- displaylength in seconds (e.g. 10),
%- channel labels (cell with strings e.g {'C3', 'Cz','C4'}, 
%- markers (like triggers) - vector of zeros the same length as signal,
%  with values at the designated trigger points
