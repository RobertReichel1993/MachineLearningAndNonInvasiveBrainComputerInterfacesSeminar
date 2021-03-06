%This function reads in a gdf file and saves it as an .mat file and returns
%the data itself and, if the data is single precission, it automatically is
%converted into double precission values
%
%Input:
%   filename ... The name of the input file
%   path ....... The path to the gdf files
%
%Output:
%   data ... A struct containing all information from the gdf file
%
%Dependencies: eeglab toolbox
%
%Remarks:
%EEG.data -> data from channels
%EEG.times -> timepoints
%EEG.srate -> sample rate
%EEG.nbchan -> number of channels with names, locations, etc.
%EEG.chanlocs -> Channel locations
%EEG.event -> events (60, 61) for hand and foot and add. info


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
    fig = figure();
    subplot(3, 7, 2);
    plot(time, data_class_1(:, : , 1), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_1(:, : , 1) + sem_c1(:, 1), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_1(:, : , 1) - sem_c1(:, 1), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{1}));
    subplot(3, 7, 3);
    plot(time, data_class_1(:, : , 2), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_1(:, : , 2) + sem_c1(:, 2), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_1(:, : , 2) - sem_c1(:, 2), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{2}));
    subplot(3, 7, 4);
    plot(time, data_class_1(:, : , 3), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_1(:, : , 3) + sem_c1(:, 3), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_1(:, : , 3) - sem_c1(:, 3), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{3}));
    subplot(3, 7, 5);
    plot(time, data_class_1(:, : , 4), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_1(:, : , 4) + sem_c1(:, 4), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_1(:, : , 4) - sem_c1(:, 4), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{4}));
    subplot(3, 7, 6);
    plot(time, data_class_1(:, : , 5), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_1(:, : , 5) + sem_c1(:, 5), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_1(:, : , 5) - sem_c1(:, 5), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{5}));
    subplot(3, 7, 8);
    plot(time, data_class_1(:, : , 6), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_1(:, : , 6) + sem_c1(:, 6), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_1(:, : , 6) - sem_c1(:, 6), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{6}));
    subplot(3, 7, 9);
    plot(time, data_class_1(:, : , 7), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_1(:, : , 7) + sem_c1(:, 7), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_1(:, : , 7) - sem_c1(:, 7), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{7}));
    subplot(3, 7, 10);
    plot(time, data_class_1(:, : , 8), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_1(:, : , 8) + sem_c1(:, 8), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_1(:, : , 8) - sem_c1(:, 8), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{8}));
    subplot(3, 7, 11);
    plot(time, data_class_1(:, : , 9), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_1(:, : , 9) + sem_c1(:, 9), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_1(:, : , 9) - sem_c1(:, 9), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{9}));
    subplot(3, 7, 12);
    plot(time, data_class_1(:, : , 10), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_1(:, : , 10) + sem_c1(:, 10), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_1(:, : , 10) - sem_c1(:, 10), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{10}));
    subplot(3, 7, 13);
    plot(time, data_class_1(:, : , 11), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_1(:, : , 11) + sem_c1(:, 11), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_1(:, : , 11) - sem_c1(:, 11), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{11}));
    subplot(3, 7, 14);
    plot(time, data_class_1(:, : , 12), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_1(:, : , 12) + sem_c1(:, 12), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_1(:, : , 12) - sem_c1(:, 12), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{12}));
    subplot(3, 7, 16);
    plot(time, data_class_1(:, : , 13), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_1(:, : , 13) + sem_c1(:, 13), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_1(:, : , 13) - sem_c1(:, 13), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{13}));
    subplot(3, 7, 17);
    plot(time, data_class_1(:, : , 14), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_1(:, : , 14) + sem_c1(:, 14), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_1(:, : , 14) - sem_c1(:, 14), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{14}));
    subplot(3, 7, 18);
    plot(time, data_class_1(:, : , 15), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_1(:, : , 15) + sem_c1(:, 15), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_1(:, : , 15) - sem_c1(:, 15), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{15}));
    subplot(3, 7, 20);
    plot(time, data_class_1(:, : , 16), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_1(:, : , 16) + sem_c1(:, 16), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_1(:, : , 16) - sem_c1(:, 16), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{16}));
    saveas(fig, fullfile('../Plots/', strcat(figtitle, ' Class 1')), 'jpeg');
    saveas(fig, fullfile('../Plots/', strcat(figtitle, ' Class 1')), 'fig');
    
    
    
    fig = figure();
    subplot(3, 7, 2);
    plot(time, data_class_2(:, : , 1), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_2(:, : , 1) + sem_c2(:, 1), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_2(:, : , 1) - sem_c2(:, 1), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{1}));
    subplot(3, 7, 3);
    plot(time, data_class_2(:, : , 1), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_2(:, : , 2) + sem_c2(:, 2), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_2(:, : , 2) - sem_c2(:, 2), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{2}));
    subplot(3, 7, 4);
    plot(time, data_class_2(:, : , 3), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_2(:, : , 3) + sem_c2(:, 3), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_2(:, : , 3) - sem_c2(:, 3), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{3}));
    subplot(3, 7, 5);
    plot(time, data_class_2(:, : , 4), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_2(:, : , 4) + sem_c2(:, 4), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_2(:, : , 4) - sem_c2(:, 4), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{4}));
    subplot(3, 7, 6);
    plot(time, data_class_2(:, : , 5), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_2(:, : , 5) + sem_c2(:, 5), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_2(:, : , 5) - sem_c2(:, 5), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{5}));
    subplot(3, 7, 8);
    plot(time, data_class_2(:, : , 6), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_2(:, : , 6) + sem_c2(:, 6), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_2(:, : , 6) - sem_c2(:, 6), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{6}));
    subplot(3, 7, 9);
    plot(time, data_class_2(:, : , 7), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_2(:, : , 7) + sem_c2(:, 7), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_2(:, : , 7) - sem_c2(:, 7), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{7}));
    subplot(3, 7, 10);
    plot(time, data_class_2(:, : , 8), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_2(:, : , 8) + sem_c2(:, 8), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_2(:, : , 8) - sem_c2(:, 8), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{8}));
    subplot(3, 7, 11);
    plot(time, data_class_2(:, : , 9), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_2(:, : , 9) + sem_c2(:, 9), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_2(:, : , 9) - sem_c2(:, 9), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{9}));
    subplot(3, 7, 12);
    plot(time, data_class_2(:, : , 10), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_2(:, : , 10) + sem_c2(:, 10), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_2(:, : , 10) - sem_c2(:, 10), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{10}));
    subplot(3, 7, 13);
    plot(time, data_class_2(:, : , 11), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_2(:, : , 11) + sem_c2(:, 11), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_2(:, : , 11) - sem_c2(:, 11), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{11}));
    subplot(3, 7, 14);
    plot(time, data_class_2(:, : , 12), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_2(:, : , 12) + sem_c2(:, 12), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_2(:, : , 12) - sem_c2(:, 12), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{12}));
    subplot(3, 7, 16);
    plot(time, data_class_2(:, : , 13), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_2(:, : , 13) + sem_c2(:, 13), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_2(:, : , 13) - sem_c2(:, 13), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{13}));
    subplot(3, 7, 17);
    plot(time, data_class_2(:, : , 14), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_2(:, : , 14) + sem_c2(:, 14), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_2(:, : , 14) - sem_c2(:, 14), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{14}));
    subplot(3, 7, 18);
    plot(time, data_class_2(:, : , 15), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_2(:, : , 15) + sem_c2(:, 15), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_2(:, : , 15) - sem_c2(:, 15), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{15}));
    subplot(3, 7, 20);
    plot(time, data_class_2(:, : , 16), 'LineWidth', 1.2, 'Color', 'k');
    hold on
    plot(time, data_class_2(:, : , 16) + sem_c2(:, 16), 'Color', [0.6 0.8 0.9]);
    plot(time, data_class_2(:, : , 16) - sem_c2(:, 16), 'Color', [0.6 0.8 0.9]);
    hold off
    xlabel('Time / s');
    ylabel('Potential / µV');
    title(strcat('MRCP for hand movement on ', electrodes{16}));
    saveas(fig, fullfile('../Plots/', strcat(figtitle, ' Class 2')), 'jpeg');
    saveas(fig, fullfile('../Plots/', strcat(figtitle, ' Class 2')), 'fig');
end