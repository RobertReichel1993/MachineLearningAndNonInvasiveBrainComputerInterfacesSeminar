function [Cshr, lambda, Ct] = cov_shrink_ac(X,maxDelay)
% cov_shrink_ac performes shrinkage regularization of covariance matrix 
% and takes auto correlation of data into account
% by David Steyrl
%
% This function is based on code of Daniel Bartz and his paper:
% Daniel Bartz, Johannes Höhne, Klaus-Robert Müller; Multi-Target
% Shrinkage; http://arxiv.org/pdf/1412.2041v1.pdf
%
% Use: 
% [Cshr, lambda]    = cov_shrink_ac(X,maxDelay)
% X                 = data (samples x dimension) e.g. for EEG 
%                       (time samples x channels)
% maxDelay          = max number of time samples for delay (typical value
%                       for EEG is a number of samples equal to 0.3 to 0.5 s)
%
% Dependences:
%
% Last modified: January-21-2016 by David Steyrl

% Sample covariance matrix
[~, n]  = size(X');
Xn      = X' - repmat(mean(X,1)', [1 n]);
S       = Xn*Xn'/(n-1);

for i=0:maxDelay
	Xn2{i+1}    = Xn(:,1:end-i).*Xn(:,1+i:end);
end

% Calculate variance of the covariance
for i=0:maxDelay
    if i==0
        V{1}        = (Xn2{1}*Xn2{1}'/(n)-S.^2);
        SumV0ii     = sum(diag(V{1}));
    else
        V{i+1}      = (n-i)/n*(Xn2{i+1}*Xn2{i+1}'/(n-i)-S.^2);
    end
    sumV(i+1) = sum(sum(V{i+1}));
end

% sumV
if maxDelay == 0
	SV = 1/n*sumV(1);
else
	SV = sumV(1)+2*sum(sumV(2:end));
	b = maxDelay;
	cf = (n-1-2*b+b*(b+1)/n);
	SV =  SV/cf;
end

% add the targets
Ct(:,:) = diag(diag(S));
covCtS = SumV0ii;

% call the optimization routine
[lambda, ~] = sotc_optimization(S,SV,Ct,covCtS);
                    
% calculate the shrinkage cov mat
% disp(lambda)
Cshr = (1-sum(lambda))*S+sum(lambda)*Ct(:,:);

% ensure symetry
Cshr = (Cshr+Cshr')/2;

end




function [lambda, problem] = sotc_optimization(C0, varC0, C, covCC0)
% sotm_optimization performs shrinkage towards multiple target means by solving a
% quadratic program.
%
% Features
%  - the function allows an arbitrary or convex linear combination of
%    covariance estimators.
%  - lambdas are restricted to [0, 1]
%
% Here, the 
%
%   Inputs:
%       C0 (DxD): sample mean
%       C (DxDxN): set of shrinkage mean
%       varC0 (1): est. variance of the sample covariance estimator
%       covCC0 (Nx1): est. covariance betweeen sample mean and shrinkage targets
%
%	Variable Inputs:
%           convex (bool): solve for a convex combination of matrices
%           trace (bool): solve under the constraint of trace
%                               conservation
%
%   Output:
%       lambda (Nx1): MSE-optimal weights of the linear combination
%
%
% 22.11.2013:
%   - re-write tidy sotm version from multishrink_optimization
% 21.01.2016 by David Steyrl
%   - some changes to fitt to cov_shrink_ac

opt.trace           = false;
opt.lowBoundAii     = false;
opt.normalized      = false;
opt.con_crossbias   = false;

% if an arbitrary linear combination is allowed, introduce an empty dummy mean
% set an empty dummy matrix
N = 2;
covCC0(N) = 0;
C(:,:,N) = 0;

% Define the matrices which build up the quadratic program
C = C - repmat(C0,[1 1 N]);
    
H = zeros(N);
for i=1:N
    for j=1:i
        H(i,j) = sum(sum(C(:,:,i).*C(:,:,j)));
    end
end

problem.H = 2*(H+tril(H,-1)');
problem.f = 2*(covCC0-varC0);
problem.Aineq = ones(1,N);
problem.bineq = 1;
problem.Aeq = [];
problem.beq = [];
problem.lb = zeros(N,1);
problem.ub = ones(N,1);

if strcmp(version,'7.4.0.287 (R2007a)')
    problem.x0 = zeros(size(problem.f));
end

% if an arbitrary linear combination is allowed, un-bound the dummy lambda
problem.lb(end) = -inf;
problem.solver = 'quadprog';
problem.options = optimset('Display','off','Algorithm','active-set');
    
% solve the quadratic program
% warning off optim:quadprog:SwitchToMedScale
% warning off

lambda = quadprog( problem );

% check if all the weights are within the intervall [0, 1]
% disp('TO DO: weight restriction ') - done by constraining...

end