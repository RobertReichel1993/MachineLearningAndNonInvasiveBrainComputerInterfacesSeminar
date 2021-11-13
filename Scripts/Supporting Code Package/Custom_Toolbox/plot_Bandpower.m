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
%   channels ...... The names of the EEG channels given in a struct of
%                   strings
%   eloc .......... The location of the EEG electrodes as read from the
%                   eeglab function "readlocs"
%   fs ............ The used sampling frequency
%   patient ....... The name of the current patient
%
%Output:
%   psd_mat ... A matrix filled with the calculated PSD of the data
%               [number of samples] x [number of trials] x [number of channels]
%
%Dependencies: none

function [psd_mat] = plot_Bandpower(data, triggers, classes, classes_idx, ...
    electrodes, times, fs, fname)
    %Splitting into different classes
    data_mat = zeros(((times(2) - times(1)) * fs), length(triggers), ...
        size(data, 2));
    for cnt_labels = 1 : length(triggers)
       data_mat(:, cnt_labels, :) = ...
           data((triggers(cnt_labels) + times(1) * fs : ...
           triggers(cnt_labels) + (times(2) * fs - 1)), :, :);
    end
    
    %Creating data for different trial classes (hand and feet)
    data_class_1 = data_mat(:, classes_idx == classes(1), :);
    data_class_2 = data_mat(:, classes_idx == classes(2), :);
    
    data_class_1 = permute(data_class_1, [3, 1, 2]);
    data_class_2 = permute(data_class_2, [3, 1, 2]);
    
    psd_mat = zeros((fs / 2) + 1, 2, length(electrodes));
    %psd_mat = zeros((fs + 1), 2, length(electrodes));

    %Estimating PSD and visualizing it (Plotting linear)
    fig = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    subplotmask = [2 3 4 5 6 8 9 10 11 12 13 14 16 17 18 20];
    for electrode = 1 : size(data, 2)
        subplot(3, 7, subplotmask(electrode));

        [psd, frange] = estimate_psd(data_class_1(electrode, :, :), ...
            data_class_2(electrode, :, :), fs, 0.5);
        
        psd = 10.^(psd ./ 20);

        psd_mat(:, :, electrode) = psd;
        plot(frange, psd(:, 1), frange,psd(:, 2), 'LineWidth', 2);
        title(electrodes{electrode});
        xlabel('Frequency [Hz]');
        ylabel('Power density');
        xlim([0 40]);
        legend('Class 1','Classe 2', 'Location', 'southoutside', 'Orientation', 'horizontal');
    end
    saveas(fig, strcat(fullfile('../Plots/', fname), '_Linear'), 'jpeg');
    saveas(fig, strcat(fullfile('../Plots/', fname), '_Linear'), 'fig');
    
    %Estimating PSD and visualizing it (Plotting logarithmic)
    fig = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    subplotmask = [2 3 4 5 6 8 9 10 11 12 13 14 16 17 18 20];
    for electrode = 1 : size(data, 2)
        subplot(3, 7, subplotmask(electrode));
        [psd, frange] = estimate_psd(data_class_1(electrode, :, :), ...
            data_class_2(electrode, :, :), fs, 0.5);
        psd_mat(:, :, electrode) = psd;
        plot(frange, psd(:, 1), frange,psd(:, 2), 'LineWidth', 2);
        title(electrodes{electrode});
        xlabel('Frequency [Hz]');
        ylabel('Power density [Db]');
        xlim([0 40]);
        legend('Class 1','Classe 2', 'Location', 'southoutside', 'Orientation', 'horizontal');
    end
    saveas(fig, strcat(fullfile('../Plots/', fname), '_Logarithmic'), 'jpeg');
    saveas(fig, strcat(fullfile('../Plots/', fname), '_Logarithmic'), 'fig');
end