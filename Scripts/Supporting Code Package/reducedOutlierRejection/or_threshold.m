function [aRejectedEpochIdcs] = or_threshold ( aSig, EP_AMP_TH_MIN, EP_AMP_TH_MAX )

  DEBUG = false;

  if ( EP_AMP_TH_MIN >= EP_AMP_TH_MAX )
    error ( '## Threshold for min needs to be smaller than the threshold for max.' ); 
  end
  
  aRejectedEpochIdcs = [];
  
  for ( k = 1:size (aSig,3) )
    iBelowTH = sum ( sum ( aSig(:,:,k) < EP_AMP_TH_MIN ) );
    iAboveTH = sum ( sum ( aSig(:,:,k) > EP_AMP_TH_MAX ) );
    
    if ( ( iBelowTH > 0 ) || ( iAboveTH > 0 ) )
      if ( DEBUG )
        PlotSignal ( squeeze ( aSig(:,:,k) )' );
      end
      
      aRejectedEpochIdcs = [aRejectedEpochIdcs k];
    end
  end
    
end
