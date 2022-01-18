%This function calculates features for classification by calculating the
%PSD for the different trials and classes.
%
%Input:
%   data ........... The given data with the dimensions:
%                    [# of datapoints] x [# of channels]
%   triggers ....... The starting indices of all trials in the experiment
%   classes ........ An array indicating the possible classes
%   classes_idx ........ An array indicating the corrseponding class for each
%                    trial indicated by triggers
%   window_erds .... The time window in which the ERDS is theorized to
%                    happen
%   fs ............. The used sampling frequency
%   num_filters .... Number of selected CSP filters in total (e.g. 2
%                    filters means biggest and smallest Eigenvalue)
%
%Output:
%   features_class_1 ... Features for the frequency domain for class 1
%                        [number of features] x [number of trials] x [number of channels]
%   features_class_2 ... Features for the frequency domain for class 2
%                        [number of features] x [number of trials] x [number of channels]
%
%Dependencies: none

function [accuracy, bands, csps] = csp_analysis(data, ...
    triggers, classes, classes_idx, window_erds, fs, num_filters, num_bands, ...
    frange, rep_factor, k)
    
    %Calculating CSP-filtered frequency features (Bandpower)
    [features_class_1, features_class_2, freq_bands] = csp_filterbank(data, ...
    triggers, classes, classes_idx, window_erds, fs, num_filters, num_bands, ...
    frange);
    
    %Splitting trials into training and testing set
    if size(features_class_1, 1) < size(features_class_2, 1)
        train = floor(size(features_class_2, 1) * 2/3);
    else
        train = floor(size(features_class_1, 1) * 2/3);
    end
    
    %Creating training features and targets
    X_train = vertcat(features_class_1(1 : train, :, :), ...
        features_class_2(1 : train, :, :));
    Y_train = [ones(train, 1); 2 * ones(train, 1)];
    %Creating testing features and targets
    X_test = vertcat(features_class_1(train + 1 : end, :, :), ...
        features_class_2(train + 1 : end, :, :));               
    Y_test = [ones(size(features_class_1, 1) - train, 1); ...
        2 * ones(size(features_class_2, 1) - train, 1)];
    %% Training
    %Preallocating storage space for accuracies
    acc_mat = zeros(num_bands, rep_factor);
    %Looping over frequency bands
    for band = 1 : num_bands
        %Doing the k-fold 10 times as per requirement
        for cnt = 1 : rep_factor
            %Doing 5-fold classification on the training data with shrinkage LDA
            acc_mat(band, cnt) = custom_kfold(squeeze(X_train(:, :, band))', ...
                Y_train, k, @custom_shrinkage_LDA);
        end
    end
    %Getting maximum of mean over columns (over repetitions)
    %Take two best bands!
    %The dimensions match here!
    %But there are Nans and shit in the acc_mat!!
    [~, inx] = sort(mean(acc_mat, 2), 'descend');
    
    X_tr_final = [X_train(:, :, inx(1)) X_train(:, :, inx(2))];
    X_te_final =  [X_test(:, :, inx(1)) X_test(:, :, inx(2))];

    %Now we only need to train a classifier using the whole training data of
    %the best frequency band and evaluate on the test set
    model_lda = lda_train(X_tr_final, Y_train);
    % Predict class membership
    [predicted_classes, ~, ~] = lda_predict(model_lda, X_te_final);

    % Calculate classification accuracy
    accuracy = 100 * sum(predicted_classes == Y_test) / length(Y_test);
    %Getting the two best performing frequency bands
    best_band = inx(1:2);
    best_band
    %Finding the frequency range of the bands and calculating the corner
    %frequencies
    band1 = freq_bands(best_band(1) : best_band(1) + 1);% ./ (fs/2);
    band2 = freq_bands(best_band(2) : best_band(2) + 1);% ./ (fs/2);
    band1
    band2
    %Calculating CSP weights (Check if they are right!!!!)
    csp_mat_low = csp_train(squeeze(features_class_1(:, :, best_band(1), :)), ...
            squeeze(features_class_2(:, :, best_band(1), :)), 'shrinkage', 0.2);
    csp_mat_high = csp_train(squeeze(features_class_1(:, :, best_band(2), :)), ...
        squeeze(features_class_2(:, :, best_band(2), :)), 'shrinkage', 0.2);
    
    csp_mat_low
    csp_mat_high

    bands = [band1 band2];
    csps = cat(3, csp_mat_low, csp_mat_high);
end