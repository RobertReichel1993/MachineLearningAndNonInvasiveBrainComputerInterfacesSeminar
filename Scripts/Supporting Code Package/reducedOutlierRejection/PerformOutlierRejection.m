function [aAllSigOutIdx, aOutCHIdc] = PerformOutlierRejection ( START_ART_CHECK_SAMPLE, END_ART_CHECK_SAMPLE, aSigRaw, aCurTriggers,  fs , varargin)

% aSigRaw, aCurTriggers, fs, START_ART_CHECK_SAMPLE, END_ART_CHECK_SAMPLE, varargin 



%% Default Outlier Parameter Do not change, change in function call with varargin
  FILTER_BAND = [3 35];
  FILTER_ORDER = 4;
  CH_PROB_TH = 5;
  CH_KURT_TH = 8;
  EP_AMP_TH_MIN = -100;
  EP_AMP_TH_MAX = +100;
  EP_PROB_TH = 4;
  EP_KURT_TH = 4;
  CH_VAR_FACT = 5;
  
  

  aAllIndices = (1:length(aCurTriggers));
  aAllCHIndices = (1:size(aSigRaw,2));
  aOutCHIdc = [];
  aOutEpochIdc = [];

  
  %% Assign variable parameter list arguments 
  
  VARARGIN_VARIABLES = { 'FILTER_BAND', 'FILTER_ORDER', 'EP_AMP_TH_MIN', 'EP_AMP_TH_MAX','CH_PROB_TH','CH_KURT_TH','EP_PROB_TH','EP_KURT_TH','CH_VAR_FACT'  };
  
  ASSIGN_VARARGIN_FIELDS_TO_VARIABLES

  
  
  
  
  
  
  
  %% (1) Filter signal prior to outlier rejection
  h  = fdesign.bandpass('N,F3dB1,F3dB2',FILTER_ORDER, FILTER_BAND(1), FILTER_BAND(2), fs);
  Hd = design(h, 'IIR', 'SOSScaleNorm','linf');
  
  % Apply filter to channels
  aSigBPass = filter(Hd,aSigRaw);
  % For Filter Check 
  % pwelch(aSigBPass,fs,1,fs,fs); fvtool(Hd)
  
  
  % Epoch data to trials
  [X, sz] = trigg ( aSigBPass, aCurTriggers, START_ART_CHECK_SAMPLE, END_ART_CHECK_SAMPLE, 0 );

  aSigBPassEpoched = reshape ( X, sz );
  
   fprintf ( '\n## (1) BP filtering before trial rejection: %s', mat2str(FILTER_BAND) );
  
  % PlotSignal ( squeeze ( aSigBPassEpoched ( :, :, 4 )' ) )
  
  %% (2) Trial rejection by threshold
  [aTH_EpochRej] = or_threshold ( aSigBPassEpoched, EP_AMP_TH_MIN, EP_AMP_TH_MAX );
  
  aSigBPassEpoched (:,:,aTH_EpochRej) = [];

  aOutEpochIdc = [aOutEpochIdc aAllIndices(aTH_EpochRej)];
  
  fprintf ( '\n## (2) Epochs rejected by threshold: (%d) => %s', length(aAllIndices(aTH_EpochRej)), mat2str(aAllIndices(aTH_EpochRej)) );
  
  aAllIndices(aTH_EpochRej) = [];

  
  %% (3) Initial channel rejection by variance
  [aVA_CHRej, aMeanChannelVars, aGrandMedVar, aGrandSTDVar] = RejectChannelsByVariance ( aSigBPassEpoched, CH_VAR_FACT );
 
   fprintf ( '\n## (3) Channels rejected by variance: Var [%2.1f] Std [%2.1f], %s, %s', aGrandMedVar, aGrandSTDVar, mat2str(fix(aMeanChannelVars(aVA_CHRej))'), mat2str(find(aVA_CHRej)') );
  
  aOutCHIdc = aAllCHIndices ( aVA_CHRej );
  
  % Manual Override, FJ, 2012-02-26, DO NOT REMOVE CHANNELS HERE!
  % aAllCHIndices ( aVA_CHRej ) = [];
  
  % aSigBPassEpochedCHSel = aSigBPassEpoched ( ~ ( aVA_CHRej ), :, : );
  
  % MANUAL OVERRIDE!! USE ALL CHANNELS FOR EPOCH REJECTION
  aSigBPassEpochedCHSel = aSigBPassEpoched;

  %% (4) Trial rejection by probability 
  [tmp, aJP_EpochRejMat] = jointprob ( aSigBPassEpochedCHSel, EP_PROB_TH, [], 1 ); 

  aJP_EpochRej = find ( sum ( aJP_EpochRejMat, 1 ) > 0 ); % aKU_EpochRejMat is a logical matrix (0s and 1s)! that's why we need the sum

  aSigBPassEpochedCHSel (:,:,aJP_EpochRej) = [];
    
  aOutEpochIdc = [aOutEpochIdc aAllIndices(aJP_EpochRej)];
  
   fprintf ( '\n## (4) Epochs rejected by probability: (%d) => %s', length(aAllIndices(aJP_EpochRej)), mat2str(aAllIndices(aJP_EpochRej)) );

  aAllIndices(aJP_EpochRej) = [];

  %% (5) Trial rejection by kurtosis 
  [tmp, aKU_EpochRejMat] = rejkurt ( aSigBPassEpochedCHSel, EP_KURT_TH, [], 1 ); 

  aKU_EpochRej = find ( sum ( aKU_EpochRejMat, 1 ) > 0 ); % aKU_EpochRejMat is a logical matrix (0s and 1s)! that's why we need the sum

  aSigBPassEpochedCHSel (:,:,aKU_EpochRej) = [];
  
  aOutEpochIdc = [aOutEpochIdc aAllIndices(aKU_EpochRej)];
  
   fprintf ( '\n## (5) Epochs rejected by kurtosis: (%d) => %s', length(aAllIndices(aKU_EpochRej)), mat2str(aAllIndices(aKU_EpochRej)) );

  aAllIndices(aKU_EpochRej) = [];
  
  %% (6) Channel rejection by probability (raw) % raw WHAT?
  [aJPMeasure, aJP_CHRej] = jointprob ( reshape ( aSigBPassEpochedCHSel, size ( aSigBPassEpochedCHSel, 1 ), size(aSigBPassEpochedCHSel,2)*size(aSigBPassEpochedCHSel,3)), CH_PROB_TH, [], 2 );

   fprintf ( '\n## (6) Channels rejected by probability => %s', mat2str(aAllCHIndices(find(aJP_CHRej))) );
  
  %% (7) Channel rejection by kurtosis (raw)
  [aKUMeasure, aKU_CHRej] = rejkurt ( reshape ( aSigBPassEpochedCHSel, size ( aSigBPassEpochedCHSel, 1 ), size(aSigBPassEpochedCHSel,2)*size(aSigBPassEpochedCHSel,3)), CH_KURT_TH, [], 2 );

   fprintf ( '\n## (7) Channels that would be rejected by kurtosis => %s\n\n', mat2str(aAllCHIndices(aKU_CHRej)) );
  
  %% Aggregate all channel rejection information
  aOutCHIdc = [aOutCHIdc aAllCHIndices(aJP_CHRej|aKU_CHRej)];
  
  aAllCHIndices ( aJP_CHRej | aKU_CHRej ) = [];
  
  aOutCHIdc = unique(aOutCHIdc);
  aAllSigOutIdx = [aOutEpochIdc];
  
  
  
  
  
  