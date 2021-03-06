% CSP - MATLAB subroutine to filter a signal with a CSP model
% by David Steyrl
%
% Use:
% Y = csp_filter(model_csp,filter_selection,X)
%
% Y                 = CSP filtered X [filters x time-samples].
% model_csp         = CSP model to use [weights per channel x spatial filters].
% filter_selection  = A logical row vector with dimesion [1 x filters], 
%                     each true entry selects a column (a CSP filter).
% X                 = A signal to be filtered [time-samples x channels].
%
% Last modified: Oct-25-2013 by David Steyrl

function Y = csp_filter(model_csp,filter_selection,X)

filter_coeff = model_csp(:,filter_selection);

Y = X*filter_coeff;

end % EOF