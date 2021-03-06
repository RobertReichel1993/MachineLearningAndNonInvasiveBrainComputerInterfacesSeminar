%This function estimates the Power Spectral Density (PSD) of the given
%input signals and then visualizes the PSD over the frequency range to
%compare between two classes for a two class classification problem.
%
%Input:
%   data_hand .......... The data for the first class
%                       [number of channels] x [number of datapoints per trial] x [number of trials in class 1]
%   data_feet .......... The data for the second class
%                       [number of channels] x [number of datapoints per trial] x [number of trials in class 2]
%   names .............. The names of the channels at which the data is
%                        recorded
%   fs ................. The sampling frequency of the signals
%   overlap ............ The overlap in window length for PSD calculation
%   in percent (0 to 1)
%   title .............. The title as which the figure should be saved
%
%Output:
%   psd ... The calculated power spectral density across the frequency
%           range from 0 to fs/2 averaged across the trials.
%           The output has the dimention:
%           [number of frequency components] x [number of classes] x [number of channels]
%
%Dependencies: none

function [psd, frange] = estimate_psd(data_hand, data_feet, names, fs, overlap, fname)
    %Checking if both classes have same amount of trials
    size_1 = size(data_hand);
    size_2 = size(data_feet);
    %If not, just take the lower number of trials to prevent errors
    if length(size(data_hand)) == 3
        if size_1(3) > size_2(3)
            size_1(3) = size_2(3);
        elseif size_2(3) > size_1(3)
            size_2(3) = size_1(3);
        end
    elseif length(size(data_hand)) == 2
        if size_1(2) > size_2(2)
            size_1(2) = size_2(2);
        elseif size_2(2) > size_1(2)
            size_2(2) = size_1(2);
        end
    end

    frange = linspace(0, fs/2, ceil((fs+1) * overlap))'; % the x axis for the PSD plot
    if length(size_1) == 2 % if we're using concatenated data from all trials 
        %psd = zeros(fs+1, 2, size_1(1)); % preallocation of psd
        psd = zeros(ceil((fs+1) * overlap), 2, size_1(1)); % preallocation of psd
        
        for i = 1:size_1(2)
            data = [data_hand(:,i) data_feet(:,i)];
            psd(:,:,i) = pwelch(data, fs, ceil(fs * overlap));
        end
        % 128 is window width (==fs) and 64 means 50% overlap

        psd = 20*log10(psd); %log transformation into [Db]
        
    else % if we're using trial-by-trial data and then calculating the mean
        %psd = zeros(fs+1, 2, size_1(1), size_1(3)); % preallocation of psd
        psd = zeros(ceil((fs+1) * overlap), 2, size_1(1), size_1(3)); % preallocation of psd

        for i = 1:size_1(1)
            for j = 1:size_1(3)
                psd(:,:,i,j) = pwelch([data_hand(i,:,j); data_feet(i,:,j)]', fs, ceil(fs * overlap));
            end
        end

        psd = 20*log10(mean(psd,4)); %log transformation of the mean into [Db]
    end  
    %Creating figure, otherwise we overwrite old plots!
%     fig = figure();
%     for j = 1 : size(data_hand, 1)
%          subplot(1,size(data_hand, 1),j) % plotting the data
%          plot(frange,psd(:,1,j),...
%               frange,psd(:,2,j),'LineWidth',2);
%          title(names{j});
%          xlabel('Frequency [Hz]');
%          ylabel('Power density [Db]');
%          legend('Class 1','Classe 2');
%     end
%     saveas(fig, fname, 'jpeg');
end