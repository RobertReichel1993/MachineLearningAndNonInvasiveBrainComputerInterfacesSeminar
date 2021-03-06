function [bands] = band_selection( r1, r2, min_area, t_range, f_range, dweight )
% Automatically select frequency bands from the difference of two ERDS
% maps.
%
% Bands are chosen from adjacent pixels that differ significantly between
% the two maps. If the area covered by adjacent pixels exceeds a treshold,
% a band is chosen.
%
% Usage:
%   [bands] = band_selection( r1, r2, min_area, t_range, f_range )
%
% Input parameters:
%   r1 ......... Input structure calculated with calcErdsMap.
%   r2 ......... Input structure calculated with calcErdsMap.
%   min_area ... Treshold area. (Units: Hz*sec)
%   t_range .... [1x2] minimum and maximum time where we look for bands.
%   f_range .... [1x2] minimum and maximum frequency to look for bands.
%   dweight .... *UNUSED* difference weight for area calculation( 0..1 ) .
%
% Output arguments:
%   bands ...... [Nx3] each row corresponds to a frequency band. The first
%                column is the channel, the second column is the lower
%                frequency, and the third column is the upper frequency.
%
% band_selection.m:
%  Copyright by Martin Billinger
%  $Revision: 0.1 $ $Date: 08/09/2010 15:30:00 $
%  E-Mail: martin.billinger@tugraz.at

% Revision history:
%   0.1: First usable version
%   0.2: Now using functions from the image processing toolbox

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

if ~exist( 'dweight', 'var' ) || isempty( dweight )
    dweight = 0;
end

if ~exist( 'f_range', 'var' ) || isempty( f_range )
    f_range = r1.f_borders;
end

if ~exist( 't_range', 'var' ) || isempty( t_range )
    t_range = [r1.t(1),r1.t(end)];
end

% convert ranges to indices
tmp = find( (r1.f_plot >= f_range(1)) & (r1.f_plot <= f_range(2)) );
f_range = [tmp(1), tmp(end)];

tmp = find( (r1.t_plot >= t_range(1)) & (r1.t_plot <= t_range(2)) );
t_range = [tmp(1), tmp(end)];

[diff, sig] = plotErdsDiff( r1, r2 );

bands = zeros(0,3);

for ch = 1 : length(diff)
    
    % new method
    
    pixelfactor = r1.t(2)*r1.f_steps;   % area [s*Hz] of a pixel
    min_pixels = round(min_area/pixelfactor);
    
    % remove significant regions that are too small
    bin = bwareaopen( sig{ch}, min_pixels );
    
    % identify regions
    %[Bd,L] = bwboundaries(bin,'noholes');
    
    %stats = regionprops( bin, abs(diff{ch}), 'MeanIntensity', 'BoundingBox', 'PixelList' );
    stats = regionprops( bin, abs(diff{ch}), 'PixelList' );
    
    for i = 1 : length(stats)
        band = [r1.f_low(min(stats(i).PixelList(:,1))), r1.f_up(max(stats(i).PixelList(:,1)))];
        bands = [bands; ch, band];
    end
    
    bands = band_merge( bands, 0.5, 2.0 );
    
    % old method
    
%     d = abs( sig{ch} .* diff{ch} );
%     b = zeros(0,2);
%     while( sum(d(:)) > 0 )
%         [dummy,t] = max( d );
%         [~,f] = max( dummy );
%         t = t(f);
%         [band, area, d] = fill( d, f, t, r1.t(2)*r1.f_steps, dweight, t_range, f_range );
%         if( area > min_area )
%             b = [b; r1.f_low(band(1)), r1.f_up(band(2)) ];
%         end
%     end
%     
%     if( size(b,1) == 0 )
%         % found no bands
%         continue
%     end
%     
%     % merge bands
%     while( 1 )
%         bands_tmp = b(1,:);
%         nochange = true;
%         for i = 2 : size( b, 1 )
%             merged = false;
%             for j = 1 : size( bands_tmp, 1 )
%                 %if( b(i,1) > bands_tmp(j,2) || b(i,2) < bands_tmp(j,1) )
%                 %    break
%                 %else
%                 if( b(i,1) <= bands_tmp(j,2) && b(i,2) > bands_tmp(j,2) )
%                     bands_tmp(j,2) = b(i,2);
%                     merged = true;
%                     nochange = false;
%                     break
%                 elseif( b(i,2) >= bands_tmp(j,1) && b(i,1) < bands_tmp(j,1) )
%                     bands_tmp(j,1) = b(i,1);
%                     merged = true;
%                     nochange = false;
%                     break
%                 elseif( b(i,1) <= bands_tmp(j,1) && b(i,2) >= bands_tmp(j,2) )
%                     bands_tmp(j,:) = b(i,:);
%                     merged = true;
%                     nochange = false;
%                     break
%                 elseif( b(i,1) >= bands_tmp(j,1) && b(i,2) <= bands_tmp(j,2) )                
%                     merged = true;
%                     nochange = false;
%                     break
%                 end
%             end
%             if( ~merged )
%                 bands_tmp = [bands_tmp; b(i,:)];
%             end
%         end
%         if nochange
%             break
%         end
%         b = bands_tmp;
%     end
%     
%     % sort bands
%     [~,i] = sort( bands_tmp, 1 );
%     bands_tmp = bands_tmp( i(:,2), : );
%     
%     bands = [bands; repmat(ch,size(bands_tmp,1),1),bands_tmp];

end

end

% ========================

% function [band, area, d] = fill( d, f, t, pixelfactor, dweight, t_range, f_range )
%     d(t,f) = 0;                             % mark as visited
%     if( f < f_range(1) || f > f_range(2) || t < t_range(1) || t > t_range(2) )
%         band = zeros( 0, 2 );
%         area = 0;
%         return
%     end
%     area = 1-dweight + dweight*d(t,f);
%     list = [f,t];                           % positions we have visited
%     queue = [f-1,t; f+1,t; f,t-1; f, t+1];  % positions we need to visit
%     while( size(queue,1) > 0 )
%         f = queue(1,1);
%         t = queue(1,2);
%         queue(1,:) = [];
%         
%         if( (t>=t_range(1)) && (f>=f_range(1)) && (t<=t_range(2)) && (f<=f_range(2)) )
%             if( d(t,f) > 0 )
%                 area = area + 1-dweight + dweight*d(t,f);
%                 list = [list;f,t];
%                 d(t,f) = 0;
%                 queue = [f-1,t; f+1,t; f,t-1; f, t+1 ; queue];
%             end        
%         end
%     end
%     %area = size(list,1);
%     area = area * pixelfactor;
%     band(1) = min(list(:,1));
%     band(2) = max(list(:,1));
% end

