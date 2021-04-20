close all;
clear all;
clc;

time_vec = {'Robert', 'Valeria', 'paper'};
freq_vec = {'paper', 'csp_all', 'csp_bins'};
%Loading results
res_AC21 = load('..\Data\Results Patient AC21.mat');
res_AC22 = load('..\Data\Results Patient AC22.mat');
res_AC23 = load('..\Data\Results Patient AC23.mat');
%Loading features
feat_AC21 = load('..\Data\Features Patient AC21.mat');
feat_AC22 = load('..\Data\Features Patient AC22.mat');
feat_AC23 = load('..\Data\Features Patient AC23.mat');
%Patient AC21
AC21_freq_paper = mean(res_AC21.acc_AC21_freq_paper);
AC21_freq_csp_all = mean(res_AC21.acc_AC21_freq_csp_all);
AC21_freq_csp_bins = mean(res_AC21.acc_AC21_freq_csp_bins);
AC21_time_robert = mean(res_AC21.acc_AC21_time_robert);
AC21_time_valeria = mean(res_AC21.acc_AC21_time_valeria);
AC21_time_paper = mean(res_AC21.acc_AC21_time_paper);
%Getting best performing methods
[~, idx] = max([AC21_freq_paper, AC21_freq_csp_all, AC21_freq_csp_bins]);
AC21_max_freq = freq_vec(idx);
[~, idx] = max([AC21_time_robert, AC21_time_valeria, AC21_time_paper]);
AC21_max_time = time_vec(idx);

%Patient AC22
AC22_freq_paper = mean(res_AC22.acc_AC22_freq_paper);
AC22_freq_csp_all = mean(res_AC22.acc_AC22_freq_csp_all);
AC22_freq_csp_bins = mean(res_AC22.acc_AC22_freq_csp_bins);
AC22_time_robert = mean(res_AC22.acc_AC22_time_robert);
AC22_time_valeria = mean(res_AC22.acc_AC22_time_valeria);
AC22_time_paper = mean(res_AC22.acc_AC22_time_paper);
%Getting best performing methods
[~, idx] = max([AC22_freq_paper, AC22_freq_csp_all, AC22_freq_csp_bins]);
AC22_max_freq = freq_vec(idx);
[~, idx] = max([AC22_time_robert, AC22_time_valeria, AC22_time_paper]);
AC22_max_time = time_vec(idx);

%Patient AC23
AC23_freq_paper_1_2 = mean(res_AC23.acc_AC23_freq_paper_class_1_2);
AC23_freq_paper_1_3 = mean(res_AC23.acc_AC23_freq_paper_class_1_3);
AC23_freq_paper_2_3 = mean(res_AC23.acc_AC23_freq_paper_class_2_3);
AC23_freq_csp_all_1_2 = mean(res_AC23.acc_AC23_freq_csp_class_1_2_all);
AC23_freq_csp_all_1_3 = mean(res_AC23.acc_AC23_freq_csp_class_1_3_all);
AC23_freq_csp_all_2_3 = mean(res_AC23.acc_AC23_freq_csp_class_2_3_all);
AC23_freq_csp_bins_1_2 = mean(res_AC23.acc_AC23_freq_csp_class_1_2_bins);
AC23_freq_csp_bins_1_3 = mean(res_AC23.acc_AC23_freq_csp_class_1_3_bins);
AC23_freq_csp_bins_2_3 = mean(res_AC23.acc_AC23_freq_csp_class_2_3_bins);
AC23_time_robert_1_2 = mean(res_AC23.acc_AC23_time_robert_class_1_2);
AC23_time_robert_1_3 = mean(res_AC23.acc_AC23_time_robert_class_1_3);
AC23_time_robert_2_3 = mean(res_AC23.acc_AC23_time_robert_class_2_3);
AC23_time_valeria_1_2 = mean(res_AC23.acc_AC23_time_valeria_class_1_2);
AC23_time_valeria_1_3 = mean(res_AC23.acc_AC23_time_valeria_class_1_3);
AC23_time_valeria_2_3 = mean(res_AC23.acc_AC23_time_valeria_class_2_3);
AC23_time_paper_1_2 = mean(res_AC23.acc_AC23_time_paper_class_1_2);
AC23_time_paper_1_3 = mean(res_AC23.acc_AC23_time_paper_class_1_3);
AC23_time_paper_2_3 = mean(res_AC23.acc_AC23_time_paper_class_2_3);

time_vec = {'Robert_12', 'Valeria_12', 'paper_12', 'Robert_13', ...
    'Valeria_13', 'paper_13', 'Robert_23', 'Valeria_23', 'paper_23'};
freq_vec = {'paper_12', 'csp_all_12', 'csp_bins_12', 'paper_13', ...
    'csp_all_13', 'csp_bins_13', 'paper_23', 'csp_all_23', 'csp_bins_23'};
%Getting best performing methods
[~, idx] = max([AC23_freq_paper_1_2, AC23_freq_csp_all_1_2, AC23_freq_csp_bins_1_2, ...
    AC23_freq_paper_1_3, AC23_freq_csp_all_1_3, AC23_freq_csp_bins_1_3, ...
    AC23_freq_paper_2_3, AC23_freq_csp_all_2_3, AC23_freq_csp_bins_2_3]);
AC23_max_freq = freq_vec(idx);
[~, idx] = max([AC23_time_robert_1_2, AC23_time_valeria_1_2, AC23_time_paper_1_2, ...
    AC23_time_robert_1_3, AC23_time_valeria_1_3, AC23_time_paper_1_3, ...
    AC23_time_robert_2_3, AC23_time_valeria_2_3, AC23_time_paper_2_3]);
