function [sorted_events] = sort_events(EventHeader)
% function sort_events sorts all entries in the event header (derived from
% [s,h,e] = gdf_reader(). 
% Further, it changes the event mode to event mode 3.

e = EventHeader;

if e.mode == 3    
    EventMatrix = sortrows([e.position' e.event_code' e.channel' e.duration']);
    e.position = EventMatrix(:,1)';
    e.event_code = EventMatrix(:,2)';
    e.channel = EventMatrix(:,3)';
    e.duration = EventMatrix(:,4)';
elseif e.mode == 1
    EventMatrix = zeros(length(e.position),4);
    EventMatrix(:,1:2) = sortrows([e.position' e.event_code']);
    EventOnsets = unique(e.event_code(e.event_code < hex2dec('8000')));
    for ev = EventOnsets
        Onsets = EventMatrix(EventMatrix(:,2) == ev,1);
        Offsets = EventMatrix(EventMatrix(:,2) == bitor(ev,hex2dec('8000')),1);
        if length(Onsets) ~= length(Offsets) && ~isempty(Offsets)
            error(' ONSETS MISSING OFFSETS ')
        elseif isempty(Offsets)
            Durations = zeros(length(Onsets),1);
        else
            Durations = Offsets - Onsets;
        end
        
        EventMatrix(EventMatrix(:,2) == ev,4) = Durations;
    end 
    EventMatrix(EventMatrix(:,2) >= hex2dec('8000'),:) = [];
    e.position = EventMatrix(:,1)';
    e.event_code = EventMatrix(:,2)';
    e.channel = EventMatrix(:,3)';
    e.duration = EventMatrix(:,4)';
    e.mode = 3;
end

sorted_events = e;