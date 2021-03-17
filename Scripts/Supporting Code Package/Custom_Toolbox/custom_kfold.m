%This function performs k runs of the k-Fold algorithm and calculates the
%mean accuracy over the number of runs. Through the function handle, the
%function used to classify can be interchanged.
%
%Input:
%   data ......................... The data for classification
%                       [number of samples] x [number of features]
%   labels ....................... The targets corresponding to the 
%                                   given samples
%   k ............................ The amount k for the k-Fold Algorithm
%
%   classification_fctn .......... A function handle of the Matlab function
%   which is used to perform the classification and prediction
%
%Output:
%   acc ... The mean accuracy over the k runs of the classification
%
%Dependencies: none

function [acc] = custom_kfold(data, labels, k, classification_fctn)
    acc = zeros(1, k);
    %Creating indices to specify training and validation set for runs
    indices = crossvalind('Kfold', size(data, 1), k);
    for i = 1 : k
        %Split dataset into training and validation set
        valid = data(indices == i, :);
        train = data(indices ~= i, :);
        valid_classes = labels(indices == i);
        train_classes = labels(indices ~= i);
        %Now training LDA and using it for classification
        [acc] = classification_fctn(train, train_classes, valid, ...
            valid_classes);
    end
    %Calculating mean accuracy
    acc = mean(acc);
end