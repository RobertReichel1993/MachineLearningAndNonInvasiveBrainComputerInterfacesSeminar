function [erds_diff, sig_matrix, a] = plotErdsMap(r1, r2, varargin)
% Displays difference between time-frequency (ERDS) maps.
%
% This function plots the difference between two ERDS maps as calculated by
% calcErdsMap.m.
%
% Usage:
%   plotErdsMap(r1, r2);
%
% Input parameters:
%   r1 ... Input structure calculated with calcErdsMap.
%   r2 ... Input structure calculated with calcErdsMap.
%
% Optional input parameters (variable argument list):
%   't_range' ... Time range to plot <1x2>. Specify start and end points within a 
%                 trial (in s) to plot only a specific time range.
%                 Default: The whole time range is plotted.
%   'bands' ..... Frequency bands to highlight <Nx3>. Each row is a band,
%                 specified as [channel, lower_bound, upper_bound].
%   'nosig' ..... disable significance testing
%   'area_threshold' ... Threshold area for "islands" of significant pixels.
%                        Every island formed by adjacent significant pixels
%                        whose total area is below the treshold provided
%                        will be removed from the ERDS map. The area is
%                        calculated as Hz*sec, thus it should be independent
%                        of the resolution.
%                        Set area_threshold to 'alpha', for automatic
%                        threshold. In that case, areas that are smaller
%                        than alpha*total_area are removed. (alpha is the
%                        erd map's alpha level, and total_area is the total
%                        area of the map)

% plotErdsMap.m:
%  Copyright by Clemens Brunner
%  $Revision: 0.8 $ $Date: 03/10/2009 14:46:00 $
%  E-Mail: clemens.brunner@tugraz.at
%
% modified by Martin Billinger as plotErdsDiff.m
%  $Revision: 0.2 $ $Date: 20/04/2011 12:00:00
%  E-Mail: martin.billinger@tugraz.at

% Revision history:
%   0.2: 'area_threshold' parameter
%   0.1: Fork from plotErdsMap to display diff-maps, lots of additional
%        sanity checks between maps

% This program is free software; you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation; either version 2 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with
% this program; if not, write to the Free Software Foundation, Inc., 59 Temple
% Place - Suite 330, Boston, MA  02111-1307, USA.

if (nargin < 2)
    error('Not enough input ERDS map specified.');
end;

% Default parameters, can be overwritten by varargin
t_range = [];  % Plot the whole time range
show_bands = [];    % Highlight no bands
nosig = false;
area_threshold = 0;  % don't remove any pixels

% Overwriting default values with optional input parameters
if ~isempty(varargin)  % Are there optional parameters available?
   k = 1;
   while k <= length(varargin)
       if strcmp(varargin{k}, 't_range')
           t_range = varargin{k + 1};
           k = k + 2;
       elseif strcmp(varargin{k}, 'bands')
           show_bands = varargin{k+1};
           k = k + 2;
       elseif strcmp(varargin{k}, 'nosig')
           nosig = true;
           k = k+1;       
       elseif strcmp(varargin{k}, 'area_threshold')
           area_threshold = varargin{k + 1};
           if ischar( area_threshold )
               area_threshold = -1;
           end
           k = k + 2;
       else  % Ignore unknown parameters
            k = k + 1;
       end;
   end;
end;

% Sanity checks
check_size( r1, r2, 'ERDS', 'error', 'ERDS maps must have same number of channels.' );
check_size( r1, r2, 'f_plot', 'error', 'ERDS maps must have same number of frequency bands.' );
check_value( r1, r2, 'f_plot', 'error', 'ERDS maps must have same frequency bands.' );
check_size( r1, r2, 't_plot', 'error', 'ERDS maps must have same number of time steps.' );
check_value( r1, r2, 't_plot', 'error', 'ERDS maps must have same time steps.' );
check_value( r1, r2, 'ref', 'error', 'ERDS maps must have same reference.' );
check_value( r1, r2, 'submean', 'error', 'One ERDS map has mean subtracted, but the other has not.' );
check_string( r1, r2, 'sig', 'error', 'ERDS maps have different significance tests.' );
check_value( r1, r2, 'alpha', 'error', 'ERDS maps have different alpha levels.' );

check_value( r1, r2, 'fs', 'warning', 'ERDS maps have different sample rates.' );
check_string( r1, r2, 'fname', 'warning', 'ERDS maps come from different files.' );
check_string( r1, r2, 'ERDS_method', 'warning', 'ERDS maps were calculated from different methods.' );
check_value( r1, r2, 'montage', 'warning', 'ERDS maps have different montage configurations.' );


