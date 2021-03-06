clear all
close all
addpath(genpath('eeglab14_1_1b'));
%need to start eeglab first to add paths

patient = 'AC22';

files = [];
all_files = dir('../Data/rec');
for i=1:length(all_files)
  if contains(all_files(i).name, patient)
      files = [files, convertCharsToStrings(all_files(i).name)];
  end
end

path = 'C:/Users/Robert/Desktop/Studium/Master/WS_2020_2021/MachineLearningAndNIVBCISeminar/rec/';
path1 = char(strcat(path,files(1)));
path2 = char(strcat(path,files(2)));
path3 = char(strcat(path,files(3)));
path4 = char(strcat(path,files(4)));
path5 = char(strcat(path,files(5)));
path6 = char(strcat(path,files(6)));
path7 = char(strcat(path,files(7)));
path8 = char(strcat(path,files(8)));
Classlabels = ["Foot", "Hand"];
events = [60, 61]; %60=foot 61=hand
e = 2;            %if foot->1, if hand->2
sample_shift = 3600;
freq = zeros(3,2);
freq(1,1) = 0.3;  %general filter
freq(1,2) = 80;   %general filter
freq(2,1) = 0.3;  %filter for mrcp 
freq(2,2) = 3;    %filter for mrcp
freq(3,1) = 5;    %cutoff freq for erds plot
freq(3,2) = 40;   %cutoff freq for erds plot
filt_ord = 4;     %filter order
data_window = [-5 4.1];
erds_window = [-5.0 0.2 4.0];
ref_window = [-4.5 -3.6];
mov_window1 = [0.3 1.2];
mov_window2 = [1.2 2.1];
mov_window3 = [2.1 3.0];
kurt = 3;
prob = 3;
allchanlimit = 5;
thresh = 100;
chan_man = [];%["FC4","C5","C6"]; %channel names which should be rejected manually

t1=ref_window(1)+5;
t2=ref_window(2)+5;
t3=mov_window1(1)+5;
t4=mov_window1(2)+5;
t5=mov_window2(1)+5;
t6=mov_window2(2)+5;
t7=mov_window3(1)+5;
t8=mov_window3(2)+5;

channum_list = [0,1,2,3,4,5,0,6,7,8,9,10,11,12,0,0,13,14,15,0,0,0,0,0,16,0,0,0];
%% import gdf files
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_biosig(path1);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname','AC21_1','gui','off'); 
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = pop_biosig(path2);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname','AC21_2','gui','off'); 
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = pop_biosig(path3);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname','AC21_3','gui','off'); 
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = pop_biosig(path4);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname','AC21_4','gui','off'); 
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
EEG = pop_biosig(path5);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'setname','AC21_5','gui','off'); 
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
EEG = pop_biosig(path6);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 5,'setname','AC21_6','gui','off'); 
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
EEG = pop_biosig(path7);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 6,'setname','AC21_7','gui','off'); 
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
EEG = pop_biosig(path8);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 7,'setname','AC21_8','gui','off'); 
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );

%% merge
EEG = pop_mergeset( ALLEEG, [1  2  3  4  5  6 7 8], 0);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'setname','AC12 Merged','gui','off'); 
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );

%% sample shift foot and hand
[EEG,com] = pop_adjustevents(EEG, 'addms',sample_shift,'eventtypes',int2str(events(1)));
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
[EEG,com] = pop_adjustevents(EEG, 'addms',sample_shift,'eventtypes',int2str(events(2)));
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);

%% create channel location file
%EEG=pop_chanedit(EEG, 'lookup', 'C:/Users/Robert/Desktop/Studium/Master/WS_2020_2021/MachineLearningAndNIVBCISeminar/info/standard-10-5-cap385.elp');
%[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
%[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);


%After this we could save it normally and drop the toolbox shit


%% bandpass filter
%EEG = pop_eegfiltnew(EEG, 'locutoff',freq(1,1),'hicutoff',freq(1,2),'plotfreqz',0);
%[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 5,'setname','AC12 Filter 03_70','gui','off'); 
%[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
%EEG = eeg_checkset( EEG );

% h  = fdesign.bandpass('N,F3dB1,F3dB2', filt_ord, freq(1,1), freq(1,2), EEG.srate);
% Hd = design(h, 'butter');%, 'SOSScaleNorm','linf');
% EEG.data = filtfilt(Hd.SoSMatrix,Hd.ScaleValues,double(EEG.data));
% EEG = eeg_checkset( EEG );

%% extract epochs
EEG = pop_epoch( EEG, {  int2str(events(e))  }, data_window, 'newname', 'AC12 Filter 03_70 epochs', 'epochinfo', 'yes');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 6,'gui','off'); 
EEG = eeg_checkset( EEG );

