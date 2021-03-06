% CSP - MATLAB subroutine to train common spatial patterns transformation
% for 2 classes by David Steyrl
%
% Use:
% model_csp   = csp_train(data_class1,data_class2,method,ac)
%
% model_csp   = CSP weights (first column is the most varying spatial filter
%               for class 1, last column is the most varying spatial filter
%               for class 2)
% data_class1 = [samples x channels] of class 1 all together or 
%               [samples x channels x trials] of class 1 per trial, if 
%               method is not 'given'.
% data_class2 = [samples x channels] of class 2 all together or 
%               [samples x channels x trials] of class 2 per trial, if 
%               method is not 'given'.
% data_class1 = [channels x channels] cov of class 1 or
%               [channels x channels x trials] of class 1 per trial, if 
%               method is 'given'.
% data_class2 = [channels x channels] cov of class 2 or
%               [channels x channels x trials] of class 2 per trial, if 
%               method is 'given'.
% method      = (optional) Which method for calculating the cov matrix should
%               be used? 'ac shrinkage' (default) or 'shrinkage' or 
%               'standard' or use 'given' covariance matrix
% ac          = (optional) auto correlation factor, number of samples of auto
%               correlation in data, typical value for EEG is a number of 
%               samples equal to 0.2 to 0.4s)
% 
% Dependences:
% cov_shrink.m
% cov_shrink_ac.m
%
% Last modified: January-21-2016 by David Steyrl

function model_csp = csp_train(data_class1,data_class2,method,ac)

% Default covariance calculation method
if (nargin == 2)
    method = 'ac shrinkage';
    ac = 20;
elseif (nargin == 3)
    if strcmp(method,'ac shrinkage')
        ac = 20;
        disp('Notice: no value for ac set. Use default of 20.');
    end
end

% Calculate the covariance matrices
if (ndims(data_class1) == 2 && ndims(data_class2) == 2)
    switch method
        case 'ac shrinkage'
            S1 = cov_shrink_ac(data_class1,ac);
            S2 = cov_shrink_ac(data_class2,ac);
        case 'shrinkage'
            S1 = cov_shrink(data_class1);
            S2 = cov_shrink(data_class2);
        case 'standard'
            S1 = cov(data_class1);
            S2 = cov(data_class2);
        case 'given'
            S1 = data_class1;
            S2 = data_class2;
        otherwise
            disp('Unknown covariance matrix estimation method.')
            model_csp = NaN;
            return
    end
elseif (ndims(data_class1) == 3 && ndims(data_class2) == 3)
    switch method
        case 'ac shrinkage'
            for cTrial = 1:size(data_class1,3)
                S1(:,:,cTrial) = cov_shrink_ac(data_class1(:,:,cTrial),ac);
                S2(:,:,cTrial) = cov_shrink_ac(data_class2(:,:,cTrial),ac);
            end
        case 'shrinkage'
            for cTrial = 1:size(data_class1,3)
                S1(:,:,cTrial) = cov_shrink(data_class1(:,:,cTrial));
                S2(:,:,cTrial) = cov_shrink(data_class2(:,:,cTrial));
            end
        case 'standard'
            for cTrial = 1:size(data_class1,3)
                S1(:,:,cTrial) = cov(data_class1(:,:,cTrial));
                S2(:,:,cTrial) = cov(data_class2(:,:,cTrial));
            end
        case 'given'
            S1 = data_class1;
            S2 = data_class2;
        otherwise
            disp('Unknown covariance matrix estimation method.')
            model_csp = NaN;
            return
    end
else
    disp('Dimension missmatch of class 1 and class 2.')
	model_csp = NaN;
	return
end

% Average S
S1_avg = mean(S1,3);
S2_avg = mean(S2,3);

% Normalize the covariance matrices by the trace
S1_n = S1_avg/trace(S1_avg);
S2_n = S2_avg/trace(S2_avg);

% Solve the eigen value problem
[V, D] = eig(S1_n,S1_n+S2_n,'qz');

% Sort eigen values descending
[~,IX] = sort(diag(D),'descend');

% Sort eigen vectors according to the eigen values
model_csp = V(:,IX);

end % EOF
