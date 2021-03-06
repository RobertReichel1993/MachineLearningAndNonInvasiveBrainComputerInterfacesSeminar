function eegplot_cp(INPUT_SIGNAL, INPUT_SCALE, INPUT_FS, INPUT_SECWIN, INPUT_LABELS, INPUT_MARKERS)

    COLOR.BKG       = [0.9 0.9 0.9];
    COLOR.EEG       = [0.0 0.0 0.0];
    COLOR.BAS       = [0.7 0.7 0.7];
    COLOR.DISP      = [1.0 1.0 1.0];
    COLOR.MARKER{1} = COLOR.DISP;
    COLOR.MARKER{2} = [0.5 0.5 1.0]; % blue
    COLOR.MARKER{3} = [1.0 0.5 0.5]; % red
    
    % Checkings
    if (iscell(INPUT_SIGNAL))
        SIGNAL = [];
        nbSamplesPerSignal = zeros(1,length(INPUT_SIGNAL));
        for s = 1:length(INPUT_SIGNAL)
            nbSamplesPerSignal(s) = length(INPUT_SIGNAL{s});
            SIGNAL = [SIGNAL INPUT_SIGNAL{s}];
        end
    else
        SIGNAL = INPUT_SIGNAL;
    end
    
    [ nbChannels, nbSamples ] = size(SIGNAL);
        
    if (nargin < 6)
        MARKERS = zeros(1,nbSamples);
    else
        MARKERS = [];
        if (iscell(INPUT_SIGNAL))
            for s = 1:length(INPUT_SIGNAL)
                MARKERS = [MARKERS INPUT_MARKERS{s}];
            end
        else
            MARKERS = INPUT_MARKERS;
        end
    end

    % Configure (invariable)
    cfg.dspPos      = [0.025 0.125 0.95 0.85];
    cfg.numSec      = ceil( nbSamples / INPUT_FS );
    cfg.winSamp     = INPUT_SECWIN * INPUT_FS;
    cfg.numMarkers  = 0;
    
    % Configure (variable)
    cfg.axis_min    = 0;
    cfg.axis_max    = INPUT_SCALE * (nbChannels+1);
    baseline = zeros(nbChannels, cfg.winSamp);
    for ch = 1:nbChannels
        baseline(ch,:) = baseline(ch,:) + cfg.axis_max - ch*INPUT_SCALE;
    end
    
    % Tracking the data...
    dsp.sampStart   = 1;
    dsp.sampWindow  = dsp.sampStart:(dsp.sampStart+cfg.winSamp-1);
    supIdx          = find( dsp.sampWindow > nbSamples );
    dsp.sampWindow( supIdx ) = [];
    dsp.SampCur     = 0;
    dsp.SampCurAbs  = 0;
    
    % Initialize figure
        fig = figure;
        set(gcf, 'Color', COLOR.BKG); box on 
        set(gca, 'Position', cfg.dspPos);
        set(gca, 'XLim', [1 cfg.winSamp]);
        set(gca, 'XTick', [1:INPUT_FS:cfg.winSamp]); 
        set(gca, 'XTickLabel', 0:1:INPUT_SECWIN);
        set(gca, 'YLim', [cfg.axis_min cfg.axis_max]);
        set(gca, 'YTick', [INPUT_SCALE:INPUT_SCALE:(cfg.axis_max-INPUT_SCALE)]);
        set(gca, 'YTickLabel', INPUT_LABELS(end:-1:1));
        set(gca, 'Color', COLOR.DISP);
        cfg.xlm = get(gca,'xlim');
        cfg.ylm = get(gca,'ylim');
        cfg.dfx = diff(cfg.xlm);
        cfg.dfy = diff(cfg.ylm);
        
        % update
        hold on
        for ch = 1:nbChannels
            plot_baseline(ch) = plot(1:cfg.winSamp, baseline(ch,:));
            set(plot_baseline, 'Color', COLOR.BAS);
            plot_eeg(ch) = plot(1:length(dsp.sampWindow), SIGNAL(ch,dsp.sampWindow)+baseline(ch,1));
            set(plot_eeg, 'Color', COLOR.EEG, 'LineWidth', 1);
        end
        hold off
        
    % uicontrol 
    pos     = get(gca,'position'); % [left bottom width height]
    pos4    = [pos(1)+2.0*pos(3)/4 pos(2)-0.1 pos(3)/4 0.05];
    pos5    = [pos(1)+6*pos(3)/8 pos(2)-0.1 pos(3)/8 0.05];
    pos6    = [pos(1)+7*pos(3)/8 pos(2)-0.1 pos(3)/8 0.05];
    
    dspBox = uicontrol('Style', 'text', ...
        'String', '', ...
        'units', 'normalized', 'position', pos4,...
        'FontSize', 10, 'FontWeight', 'normal', ...
        'HorizontalAlignment', 'center', ...
        'BackgroundColor', COLOR.BKG ); 
    uicontrol('Style', 'pushbutton', ...
        'String', 'Zoom In', ...
        'units', 'normalized', 'position', pos5,...
        'Callback', @zoom_in_Callback); 
    uicontrol('Style', 'pushbutton', ...
        'String', 'Zoom Out', ...
        'units', 'normalized', 'position', pos6,...
        'Callback', @zoom_out_Callback); 
    
    % Check if a buttom is pressed when focus on figure and exec callback
    set(gcf, 'KeyPressFcn', {@pb_kpf} );
    set(gcf, 'WindowButtonMotionFcn',{@fh_wbmfcn}) % Set the motion detector.
    update_plot();
    %uiwait(gcf);
    
    % Tracks the pointer to update the text information
    function [] = fh_wbmfcn(varargin)
        F = get(gcf,'currentpoint');  % The current point w.r.t the figure.
        getSampleCursor(F);      
        if (dsp.SampCur>0 && dsp.SampCurAbs < nbSamples)
            update_text();
        end
    end

    % Returns the position of the cursor in sample-units, either relative
    % within the current display window (dsp.SampCur) or absolute
    % (dsp.SampCurAbs)
    function getSampleCursor(Coord)
        screen_pos = get(gcf,'position');
        Coord(1) = Coord(1) / screen_pos(3);
        Coord(2) = Coord(2) / screen_pos(4);
        % Figure out of the current point is over the axes or not -> logicals.
        tf1 = cfg.dspPos(1) <= Coord(1) && Coord(1) <= cfg.dspPos(1) + cfg.dspPos(3);
        tf2 = cfg.dspPos(2) <= Coord(2) && Coord(2) <= cfg.dspPos(2) + cfg.dspPos(4);        
        if tf1 && tf2
            % Calculate the current point w.r.t. the axes.
            dsp.SampCur = floor(cfg.xlm(1) + (Coord(1)-cfg.dspPos(1)).*(cfg.dfx/cfg.dspPos(3)));
            dsp.SampCurAbs = dsp.sampStart + dsp.SampCur;
        else
            dsp.SampCur = -1;
            dsp.SampCurAbs = -1;
        end
    end

    % Forward/rewind when right/left arrows pressed
    function pb_kpf(varargin)
        if (strcmp(varargin{1,2}.Key, 'rightarrow'))
            % forward
            antStart = dsp.sampStart;
            newStart = dsp.sampStart + cfg.winSamp;
            if ( newStart < nbSamples )
                dsp.sampStart = newStart;
            end
            % update?
            if (antStart ~= dsp.sampStart)
                dsp.sampWindow  = dsp.sampStart:(dsp.sampStart+cfg.winSamp-1);
                supIdx = find( dsp.sampWindow > nbSamples );
                dsp.sampWindow( supIdx ) = [];
                update_plot();
                update_text();
            end
        elseif (strcmp(varargin{1,2}.Key, 'leftarrow'))
            % rewind
            antStart = dsp.sampStart;
            newStart = dsp.sampStart - cfg.winSamp;
            if ( newStart < 1 )
                dsp.sampStart = 1;
            else
                dsp.sampStart = newStart;
            end
            % update?
            if (antStart ~= dsp.sampStart)
                dsp.sampWindow  = dsp.sampStart:(dsp.sampStart+cfg.winSamp-1);
                supIdx = find( dsp.sampWindow > nbSamples );
                dsp.sampWindow( supIdx ) = [];
                update_plot();
                update_text();
            end
        end
    end

    % Zoom in of the data
    function zoom_in_Callback(hObj, event)
        INPUT_SCALE    = INPUT_SCALE/1.25;
        update_scale();
        update_plot();
        FocusToFig(hObj, event);
    end

    % Zoom out of the data
    function zoom_out_Callback(hObj, event)
        INPUT_SCALE    = INPUT_SCALE*1.25;
        update_scale();
        update_plot();
        FocusToFig(hObj, event);
    end

    % Updates the plot
    function update_plot()
        hold on
        % delete previous
        for p = 1:cfg.numMarkers
            delete(cfg.marker_line_list{p});
            delete(cfg.marker_text_list{p});
        end
        cfg.numMarkers = 0;
        % plot markers
        MARKER_WDW = MARKERS(dsp.sampWindow);
        antVal = MARKER_WDW(1);
        for i = 2:length(MARKER_WDW)
            if (antVal ~= MARKER_WDW(i))
                if (MARKER_WDW(i) > -1)
                    cfg.numMarkers = cfg.numMarkers+1;
                    cfg.marker_line_list{cfg.numMarkers} = line([i i], [cfg.axis_min, cfg.axis_max], 'LineWidth',2, 'Color', [1 0 0]);
                    cfg.marker_text_list{cfg.numMarkers} = text(i-6, 0, ['val = ' num2str(MARKER_WDW(i))], 'Rotation', 90, 'Color', [1 0 0], 'FontWeight', 'bold');
                end
                % update
                antVal = MARKER_WDW(i);
            end
        end
        % plot EEG
        for ch = 1:nbChannels
            delete(plot_eeg(ch));
            plot_eeg(ch) = plot(1:length(dsp.sampWindow), SIGNAL(ch,dsp.sampWindow)+baseline(ch,1));
            set(plot_eeg, 'Color', COLOR.EEG, 'LineWidth', 1);
        end
        hold off
        set(gca, 'layer', 'top');
    end

    % Updates the text
    function update_text()
        window_sec = [(dsp.sampWindow(1)-1)/INPUT_FS dsp.sampWindow(end)/INPUT_FS];
        DISPLAY_TEXT = sprintf('Sample %d; %.01f / %d s', dsp.SampCurAbs, dsp.SampCurAbs/INPUT_FS, cfg.numSec);
        set(dspBox,'String',DISPLAY_TEXT);
        set(gca, 'XTickLabel', window_sec(1):1:window_sec(2));
    end

    % Updates the scale
    function update_scale()
        cfg.axis_min    = 0;
        cfg.axis_max    = INPUT_SCALE * (nbChannels+1);
        baseline = zeros(nbChannels, cfg.winSamp);
        for ch = 1:nbChannels
            baseline(ch,:) = baseline(ch,:) + cfg.axis_max - ch*INPUT_SCALE;
        end
        set(gca, 'YLim', [cfg.axis_min cfg.axis_max]);
        set(gca, 'YTick', [INPUT_SCALE:INPUT_SCALE:(cfg.axis_max-INPUT_SCALE)]);
        cfg.ylm = get(gca,'ylim');
        cfg.dfy = diff(cfg.ylm);
        hold on
        for ch = 1:nbChannels
            delete(plot_baseline(ch));
            plot_baseline(ch) = plot(1:cfg.winSamp, baseline(ch,:));
            set(plot_baseline, 'Color', COLOR.BAS);
        end
        hold off
    end
end
