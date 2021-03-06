Statistical Outlier rejection. The Function autmatically segments your trials according to the triggers (e.g. cue timings) you hand to it.

% the data window defines your trial length with respect to the trigger (cue)
data window = [-3 5];
% the sampling frequency of your data 
fs = 128;
% aCurTriggers is an array with your cues
% aCurClasslabels is an array which holds the classlabel (e.g both feet, right hand) to your cues.

% Basic Function call:
[IdcsOfTaintedTrials, ~] = PerformOutlierRejection(data_window(1)*fs, data_window(2)*fs, YourEEGSignal, YourCues, SamplingRate);



%You can also derivate form the default threshold parameters, as given in the example here:


%% Outlier Rejection
% Parameters that can be adapted

%   default parameters
%   Bandpass Filter Width (Hz)     : FILTER_BAND = [3 35];
%   Bandpass Filter Order          : FILTER_ORDER = 4;
%   Channel Probalility Threshold  : CH_PROB_TH = 5;
%   Channel Kurtosis  Threshold    : CH_KURT_TH = 8;
%   Epoch Amplitude   Threshold Min: EP_AMP_TH_MIN = -100;
%   Epoch Amplitude   Threshold Max: EP_AMP_TH_MAX = +100;
%   Epoch Probability Threshold    : EP_PROB_TH = 4;
%   Epoch Kurtosus    Threshold    : EP_KURT_TH = 4;
%   Channel Varicance Threshold    : CH_VAR_FACT = 5;



%The function returns the Idcs of tainted trials given previously in the aCurTriggers vector [e.g. [ 1 5 18 43], which means that the trials with the triggers [ 1 5 18 43] are tainted and should be excluded like this:

aCurTriggers(aAllSigOutIdx) = [];
aCurClasslabels(aAllSigOutIdx)  = [];