%% remove baseline: comment out if not needed
EEG = pop_rmbase( EEG, [] ,[]);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 7,'setname','AC12 Filter 03_70 epochs_br','gui','off');
EEG = eeg_checkset( EEG );

%% artifact trials marked
EEG = pop_eegthresh(EEG,1,[1:16] ,-thresh,thresh,data_window(1),data_window(2),2,0);
EEG = pop_jointprob(EEG,1,[1:16] ,prob,allchanlimit,0,0,0,[],0);
EEG = pop_jointprob(EEG,1,[1:16] ,prob,allchanlimit,0,0,'set(findobj(''parent'', findobj(''tag'', ''rejtrialraw''), ''tag'', ''mantrial''), ''string'', num2str(sum(EEG.reject.rejmanual)));set(findobj(''parent'', findobj(''tag'', ''rejtrialraw''), ''tag'', ''threshtrial''), ''string'', num2str(sum(EEG.reject.rejthresh)));set(findobj(''parent'', findobj(''tag'', ''rejtrialraw''), ''tag'', ''freqtrial''), ''string'', num2str(sum(EEG.reject.rejfreq)));set(findobj(''parent'', findobj(''tag'', ''rejtrialraw''), ''tag'', ''consttrial''), ''string'', num2str(sum(EEG.reject.rejconst)));set(findobj(''parent'', findobj(''tag'', ''rejtrialraw''), ''tag'', ''enttrial''), ''string'', num2str(sum(EEG.reject.rejjp)));set(findobj(''parent'', findobj(''tag'', ''rejtrialraw''), ''tag'', ''kurttrial''), ''string'', num2str(sum(EEG.reject.rejkurt)));',[],0);
EEG = pop_rejkurt(EEG,1,[1:16] ,kurt,allchanlimit,0,0,0,[],0);
EEG = pop_rejkurt(EEG,1,[1:16] ,kurt,allchanlimit,0,0,'set(findobj(''parent'', findobj(''tag'', ''rejtrialraw''), ''tag'', ''mantrial''), ''string'', num2str(sum(EEG.reject.rejmanual)));set(findobj(''parent'', findobj(''tag'', ''rejtrialraw''), ''tag'', ''threshtrial''), ''string'', num2str(sum(EEG.reject.rejthresh)));set(findobj(''parent'', findobj(''tag'', ''rejtrialraw''), ''tag'', ''freqtrial''), ''string'', num2str(sum(EEG.reject.rejfreq)));set(findobj(''parent'', findobj(''tag'', ''rejtrialraw''), ''tag'', ''consttrial''), ''string'', num2str(sum(EEG.reject.rejconst)));set(findobj(''parent'', findobj(''tag'', ''rejtrialraw''), ''tag'', ''enttrial''), ''string'', num2str(sum(EEG.reject.rejjp)));set(findobj(''parent'', findobj(''tag'', ''rejtrialraw''), ''tag'', ''kurttrial''), ''string'', num2str(sum(EEG.reject.rejkurt)));',[],0);

%% save dataset for later use
EEG2 = EEG;

%% reject Artifacts
EEG = eeg_rejsuperpose( EEG, 1, 1, 1, 1, 1, 1, 1, 1);
rejtrials = find(EEG.reject.rejglobal);
EEG = pop_rejepoch( EEG, rejtrials ,0);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 10,'gui','off'); 
EEG = eeg_checkset( EEG );

%% CAR
% EEG = pop_reref( EEG, []);
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 9,'gui','off'); 
% EEG = eeg_checkset( EEG );
car_data = zeros(size(EEG.data));
for i=1:16 car_data(i,:,:) = EEG.data(i,:,:)-mean(EEG.data,1); end
EEG.data = car_data;

