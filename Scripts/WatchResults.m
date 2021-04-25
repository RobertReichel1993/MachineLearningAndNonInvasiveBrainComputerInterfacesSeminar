close all;
clear all;
clc;

time_vec = {'m1', 'm2', 'paper'};
freq_vec = {'avrfreq', 'csp_all', 'csp_bins'};
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
%Getting best features from methods
AC21_best_freq_class1 = feat_AC21.(strcat("features_class_1_AC21_", AC21_max_freq));
AC21_best_freq_class2 = feat_AC21.(strcat("features_class_2_AC21_", AC21_max_freq));
AC21_best_time_class1 = feat_AC21.(strcat("features_class_1_AC21_", AC21_max_time));
AC21_best_time_class2 = feat_AC21.(strcat("features_class_2_AC21_", AC21_max_time));






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
%Getting best features from methods
AC22_best_freq_class1 = feat_AC22.(strcat("features_class_1_AC22_", AC22_max_freq));
AC22_best_freq_class2 = feat_AC22.(strcat("features_class_2_AC22_", AC22_max_freq));
AC22_best_time_class1 = feat_AC22.(strcat("features_class_1_AC22_", AC22_max_time));
AC22_best_time_class2 = feat_AC22.(strcat("features_class_2_AC22_", AC22_max_time));






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

time_vec_12 = {'m1_12', 'm2_12', 'paper_12'};
freq_vec_12 = {'paper_12', 'csp_all_12', 'csp_bins_12'};
time_vec_13 = {'m1_13', 'm2_13', 'paper_13'};
freq_vec_13 = {'paper_13', 'csp_all_13', 'csp_bins_13',};
time_vec_23 = {'m1_23', 'm2_23', 'paper_23'};
freq_vec_23 = {'paper_23', 'csp_all_23', 'csp_bins_23'};

%Getting best performing methods
[~, idx] = max([AC23_freq_paper_1_2, AC23_freq_csp_all_1_2, AC23_freq_csp_bins_1_2]);
AC23_max_freq_12 = freq_vec_12(idx);
[~, idx] = max([AC23_time_robert_1_2, AC23_time_valeria_1_2, AC23_time_paper_1_2]);
AC23_max_time_12 = time_vec_12(idx);

%Getting best performing methods
[~, idx] = max([AC23_freq_paper_1_3, AC23_freq_csp_all_1_3, AC23_freq_csp_bins_1_3]);
AC23_max_freq_13 = freq_vec_13(idx);
[~, idx] = max([AC23_time_robert_1_3, AC23_time_valeria_1_3, AC23_time_paper_1_3]);
AC23_max_time_13 = time_vec_13(idx);

%Getting best performing methods
[~, idx] = max([AC23_freq_paper_2_3, AC23_freq_csp_all_2_3, AC23_freq_csp_bins_2_3]);
AC23_max_freq_23 = freq_vec_23(idx);
[~, idx] = max([AC23_time_robert_2_3, AC23_time_valeria_2_3, AC23_time_paper_2_3]);
AC23_max_time_23 = time_vec_23(idx);

%Getting best features from methods, classes 1 and 2
AC23_best_freq_class1_12 = feat_AC23.(strcat("features_class_1_AC23_", AC23_max_freq_12));
AC23_best_freq_class2_12 = feat_AC23.(strcat("features_class_2_AC23_", AC23_max_freq_12));
AC23_best_time_class1_12 = feat_AC23.(strcat("features_class_1_AC23_", AC23_max_time_12));
AC23_best_time_class2_12 = feat_AC23.(strcat("features_class_2_AC23_", AC23_max_time_12));

%Getting best features from methods, classes 1 and 3
AC23_best_freq_class1_13 = feat_AC23.(strcat("features_class_1_AC23_", AC23_max_freq_13));
AC23_best_freq_class2_13 = feat_AC23.(strcat("features_class_2_AC23_", AC23_max_freq_13));
AC23_best_time_class1_13 = feat_AC23.(strcat("features_class_1_AC23_", AC23_max_time_13));
AC23_best_time_class2_13 = feat_AC23.(strcat("features_class_2_AC23_", AC23_max_time_13));

%Getting best features from methods, classes 2 and 3
AC23_best_freq_class1_23 = feat_AC23.(strcat("features_class_1_AC23_", AC23_max_freq_23));
AC23_best_freq_class2_23 = feat_AC23.(strcat("features_class_2_AC23_", AC23_max_freq_23));
AC23_best_time_class1_23 = feat_AC23.(strcat("features_class_1_AC23_", AC23_max_time_23));
AC23_best_time_class2_23 = feat_AC23.(strcat("features_class_2_AC23_", AC23_max_time_23));
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