%This function performs shrinkage LDA from the Supporting Code package to
%train a classifier and then tests the classifier on a validation set
%
%Input:
%   X_train ..... The training data
%                 [number of samples] x [number of features]
%   Y_train ..... The training targets
%   X_test ..... The testing or validation data
%                 [number of samples] x [number of features]
%   Y_test ..... The training or validation targets
%
%Output:
%   acc ... The accuracy of the LDA classifier on the validation set
%
%Dependencies: lda_train, lda_predict

function [acc] = custom_shrinkage_LDA(X_train, Y_train, X_test, Y_test)
    %Training lda with features and targets
    model_lda = lda_train(X_train, Y_train);
    %Predicting based on new features
    [predicted_classes, ~, ~] = lda_predict(model_lda, X_test);
    %Stealing prediction scores from demo because I am a cheeky mfer
    acc = 100 * sum(predicted_classes == Y_test) / length(Y_test);
end