% %% reject Channel automaticly
% EEG = pop_rejchan(EEG, 'elec',[1:EEG.nbchan] ,'threshold',kurt,'norm','on','measure','kurt');
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 10,'gui','off'); 
% EEG = eeg_checkset( EEG );
% 
%% reject Channel manually
for i=1:length(chan_man)
    EEG = pop_select( EEG, 'nochannel',{convertStringsToChars(chan_man(i))});
end
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 12,'setname','AC12 14chan','gui','off'); 
EEG = eeg_checkset( EEG );



%Works untill here, so we could resave the data here and work with it as
%usual



%% create parameters for plotting
channels = [];
for i=1:length(EEG.chanlocs)
    channels = [channels, convertCharsToStrings(EEG.chanlocs(i).labels)];
end

channums = zeros(EEG.nbchan,1);
for i=1:length(EEG.chanlocs)
    channums(i) = EEG.chanlocs(i).urchan;
end

for i=1:length(channum_list)
    if not(ismember(channum_list(i),channums))
        channum_list(i) = 0;
    end
end
chan_log = logical(channum_list);
%% plot ERDS Map

info.SampleRate = EEG.srate;
info.TRIG = [];
for i=1:length(EEG.event)
    if str2double(EEG.event(i).type) == events(e)
        info.TRIG = [info.TRIG, round(EEG.event(i).latency)];
    end
end
Classlabel = Classlabels(e);
info.Classlabel = repelem(Classlabel, length(info.TRIG));
% 
% montage_mat = reshape(chan_log, [7,4]);
% montage_mat = montage_mat';
% 
% cont_len = size(EEG.data,2)*size(EEG.data,3);
% 
% data = double(reshape(EEG.data, [EEG.nbchan,cont_len]))';
% r_foot = calcErdsMap(data,info,erds_window,[freq(3,1) freq(3,2)],'ref',ref_window,'alpha',0.95,'montage',montage_mat);
% plotErdsMap(r_foot,channels);
% 
% % pdfplot
% print(char(strcat("ERD_ERS_", Classlabels(e),".pdf")),'-dpdf','-fillpage');
% 
% %% plot Power Spectrum
% samples1 = t1*EEG.srate;
% samples2 = t2*EEG.srate;
% samples3 = t3*EEG.srate;
% samples4 = t4*EEG.srate;
% samples5 = t5*EEG.srate;
% samples6 = t6*EEG.srate;
% samples7 = t7*EEG.srate;
% samples8 = t8*EEG.srate;
% 
% ind = 0;
% figure()
% for i=1:length(channum_list)
%     subplot(4,7,i)
%     if chan_log(i) == true
%         ind = ind+1;
%         [spectramov1, freqmov1] = spectopo(EEG.data(ind,samples3:samples4,:),0,EEG.srate,'winsize',256,'overlap',20,'plot','off');
%         [spectramov2, freqmov2] = spectopo(EEG.data(ind,samples5:samples6,:),0,EEG.srate,'winsize',256,'overlap',20,'plot','off');
% 		[spectramov3, freqmov3] = spectopo(EEG.data(ind,samples7:samples8,:),0,EEG.srate,'winsize',256,'overlap',20,'plot','off');
%         [spectraref, freqref] = spectopo(EEG.data(ind,samples1:samples2,:),0,EEG.srate,'winsize',256,'overlap',20,'plot','off');
%         hold on
%         plot(freqmov1, spectramov1, 'g')
%         plot(freqmov2, spectramov2, 'b')
% 		plot(freqmov3, spectramov3, 'c')
%         plot(freqref, spectraref, 'r')
%         xlabel('frequency in Hz')
%         ylabel('power spectral density in dB')
%         xlim([0 40])
%         ylim([-20 10])
%         legend('move1','move2','move3','ref','Location','northeast')
%         hold off
%         set(gca,'FontSize',6);
%         title(EEG.chanlocs(ind).labels,'FontSize',8);
%     else
%         axis off
%     end
% end
% % text_title = strcat("Power Spectrum", Classlabels(e));
% % g = suptitle(text_title);
% set(gcf, 'Position', get(0, 'Screensize'));
% 
% % pdfplot
% orient('landscape')
% print(char(strcat("Power_Spectrum_", Classlabels(e),".pdf")),'-dpdf','-fillpage');
%% plot MRCP
% bandpass filter
EEG2 = pop_eegfiltnew(EEG2, 'locutoff',freq(2,1),'hicutoff',freq(2,2),'plotfreqz',0);
[ALLEEG EEG2 CURRENTSET] = pop_newset(ALLEEG, EEG2, 8,'gui','off'); 
EEG2 = eeg_checkset( EEG2 );