% Does the range interval lie inside the calculated time segment?
if ~isempty(t_range)
    if numel(t_range) ~= 2
        error('Argument t_range must be a <1x2> vector containing the start and end point (in s).');
    end;
    if t_range(1) >= t_range(2)
        error('First element of t_range must be less than the second element.');
    end;
    if t_range(1) < r.t_plot(1) || t_range(2) > r.t_plot(end)
        error('Argument t_range must lie inside calculated time segment.');
    end;
    
    % Cut out time segment to plot
    [temp, pos] = find(r.t_plot >= t_range(1) & r.t_plot <= t_range(2));
    r.t_plot = r.t_plot(pos);
    for k = 1:length(r.ERDS)
        r.ERDS{k}.erds = r.ERDS{k}.erds(pos,:);
    end;
    if ~strcmp(r.sig, 'none')
        for k = 1:length(r.ERDS)
            r.ERDS{k}.cl = r.ERDS{k}.cl(pos,:);
            r.ERDS{k}.cu = r.ERDS{k}.cu(pos,:);
        end;
    end;
    
end;

border = 0.1;  % Border around figure
border_plots = 0.01;  % Border around each plot
plot_area = 1 - 2 * border;

% Topographic layout
if isfield(r1, 'montage')
    plot_index = find(r1.montage' == 1);
    n_rows = size(r1.montage, 1);
    n_cols = size(r1.montage, 2);
else  % create default layout
    plot_index = 1:length(r1.ERDS);
    n_cols = ceil(sqrt(length(r1.ERDS)));
    if (length(r1.ERDS) > 2)
        n_rows = n_cols;
    else
        n_rows = 1;
    end;
end;

i_width = plot_area / n_cols;  % Width of one subplot
i_height = plot_area / n_rows;  % Height of one subplot
font_size = 1/32;  % Default normalized axes font size

% If significance information exists, plot only significant data
if ~(strcmp(r1.sig, 'none') || nosig)
    for chn = 1:length(r1.ERDS)
        
        sig_matrix{chn} = (sign(r2.ERDS{chn}.cu-r1.ERDS{chn}.cl) .* sign(r1.ERDS{chn}.cu-r2.ERDS{chn}.cl)) < 0;
        
        if area_threshold == -1
            total_area = length(sig_matrix{chn}(:));
            sig_matrix{chn} = bwareaopen( sig_matrix{chn}, round(total_area * r1.alpha) );
            disp( ['Automatic threshold: ' num2str( round(total_area * r1.alpha) * r1.t(2)*r1.f_steps )] )
        elseif area_threshold > 0
            sig_matrix{chn} = bwareaopen( sig_matrix{chn}, round( area_threshold / ( r1.t(2)*r1.f_steps ) ) );
        end
        
        erds_diff{chn} = r2.ERDS{chn}.erds - r1.ERDS{chn}.erds;
    end;
else
    warning( 'No significance information in ERDS maps.' )    
    for chn = 1:length(r1.ERDS)
        
        sig_matrix{chn} = ones( size(r1.ERDS{chn}.erds) );
        erds_diff{chn} = r2.ERDS{chn}.erds - r1.ERDS{chn}.erds;
    end;
end

if strcmp(r1.sig, 'none' )
elseif strcmp(r1.sig, 'boxcox' )
else
    warning( [r1.sig ' method not yet supported.'] )
end

if( nargout > 0 && nargout < 3)
    return
end

f = figure;
set(f, 'PaperOrientation', 'landscape');
set(f, 'PaperType', 'A4');
set(f, 'PaperUnits', 'centimeters');
set(f, 'PaperPosition', [1, 1, 27.7, 19]);
set(f, 'Color', [1 1 1]);
set(f, 'DefaultAxesFontUnits', 'normalized');
set(f, 'DefaultAxesFontSize', font_size);

% Invert color map so that ERS is blue and ERD is red
load erdscolormap;
colormap(erdcolormap);

counter_total = 1;  % Iterates through all rows and columns
counter_plots = 1;  % Iterates through all subplots

a = cell(1, length(plot_index));  % Contains the axes of the ERDS subplots

for i_rows = 1:n_rows
    for i_cols = 1:n_cols
        if sum(counter_total == plot_index) == 1
            a{counter_plots} = axes('position', [border + border_plots + i_width * (i_cols - 1), plot_area + border + border_plots - i_height * i_rows, i_width - border_plots, i_height - border_plots]);
            set(f, 'CurrentAxes', a{counter_plots});

            if ~strcmp(r1.sig, 'none')
                %imagesc(r1.t_plot, r1.f_plot, sig_matrix{counter_plots}' .* abs(erds_diff{counter_plots}'), [0, 2.0]);
                imagesc(r1.t_plot, r1.f_plot, sig_matrix{counter_plots}' .* abs(erds_diff{counter_plots}') );
            else
                %imagesc(r1.t_plot, r1.f_plot, abs(erds_diff{counter_plots}'), [0, 2.0]);
                imagesc(r1.t_plot, r1.f_plot, abs(erds_diff{counter_plots}') );
            end
            colormap(flipud(bone));
            
            hold on
%             for i_bands = 1 : size(show_bands,1)
%                 if( show_bands(i_bands,1) == counter_plots )
%                       handle = patch( [r1.t_plot(1), r1.t_plot(end), r1.t_plot(end), r1.t_plot(1)], ...
%                           [show_bands(i_bands,2), show_bands(i_bands,2), show_bands(i_bands,3), show_bands(i_bands,3)], [0,0,0] );
%                       set(handle,'FaceAlpha',0.25);
%                       set(handle,'FaceColor',[0,1,0] );
%                       set(handle,'EdgeColor',[0,1,0] );
%                 end
%             end            
            hold off

            %set(gca, 'Tag', num2str(counter_plots));

            set(a{counter_plots}, 'ydir', 'normal');
            if sum(counter_total + n_cols == plot_index) == 1  % Draw x-labels only if there is no subplot below
                set(a{counter_plots}, 'XTickLabel', '');
            end;
            if sum(counter_total - 1 == plot_index) == 1 && i_cols ~= 1  % Draw y-labels only if there is no subplot to the left
                set(a{counter_plots}, 'YTickLabel', '');
            end;

            % Draw lines for reference interval and cue
            v = axis;
            line([r1.ref(1), r1.ref(1)], [v(3), v(4)], 'LineStyle', ':', 'Color', 'k');
            line([r1.ref(2), r1.ref(2)], [v(3), v(4)], 'LineStyle', ':', 'Color', 'k');
            if isfield(r1, 'cue')
                line([r1.cue, r1.cue], [v(3), v(4)], 'Color', 'k');
            end;
            
            counter_plots = counter_plots + 1;
        end;
        counter_total = counter_total + 1;
    end;
end;

showErdsBands( r1, show_bands, a, [0 1 0] );

% Heading
if isfield(r1, 'heading')  % Recording date
    axes('position', [border + border_plots, 1 - 3/4* border, 1 - 2 * (border + border_plots), border], 'visible', 'off');
    text(0.5, 0, r1.heading, 'FontUnits', 'normalized', 'FontSize', 1/4, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'Bottom', 'Interpreter', 'none', 'FontWeight', 'bold');
end;
%line([0, 1], [0, 0], 'Color', 'k');

% Additional text
axes('position', [border + border_plots, 3/4*border, 1 - 2 * (border + border_plots), 3/4*border], 'visible', 'off');
temp_str{1} = ['{\bfERDS maps 0.7 (', upper(r1.ERDS_method), ').}{\rm Calculated on ', r1.date_calc, ', ', r2.date_calc, '.}'];

if length(r1.classes) > 1
    classes_str1 = ' classes: [';
    for k = 1:length(r1.classes)
        classes_str1 = [classes_str1, num2str(r1.classes(k))];
        if k < length(r1.classes)
            classes_str1 = [classes_str1, ', '];
        end;
    end;
    classes_str1 = [classes_str1, ']'];
else
    classes_str1 = [' class: ', num2str(r1.classes)];
end;

if length(r2.classes) > 1
    classes_str2 = ' classes: [';
    for k = 1:length(r2.classes)
        classes_str2 = [classes_str2, num2str(r2.classes(k))];
        if k < length(r2.classes)
            classes_str2 = [classes_str2, ', '];
        end;
    end;
    classes_str2 = [classes_str2, ']'];
else
    classes_str2 = [' class: ', num2str(r2.classes)];
end;

t_str = ['[', num2str(r1.t(1)), ', ', num2str(r1.t(2)), ', ', num2str(r1.t(3)), ']s'];

f_borders_str = '[';
for k = 1:length(r1.f_borders)
    f_borders_str = [f_borders_str, num2str(r1.f_borders(k))];
    if k < length(r1.f_borders)
        f_borders_str = [f_borders_str, ', '];
    end;
end;
f_borders_str = [f_borders_str, ']Hz'];

if length(r1.f_bandwidths) > 1
    f_bandwidths_str = '[';
    for k = 1:length(r1.f_bandwidths)
        f_bandwidths_str = [f_bandwidths_str, num2str(r1.f_bandwidths(k))];
        if k < length(r1.f_bandwidths)
            f_bandwidths_str = [f_bandwidths_str, ', '];
        end;
    end;
    f_bandwidths_str = [f_bandwidths_str, ']'];
else
    f_bandwidths_str = num2str(r1.f_bandwidths);    
end;
f_bandwidths_str = [f_bandwidths_str, 'Hz'];

if length(r1.f_steps) > 1
    f_steps_str = '[';
    for k = 1:length(r.f_steps)
        f_steps_str = [f_steps_str, num2str(r1.f_steps(k))];
        if k < length(r1.f_steps)
            f_steps_str = [f_steps_str, ', '];
        end;
    end;
    f_steps_str = [f_steps_str, ']'];
else
    f_steps_str = num2str(r1.f_steps);    
end;
f_steps_str = [f_steps_str, 'Hz'];

ref_str = ['[', num2str(r1.ref(1)), ', ', num2str(r1.ref(2)), ']s'];

temp_str{2} = ['Trials: ', num2str(r1.n_trials), classes_str1, ', fs: ', num2str(r1.fs), 'Hz, time: ', t_str, ', ref: ', ref_str];
temp_str{3} = ['Trials: ', num2str(r2.n_trials), classes_str2, ', fs: ', num2str(r2.fs), 'Hz, time: ', t_str, ', ref: ', ref_str];
temp_str{4} = ['f borders: ', f_borders_str, ', f bandwidths: ', f_bandwidths_str, ', f steps: ', f_steps_str, ', '];
if strcmp(r1.sig, 'boot')
    temp_str{4} = [temp_str{4}, 'Bootstrap significance test (\alpha = ', num2str(r1.alpha), ')'];
elseif strcmp(r1.sig, 'boxcox')
    temp_str{4} = [temp_str{4}, 'Box-Cox significance test (\alpha = ', num2str(r1.alpha), ', \lambda = ', num2str(r1.lambda), ')'];
else
    temp_str{4} = [temp_str{4}, 'no significance test.'];
end;
text(0, 0, temp_str, 'FontUnits', 'normalized', 'FontSize', 1/6, 'VerticalAlignment', 'Top', 'Interpreter', 'Tex');
%line([0, 1], [0, 0], 'Color', 'k');

%hndl = findobj('parent', gcf, 'type', 'axes');
%for a = 1:length(hndl)
%    set(findobj('parent', hndl(a)), 'ButtonDownFcn', 'zoomMap(r)');
%end;

if( nargout == 0 )
    clear erds_diff
end


%==================================================================
function check_size( r1, r2, fieldname, errlvl, message )
    b1 = isfield(r1,fieldname);
    b2 = isfield(r2,fieldname);
    if xor( b1, b2 )
        warning( [fieldname ' is not present in both maps.'] )
    else
        if b1 && b2
            s = size( getfield(r1,fieldname) ) ~= size( getfield(r2,fieldname) );
            if sum( s(:) )
                if strcmp('ERR', upper(errlvl)) || strcmp('ERROR', upper(errlvl))
                    error( message );
                elseif strcmp('WARN', upper(errlvl)) || strcmp('WARNING', upper(errlvl))
                    warning( message );
                end
            end
        end
    end
    

function check_value( r1, r2, fieldname, errlvl, message )
    b1 = isfield(r1,fieldname);
    b2 = isfield(r2,fieldname);
    if xor( b1, b2 )
        warning( [fieldname ' is not present in both maps.'] )
    else
        if b1 && b2
            s = getfield(r1,fieldname) ~= getfield(r2,fieldname);
            if sum( s(:) )
                if strcmp('ERR', upper(errlvl)) || strcmp('ERROR', upper(errlvl))
                    error( message );
                elseif strcmp('WARN', upper(errlvl)) || strcmp('WARNING', upper(errlvl))
                    warning( message );
                end
            end
        end
    end
    

function check_string( r1, r2, fieldname, errlvl, message )
    b1 = isfield(r1,fieldname);
    b2 = isfield(r2,fieldname);
    if xor( b1, b2 )
        warning( [fieldname ' is not present in both maps.'] )
    else
        if b1 && b2
            if ~strcmp( getfield(r1,fieldname), getfield(r2,fieldname) )
                if strcmp('ERR', upper(errlvl)) || strcmp('ERROR', upper(errlvl))
                    error( message );
                elseif strcmp('WARN', upper(errlvl)) || strcmp('WARNING', upper(errlvl))
                    warning( message );
                end
            end
        end
    end
