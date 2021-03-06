function [signal,header,events, files] = gdf_multiread( files, varargin )

% function [SIGNALS, HEADER, EVENTS, FILES] = gdf_multiread( FILES, OPTION, VALUE, ... )
%
% Load and concatenate multiple GDF files.
%
% Input Arguments:
%
%   FILES:   If FILES is a cell array, each element is interpreted as a
%            filename to be loaded in the same order as they appear in the
%            list.
%            If FILES is a string, a list of files that match that string
%            is automatically generated in alphabetical order. For example
%            'data/*.gdf' loads all .gdf files in the data subfolder.
%   OPTIONS: See gdf_reader help.
%
% Output Arguments:
%
%   SIGNALS: \   
%   HEADER :  > See gdf_reader help.
%   EVENTS : /
%
%   FILES  : List of files in the order they were loaded.

if ~iscell( files )
    [p,n,e] = fileparts(files);
    files = dir( files );
    files = sort( {files.name} )';
    if ~isempty(p)
        files = strcat( p, filesep, files );
    end
    %files
end

nf = length(files);

header.file.file_offsets = zeros(1,nf);

[signal,header,events] = gdf_reader( files{1}, varargin{:} );

offset = double(header.file.num_datarecords) * double(header.file.datarecord_duration);

for i = 2 : nf

    [s,h,e] = gdf_reader( files{i}, varargin{:} );
    
    if i < nf
        if events.mode == 1
            events.position = [events.position, offset*double(e.sample_rate)];
            events.event_code = [events.event_code, hex2dec('7ffe')];
        else
            events.position = [events.position, offset*double(e.sample_rate)];
            events.event_code = [events.event_code, hex2dec('7ffe')];
            events.channel = [events.channel 0];
            events.duration = [events.duration 0];
        end
    end
    
    header.file.num_datarecords = double(header.file.num_datarecords) + double(h.file.num_datarecords);
    
    if events.mode == 1
        %disp('mode 1 handling')
        events.position = [events.position, double(e.position) + offset*double(e.sample_rate)];
        events.event_code = [events.event_code e.event_code];
    else
        %disp('mode 3 handling')
        events.position = [events.position, double(e.position) + offset*double(e.sample_rate)];
        events.event_code = [events.event_code e.event_code];
        events.channel = [events.channel e.channel];
        events.duration = [events.duration e.duration];

    end

    header.file.file_offsets(i) = offset;
    
    offset = offset + double(h.file.num_datarecords) * double(h.file.datarecord_duration);
    
    if( iscell(signal) )
        
        for k = 1 : header.file.num_signals
            if size( signal{k}, 1 ) == 1
                signal{k} = [signal{k} s{k}];
            else
                signal{k} = [signal{k}; s{k}];
            end
        end
    elseif( isstruct(signal) )
        if size(signal(1).data,1) == length(signal(1).channels)
            for j = 1 : length(signal)
                signal(j).data = [signal(j).data, s(j).data];
            end
        elseif size(signal(1).data,2) == length(signal(1).channels)
            for j = 1 : length(signal)
                signal(j).data = [signal(j).data; s(j).data];
            end
        else
            error 'Signal has wrong number of channels.'
        end
    else
        if( size(s,1) == h.file.num_signals )
            signal = [signal, s];
        elseif( size(s,2) == h.file.num_signals )
            signal = [signal; s];
        else
            error 'Signal has wrong number of channels.'
        end
    end
    
end

header.recording.id = 'multiple files';

end
