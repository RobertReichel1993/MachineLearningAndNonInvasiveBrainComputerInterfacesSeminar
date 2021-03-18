%This function is just for making the main code prettier. It takes the data
%for both classes, permutes it to the right dimensionality and performs
%repeated k-dolfing for estimating the performance of the shrinkage LDA.S
%
%Input:
%   features_class_1 ... The features of class 1 of the data
%                   [# of datapoints] x [# of trials] x [# of channels]
%   features_class_2 ... The features of class 2 of the data
%                   [# of datapoints] x [# of trials] x [# of channels]
%   rep_fac ............ The factor by which the k-folding should be
%                   repeated
%   kfold_factor ....... The factor k for k-folding
%
%Output:
%   acc ... The mean accuracy of the classification over all runs
%
%Dependencies: lda_20160129 from the supporting code package

function [acc] = permute_and_kfold(features_class_1, features_class_2, ...
    rep_fac, kfold_factor)
    %Reshaping to use already existing classification methods
    tmp = permute([features_class_1 features_class_2], [2 3 1]);
    features = reshape(tmp, [], size(tmp, 1), 1);
    labels = [ones(size(features_class_1, 2), 1) * 60; ...
        ones(size(features_class_2, 2), 1) * 61];
    %Performing k-fold Classification with sLDA
    acc = zeros(rep_fac, 1);
    for rep = 1 : rep_fac
        [tmp] = custom_kfold(features', labels, kfold_factor, @custom_shrinkage_LDA);
        acc(rep) = tmp;
    end
end