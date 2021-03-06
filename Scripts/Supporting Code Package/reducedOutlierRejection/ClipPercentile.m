
function [aClippedValues] = ClipPercentile ( aValues, aTotalPercentile )

  aValues = aValues (:);

  iNumToClipOnEachTail = max ( 1, fix ( ( length(aValues) * aTotalPercentile ) / 2 ) );
  
  [aVals, aIdx] = sort ( aValues );
  
  aIdx = aIdx (iNumToClipOnEachTail+1:end-iNumToClipOnEachTail);
  
  aClippedValues = aValues(aIdx);
end