AC23_max_time = time_vec(idx);

%%
%Patient AC21
fig = figure('units', 'normalized', 'outerposition', [0 0 1 1], 'Name', ...
    'Accuracies for Patien AC 21');
subplot(2, 1, 1);
title("Results for frequency domain");
hold on;
bar(1, AC21_freq_paper);
bar(2, AC21_freq_csp_all);
bar(3, AC21_freq_csp_bins);
hold off;
ylabel('Accuracy / Percent');
legend('Paper Features', 'CSP Features, mean over all frequencies', ...
    'CSP Features, mean over frequency bins', 'Location', 'NorthWest');
subplot(2, 1, 2);
title("Results for time domain");
hold on;
bar(1, AC21_time_robert);
bar(2, AC21_time_valeria);
bar(3, AC21_time_paper);
hold off;
ylabel('Accuracy / Percent');
legend('Method Robert', 'Method Valeria', 'Method Paper', 'Location', 'NorthWest');
saveas(fig, '../Plots/AC21_Results_classification', 'jpeg');
saveas(fig, '../Plots/AC21_Results_classification', 'fig');

%%
%Patient AC22
figure('units', 'normalized', 'outerposition', [0 0 1 1], 'Name', ...
    'Accuracies for Patien AC 22');
title("Results for patient AC22");
subplot(2, 1, 1);
title("Results for frequency domain");
hold on;
bar(1, AC22_freq_paper);
bar(2, AC22_freq_csp_all);
bar(3, AC22_freq_csp_bins);
hold off;
ylabel('Accuracy / Percent');
legend('Paper Features', 'CSP Features, mean over all frequencies', ...
    'CSP Features, mean over frequency bins', 'Location', 'NorthWest');
subplot(2, 1, 2);
title("Results for time domain");
hold on;
bar(1, AC22_time_robert);
bar(2, AC22_time_valeria);
bar(3, AC22_time_paper);
hold off;
ylabel('Accuracy / Percent');
legend('Method Robert', 'Method Valeria', 'Method Paper', 'Location', 'NorthWest');
saveas(fig, '../Plots/AC22_Results_classification', 'jpeg');
saveas(fig, '../Plots/AC22_Results_classification', 'fig');

%%
%Patient AC23
figure('units', 'normalized', 'outerposition', [0 0 1 1], 'Name', ...
    'Accuracies for Patien AC 23, time domain');
%Time domain, method paper
subplot(3, 1, 1);
title('Time domain, features of paper method');
hold on;
bar(1, AC23_time_paper_1_2);
bar(2, AC23_time_paper_1_3);
bar(3, AC23_time_paper_2_3);
hold off;
ylabel('Accuracy / Percent');
legend('Class 1 and 2', 'Class 1 and 3', 'Class 2 and 3', 'Location', 'NorthWest');
%Time domain, robert's paper
subplot(3, 1, 2);
title('Time domain, features of rober''s method');
hold on;
bar(1, AC23_time_robert_1_2);
bar(2, AC23_time_robert_1_3);
bar(3, AC23_time_robert_2_3);
hold off;
ylabel('Accuracy / Percent');
legend('Class 1 and 2', 'Class 1 and 3', 'Class 2 and 3', 'Location', 'NorthWest');
%Time domain, valeria's paper
subplot(3, 1, 3);
title('Time domain, features of valeria''s method');
hold on;
bar(1, AC23_time_valeria_1_2);
bar(2, AC23_time_valeria_1_3);
bar(3, AC23_time_valeria_2_3);
hold off;
ylabel('Accuracy / Percent');
legend('Class 1 and 2', 'Class 1 and 3', 'Class 2 and 3', 'Location', 'NorthWest');
saveas(fig, '../Plots/AC23_Results_classification_timeDomain', 'jpeg');
saveas(fig, '../Plots/AC23_Results_classification_timeDomain', 'fig');


figure('units', 'normalized', 'outerposition', [0 0 1 1], 'Name', ...
    'Accuracies for Patien AC 23, frequency domain');
%Frequency domain, method paper
subplot(3, 1, 1);
title('Frequency domain, features of paper method');
hold on;
bar(1, AC23_freq_paper_1_2);
bar(2, AC23_freq_paper_1_3);
bar(3, AC23_freq_paper_2_3);
hold off;
ylabel('Accuracy / Percent');
legend('Class 1 and 2', 'Class 1 and 3', 'Class 2 and 3', 'Location', 'NorthWest');
%Frequency domain, mean PSD across whole frequency domain filtered with CSP
subplot(3, 1, 2);
title('Frequency domain, mean PSD across whole frequency domain filtered with CSP');
hold on;
bar(1, AC23_freq_csp_all_1_2);
bar(2, AC23_freq_csp_all_1_3);
bar(3, AC23_freq_csp_all_2_3);
hold off;
ylabel('Accuracy / Percent');
legend('Class 1 and 2', 'Class 1 and 3', 'Class 2 and 3', 'Location', 'NorthWest');
%Frequency domain, mean PSD across frequency bins filtered with CSP
subplot(3, 1, 3);
title('Frequency domain, mean PSD across frequency bins filtered with CSP');
hold on;
bar(1, AC23_freq_csp_bins_1_2);
bar(2, AC23_freq_csp_bins_1_2);
bar(3, AC23_freq_csp_bins_1_2);
hold off;
ylabel('Accuracy / Percent');
legend('Class 1 and 2', 'Class 1 and 3', 'Class 2 and 3', 'Location', 'NorthWest');
saveas(fig, '../Plots/AC23_Results_classification_frequencyDomain', 'jpeg');
saveas(fig, '../Plots/AC23_Results_classification_frequencyDomain', 'fig');