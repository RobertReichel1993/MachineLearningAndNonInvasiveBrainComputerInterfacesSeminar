function [ArtifactTrials,ArtifactChannelMatrix] = select_artifacts(SignalHeader,EventHeader)
% select_artifacts aims to give the same results as the previously used
% setup with .evt and .sel files.
% Now, you can save artifact events directly to the .gdf file in SigViewer
% and this function returns a list similar to h.ArtifactSelection from
% previous .gdf versions implemented in BioSig Toolbox.
%
% Input:    EventHeader... e, as returned from [s,h,e] = gdf_reader(...)
%           EventHeader... h, as returned from [s,h,e] = gdf_reader(...)
%
% Output:   ArtifactTrials... a vector with 0 and 1 for artifact on/off
%           ArtifactChannelMatrix... Channel specific information

e = EventHeader;
h = SignalHeader;

% Just to make sure the events are really sorted...
EventMatrix = sortrows([e.position' e.event_code' e.channel' e.duration']);

TrialOnsets = EventMatrix(EventMatrix(:,2)==768,1);
TrialOffsets = EventMatrix(EventMatrix(:,2)==768,1) + EventMatrix(EventMatrix(:,2)==768,4);
TrialOnOff = [TrialOnsets,TrialOffsets];

ArtifactTrials = zeros(size(TrialOnsets,1),1);

% Only keep information about corrupted trials:
EventMatrix_red = EventMatrix;
EventMatrix_red(EventMatrix_red(:,2)<257 | EventMatrix_red(:,2)>266,:) = [];

% Span Artifact/Channel Matrix:
AffectedChannels = 1:size(h.signals,1);

ArtifactMatrix = zeros(max(AffectedChannels), max([h.signals.samples_per_record])*double(h.file.num_datarecords));
ArtifactChannelMatrix = zeros(size(ArtifactMatrix,1),size(TrialOnsets,1));

for ch = 1:max(AffectedChannels)
    ArtifactMatrix(ch,EventMatrix_red(EventMatrix_red(:,3)==ch | EventMatrix_red(:,3)==0,1)) = 1;
    ArtifactMatrix(ch,EventMatrix_red(EventMatrix_red(:,3)==ch | EventMatrix_red(:,3)==0,1)...
        + EventMatrix_red(EventMatrix_red(:,3)==ch | EventMatrix_red(:,3)==0,4)) = -1;
    ArtifactMatrix(ch,:) = cumsum(ArtifactMatrix(ch,:));
    
    for l = 1:length(TrialOnsets)
        if sum(ArtifactMatrix(ch,TrialOnOff(l,1):TrialOnOff(l,2))) > 0
            ArtifactTrials(l) = 1;
            ArtifactChannelMatrix(ch,l) = 1;
        end
    end
    
    % If all artifacts are on all channels we need not bother going through
    % all of them:
    if sum(EventMatrix_red(:,3)) == 0
        ArtifactChannelMatrix = repmat(ArtifactChannelMatrix(ch,:),18,1);
        break;
    end
    
end
ArtifactChannelMatrix = ArtifactChannelMatrix';

