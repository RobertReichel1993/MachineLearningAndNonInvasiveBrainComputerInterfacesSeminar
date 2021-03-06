% CSP demo script to example the use of csp_train and csp_filter with real
% eeg data

% clear all variables
clear all;

% paths
addpath('gdf_reader');

% read data
[Sig, Hea, Eve, ~] = gdf_multiread('data\*.gdf','DATAFORMAT','MATRIX',...
    'DATAORIENTATION','ROW');

% insert zeros instead of NaNs
Sig(isnan(Sig)) = 0;

Sig = resample(Sig',1,8);

% Sample rate
SR = 64;

% define a butterworth band pass filter (7 to 30 Hz)
[b,a] = butter(4,[7 30]/(SR/2));

% Filter the signal
Sig = filter(b,a,Sig);

% class's positions hand
ClassPosH = Eve.position(Eve.event_code==770)/8;

% class's positions feet
ClassPosF = Eve.position(Eve.event_code==771)/8;

% Divide signal into the two classes
data_class1 = [];
data_class2 = [];
% for cTrial = 1:length(ClassPosH)
%     data_class1 = [data_class1; Sig(int64(ClassPosH(cTrial)+1.5*SR):int64(ClassPosH(cTrial)+1.5*SR+3*SR),:)];
% end
for cTrial = 1:length(ClassPosH)
    data_class1(:,:,cTrial) = Sig(int64(ClassPosH(cTrial)+1.5*SR):int64(ClassPosH(cTrial)+1.5*SR+3*SR),:);
end
% for cTrial = 1:length(ClassPosF)
%     data_class2 = [data_class2; Sig(int64(ClassPosF(cTrial)+1.5*SR):int64(ClassPosF(cTrial)+1.5*SR+3*SR),:)];
% end
for cTrial = 1:length(ClassPosF)
    data_class2(:,:,cTrial) = Sig(int64(ClassPosF(cTrial)+1.5*SR):int64(ClassPosF(cTrial)+1.5*SR+3*SR),:);
end

% Train the CSP model
tic
model_csp_shrink = csp_train(data_class1,data_class2,'standard');
toc

% Select the CSP filter
filter_selection = logical([ones(1,3),zeros(1,9),ones(1,3)]);

% Filter the data with the CSP
Sig_csp = csp_filter(model_csp_shrink,filter_selection,Sig);

% Calculate power of CSP filtered signals
Sig_csp_power = (Sig_csp.^2);

% Moving average
a = 1;
b = 1/2*SR*ones(1,2*SR);
Sig_csp_power_filt = filter(b,a,Sig_csp_power);

% Plot figures
figure();
plot(Sig_csp_power_filt);