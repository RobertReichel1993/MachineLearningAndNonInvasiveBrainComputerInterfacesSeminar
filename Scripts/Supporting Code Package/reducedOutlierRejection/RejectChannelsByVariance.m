
function [aVA_CHRej, aMeanChannelVars, aGrandMedVar, aGrandSTDVar] = RejectChannelsByVariance ( aSigBPassEpoched, CH_VAR_FACT )

  aChannelVars = var ( aSigBPassEpoched, 0, 3 );
  
  aMeanChannelVars = mean ( aChannelVars, 2 );
  
  aGrandMedVar = median ( aMeanChannelVars, 1 );
  aGrandSTDVar = std    ( ClipPercentile ( aMeanChannelVars, 1/4 ), 0, 1 );
  
  aVA_CHRej = ( aMeanChannelVars < ( aGrandMedVar - CH_VAR_FACT * aGrandSTDVar ) ) | ( aMeanChannelVars > ( aGrandMedVar + CH_VAR_FACT * aGrandSTDVar ) );

  % fprintf ( '\n## GrandMedianVar [%2.1f] GrandSTDVar [%2.1f] rejected [%d] channels in %s', aGrandMedVar, aGrandSTDVar, sum ( aVA_CHRej ), mat2str((sort(fix(aMeanChannelVars*100)/100.0)')) );
  
end