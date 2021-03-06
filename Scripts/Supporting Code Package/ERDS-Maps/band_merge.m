function [bandsout] = band_merge( b, gapfill, bwmin )
% Merge overlapping frequency bands.
%
% Usage:
%   [bandsout] = band_merge( bandsin, gapfill, bwmin )
%
% Input parameters:
%   bandsin .... [Nx3] each row corresponds to a frequency band. The first
%                column is the channel, the second column is the lower
%                frequency, and the third column is the upper frequency.
%   gapfill .... Frequency tolerance. Gaps between frequency bands will be
%                filled if they are smaller or equal gapfill.
%   bwmin ...... Bands smaller than bwmin will be removed.
%
% Output arguments:
%   bandsout ... [Nx3] each row corresponds to a frequency band. The first
%                column is the channel, the second column is the lower
%                frequency, and the third column is the upper frequency.
%
% band_merge.m:
%  Copyright by Martin Billinger
%  $Revision: 0.1 $ $Date: 05/11/2010 10:00:00 $
%  E-Mail: martin.billinger@tugraz.at

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

    if( size(b,2) ~= 3 )
        error( 'Wrong Input Dimensions' )
    end
    
    if( size(b,1) < 2 )
        % nothing to do
        bandsout = b;
        return
    end
    
    if ~exist( 'gapfill', 'var' )
        gapfill = 0;
    end
    
    if ~exist( 'bwmin', 'var' )
        bwmin = 0;
    end

    
    % merge bands
    while( 1 )
        bands_tmp = b(1,:);
        nochange = true;
        for i = 2 : size( b, 1 )
            merged = false;
            for j = 1 : size( bands_tmp, 1 )
                if( b(i,1) == bands_tmp(j,1) )
                    if( b(i,2) <= bands_tmp(j,3)+gapfill && b(i,3) > bands_tmp(j,3) )
                        %   -------------      ----------
                        %     ========       ==========
                        bands_tmp(j,3) = b(i,3);
                        merged = true;
                        nochange = false;
                        break
                    elseif( b(i,3) >= bands_tmp(j,2)-gapfill && b(i,2) < bands_tmp(j,2) )
                        %   -------------      ----------
                        %     ========           ==========
                        bands_tmp(j,2) = b(i,2);
                        merged = true;
                        nochange = false;
                        break
                    elseif( b(i,2) <= bands_tmp(j,2) && b(i,3) >= bands_tmp(j,3) )
                        %   ------------- 
                        %     ========
                        bands_tmp(j,:) = b(i,:);
                        merged = true;
                        nochange = false;
                        break
                    elseif( b(i,2) >= bands_tmp(j,2) && b(i,3) <= bands_tmp(j,3) )                
                        merged = true;
                        nochange = false;
                        break
                    end
                end
            end
            if( ~merged )
                bands_tmp = [bands_tmp; b(i,:)];
            end
        end
        if nochange
            break
        end
        b = bands_tmp;
    end
    
    % remove small bands
    bw = bands_tmp(:,3) - bands_tmp(:,2);
    bands_tmp( bw < bwmin, : ) = [];
    
    % sort bands
    [~,i] = sort( bands_tmp, 1 );
    bandsout = bands_tmp( i(:,2), : );
    
end