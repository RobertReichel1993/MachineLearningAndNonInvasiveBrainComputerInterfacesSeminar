
if ( ~exist ( 'VARARGIN_VARIABLES', 'var' ) )

  error ( '## VARARGIN assignment script requires variable VARARGIN_VARIABLES' );

end
  
 
% Get parameters
iVarArginAssignmentIdx = 1;

while ( iVarArginAssignmentIdx <= length(varargin) )

  iVarArginVariableIdx = 1;
  bFound = false;
  
  while ( ~bFound && ( iVarArginVariableIdx <= length(VARARGIN_VARIABLES) ) )

    if ( strcmpi ( varargin{iVarArginAssignmentIdx}, VARARGIN_VARIABLES{iVarArginVariableIdx} ) )
      
      aVal = [];
      
      if ( isnumeric ( varargin{iVarArginAssignmentIdx+1} ) )
        
        if ( length(varargin{iVarArginAssignmentIdx+1}) > 1 )

          aVal = mat2str ( varargin{iVarArginAssignmentIdx+1} );
          
        else
          
          aVal = num2str ( varargin{iVarArginAssignmentIdx+1} );
        
        end

        
      else
        
        aVal = varargin{iVarArginAssignmentIdx+1};
        

        
        
      end
      
      
             eval ( [VARARGIN_VARIABLES{iVarArginVariableIdx} ' = ' aVal ';'] );
      

      iVarArginAssignmentIdx = iVarArginAssignmentIdx + 2;
      
      bFound = true;
      
    end
    
    iVarArginVariableIdx = iVarArginVariableIdx + 1;
    
  end

      
end
