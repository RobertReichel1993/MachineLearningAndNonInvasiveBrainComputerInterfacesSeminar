%This function creates plots of the bandpower of the signals given in data
%
%Input:
%   data .......... The given data with the dimensions:
%                   [# of datapoints] x [# of channels]
%   triggers ...... The starting indices of all trials in the experiment
%   classes ....... An array indicating all possible classes in
%                   classes_idx
%   classes_idx ... An array indicating the corrseponding class for each
%                   trial indicated by triggers
%   electrodes .... The names of the EEG channels given in a struct of
%                   strings
%   times ......... The time window in which the MRCP is theorized to
%                   happen
%   fs ............ The used sampling frequency
%   figtitle ...... The title under which the created figures are supposed
%                   to be saved, once as .jpeg and once as .fig file
%
%Output:
%   stuff ... Currently not needed, included for debugging purposes
%
%Dependencies: none

function [data] = plot_MRCP(data, triggers, classes, classes_idx, ...
    electrodes, times, fs, figtitle)

    time = times(1) : 1/fs : times(2)-1/fs;
    
    %Splitting into different classes
    data_mat = zeros(((times(2) - times(1)) * fs), length(triggers), ...
        size(data, 2));
    for cnt_labels = 1 : length(triggers)
       data_mat(:, cnt_labels, :) = ...
           data((triggers(cnt_labels) + times(1) * fs : ...
           triggers(cnt_labels) + (times(2) * fs - 1)), :, :);
    end
    
    %Creating data for different trial classes (hand and feet)
    data_class_1 = mean(data_mat(:, classes_idx == classes(1), :), 2);
    data_class_2 = mean(data_mat(:, classes_idx == classes(2), :), 2);
    %Calculating Standard error of mean
    sem_c1 = squeeze(std(data_mat(:, classes_idx == classes(1), :), 0, 2) ...
        ./ sqrt(size(data, 2)));
    sem_c2 = squeeze(std(data_mat(:, classes_idx == classes(2), :), 0, 2) ...
        ./ sqrt(size(data, 2)));
    
    %Plotting everything
    subplotmask = [2 3 4 5 6 8 9 10 11 12 13 14 16 17 18 20];
    fig = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    for electrode = 1 : size(data, 2)
        subplot(3, 7, subplotmask(electrode));
        plot(time, data_class_1(:, : , 1), 'LineWidth', 1.2, 'Color', 'k');
        hold on
        plot(time, data_class_1(:, : , 1) + sem_c1(:, 1), 'Color', [0.6 0.8 0.9]);
        plot(time, data_class_1(:, : , 1) - sem_c1(:, 1), 'Color', [0.6 0.8 0.9]);
        hold off
        xlabel('Time / s');
        ylabel('Potential / µV');
        title(strcat('MRCP for hand movement on ', electrodes{1}));
    end
    saveas(fig, fullfile('../Plots/', strcat(figtitle, ' Class 1')), 'jpeg');
    saveas(fig, fullfile('../Plots/', strcat(figtitle, ' Class 1')), 'fig');
    
    fig = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    for electrode = 1 : size(data, 2)
        subplot(3, 7, subplotmask(electrode));
        plot(time, data_class_2(:, : , 1), 'LineWidth', 1.2, 'Color', 'k');
        hold on
        plot(time, data_class_2(:, : , 1) + sem_c1(:, 1), 'Color', [0.6 0.8 0.9]);
        plot(time, data_class_2(:, : , 1) - sem_c1(:, 1), 'Color', [0.6 0.8 0.9]);
        hold off
        xlabel('Time / s');
        ylabel('Potential / µV');
        title(strcat('MRCP for foot movement on ', electrodes{1}));
    end
    saveas(fig, fullfile('../Plots/', strcat(figtitle, ' Class 2')), 'jpeg');
    saveas(fig, fullfile('../Plots/', strcat(figtitle, ' Class 2')), 'fig');
    
    fig = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    for electrode = 1 : size(data, 2)
        subplot(3, 7, subplotmask(electrode));
        plot(time, data_class_1(:, : , 1), 'LineWidth', 1.2, 'Color', 'b');
        hold on
        plot(time, data_class_1(:, : , 1) + sem_c1(:, 1), 'Color', [0.5843 0.8157 0.9882]);
        plot(time, data_class_1(:, : , 1) - sem_c1(:, 1), 'Color', [0.5843 0.8157 0.9882]);
        plot(time, data_class_2(:, : , 1), 'LineWidth', 1.2, 'Color', 'r');
        plot(time, data_class_2(:, : , 1) + sem_c1(:, 1), 'Color', [1 0.5 0.5]);
        plot(time, data_class_2(:, : , 1) - sem_c1(:, 1), 'Color', [1 0.5 0.5]);
        hold off
        xlabel('Time / s');
        ylabel('Potential / µV');
        title(strcat('MRCP for hand and foot movement on ', electrodes{1}));
    end
    text = "Blue ... Mean MRCP Hand movement" + newline + newline + ...
        "Light blue ... Standard error of Mean MRCP Hand movement" + newline + newline + ...
        "Red ... Standard error of Mean MRCP Foot movement" + newline + newline + ...
        "Light red ... Standard error of Mean MRCP Foot movement";
    annotation('textbox', [0 .5 .1 .2], 'String', text, 'EdgeColor', 'none')
    saveas(fig, fullfile('../Plots/', strcat(figtitle, ' Two Classes')), 'jpeg');
    saveas(fig, fullfile('../Plots/', strcat(figtitle, ' Two Classes')), 'fig');

end