% reject Artifacts
EEG2 = eeg_rejsuperpose( EEG2, 1, 1, 1, 1, 1, 1, 1, 1);
rejtrials = find(EEG2.reject.rejglobal);
EEG2 = pop_rejepoch( EEG2, rejtrials ,0);
[ALLEEG EEG2 CURRENTSET] = pop_newset(ALLEEG, EEG2, 10,'gui','off'); 
EEG2 = eeg_checkset( EEG2 );

% CAR
% EEG2 = pop_reref( EEG2, []);
% [ALLEEG EEG2 CURRENTSET] = pop_newset(ALLEEG, EEG2, 9,'gui','off'); 
% EEG2 = eeg_checkset( EEG2 );
car_data2 = zeros(size(EEG2.data));
for i=1:16 
    car_data2(i,:,:) = EEG2.data(i,:,:)-mean(EEG2.data,1); 
end
EEG2.data = car_data2;

% % reject Channel automaticly
% EEG2 = pop_rejchan(EEG2, 'elec',[1:EEG2.nbchan] ,'threshold',kurt,'norm','on','measure','kurt');
% [ALLEEG EEG2 CURRENTSET] = pop_newset(ALLEEG, EEG2, 10,'gui','off'); 
% EEG2 = eeg_checkset( EEG2 );

% reject Channel manually
for i=1:length(chan_man)
    EEG2 = pop_select( EEG2, 'nochannel',{convertStringsToChars(chan_man(i))});
end
[ALLEEG EEG2 CURRENTSET] = pop_newset(ALLEEG, EEG2, 12,'setname','AC12 14chan','gui','off'); 
EEG2 = eeg_checkset( EEG2 );

ind = 0;
mean_all_foot = mean(EEG2.data,3);
std_err_all_foot = std(EEG2.data,0,3)/sqrt(size(EEG2.data,3));
figure()
for i=1:length(channum_list)
    subplot(4,7,i)
    if chan_log(i) == true
        ind = ind+1;
        time = -5:(1/EEG.srate):4.1;
        mean_data_foot = mean_all_foot(ind,:);
        std_err_foot = std_err_all_foot(ind,:);
        hold on
        %foot
        p1 = plot(time, mean_data_foot, 'b');
        p2 = plot(time, [mean_data_foot + std_err_foot; mean_data_foot - std_err_foot], 'b', 'LineStyle', 'none');
        x2 = [time, fliplr(time)];
        inBetween = [mean_data_foot - std_err_foot, fliplr(mean_data_foot + std_err_foot)];
        fill(x2, inBetween, 'b','LineStyle','none');
        alpha(0.25);
        
        xlabel('time in s')
        ylabel('amplitude in \muV')
        xlim([-1 3.4])
        ylim([-10 10])
        p5 = plot([0 0], ylim, 'k', 'LineStyle', '--');
        legend([p1],Classlabel,'Location','southwest');
        hold off
        grid on
        set(gca,'FontSize',6);
        title(EEG2.chanlocs(ind).labels,'FontSize',8);
    else
        axis off
    end
end

% figure; pop_plottopo(EEG2, [1:EEG2.nbchan] , '', 0, 'ydir',1,'axsize',[0.09 0.08]);
%figpos = get(gcf, 'Position', 'Normalized');
set(gcf, 'Position', get(0, 'Screensize')); 
% set(gcf, 'PaperUnit', 'Centimeters');
% set(gcf, 'Papersize', [30,17]);

% pdfplot
orient('landscape')
print(char(strcat("MRCP_", Classlabels(e),".pdf")),'-dpdf','-fillpage');
%% END
eeglab redraw;