clearvars, close all, clc

%% Load training data
[SIGNALS, ~, EVENTS] = gdf_multiread('..\Data\rec\20191021_154659_AC21_mcs_patientShortIntro_3sMove_1.gdf');

Classlabels = ["Foot", "Hand"];
events = [60, 61]; %60=foot 61=hand

% Data preprocessing
hGes.SampleRate = EVENTS.sample_rate;
hGes.SampleRate = double(hGes.SampleRate);
hGes.Classlabel = EVENTS.event_code(EVENTS.event_code==events(1)|EVENTS.event_code==events(2));
hGes.Classlabel(hGes.Classlabel==events(1)) = events(1);
hGes.Classlabel(hGes.Classlabel==events(2)) = events(2);
hGes.Classlabel = double(hGes.Classlabel);
hGes.TRIG = double(EVENTS.position(EVENTS.event_code==events(1)|EVENTS.event_code==events(2)));

for kchans = size(SIGNALS,1)
    sGes(:,kchans) = SIGNALS{kchans,1};
end