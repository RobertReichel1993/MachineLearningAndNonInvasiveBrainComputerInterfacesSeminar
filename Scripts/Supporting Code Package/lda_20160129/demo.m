% LDA demo script to example the use of lda_train and lda_predict with
% artificial data

% clear all variables
clear all;

av_acc = 0;
for i = 1:100

% Generate example data: 2 classes, 50 dimensional data, 20 training samples per class,
% 2000 test samples
rng('shuffle');
ntrain = 100;
X_train = [randn(ntrain,50)+1+0.1*randn(ntrain,50); randn(ntrain,40)+1+0.1*randn(ntrain,40), randn(ntrain,10)+2+0.1*randn(ntrain,10)];
Y_train = [zeros(ntrain,1); ones(ntrain,1)];
rng('shuffle');
ntest = 1000;
X_tst = [randn(ntest,50)+1+0.1*randn(ntest,50); randn(ntest,40)+1+0.1*randn(ntest,40), randn(ntest,10)+2+0.1*randn(ntest,10)];
Y_tst = [zeros(ntest,1); ones(ntest,1)];

% Calculate linear discriminant coefficients
tic
model_lda = lda_train(X_train,Y_train);
toc
% Predict class membership
tic
[predicted_classes, linear_scores, class_probabilities] = lda_predict(model_lda,X_tst);
toc

% Testing
%X_tst2 = [randn(8,6); randn(8,6) + [3*ones(8,1),zeros(8,6-1)]];  Y_tst2 = [zeros(8,1); ones(8,1)];
%linear_scores2 = [ones(16,1), X_tst2] * model_lda.w';
%linear_scores3 = [ones(16,1), X_tst2] * model_lda.w';

% Calculate classification accuracy
accuracy = 100*sum(predicted_classes==Y_tst)/length(Y_tst);
av_acc = av_acc + accuracy/100;
end
% %% Plot hyperplanes
% 
% figure(1); hold all; scatter(X_train(1:100,1),X_train(1:100,2)); scatter(X_train(101:200,1),X_train(101:200,2));
% figure(2); hold all; scatter(X_tst(1:500,1),X_tst(1:500,2)); scatter(X_tst(501:1000,1),X_tst(501:1000,2));
% figure(3); hold all; scatter(X_tst(predicted_classes==0,1),X_tst(predicted_classes==0,2)); scatter(X_tst(predicted_classes==1,1),X_tst(predicted_classes==1,2));
% 
% x=(1:0.001:2);
% y=(model_lda.w(2,1)-model_lda.w(1,1)+model_lda.w(2,2)*x-model_lda.w(1,2)*x)/(model_lda.w(1,3)-model_lda.w(2,3));
% 
% scatter(x,y);
% 
% % Distance from hyperplane
% lin_diff = linear_scores(:,1)-linear_scores(:,2);
% tmp = sign(lin_diff);
% tmp(tmp>0)=1;
% tmp(tmp<0)=0;
% tmp2=sum(tmp~=Y_tst);