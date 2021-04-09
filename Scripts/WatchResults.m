close all;
clear all;
clc;

res_AC21 = load('Results Patient AC21.mat');
res_AC22 = load('Results Patient AC22.mat');
res_AC23 = load('Results Patient AC23.mat');

res_AC21.mean_paper = mean(res_AC21.acc_AC21_paper);
res_AC21.mean_valeria = mean(res_AC21.acc_AC21_valeria);
res_AC21.mean_robert = mean(res_AC21.acc_AC21_robert);

res_AC22.mean_paper = mean(res_AC22.acc_AC22_paper);
res_AC22.mean_valeria = mean(res_AC22.acc_AC22_valeria);
res_AC22.mean_robert = mean(res_AC22.acc_AC22_robert);

res_AC23.mean_paper = mean(res_AC23.acc_AC23_paper);
res_AC23.mean_valeria = mean(res_AC23.acc_AC23_valeria);
res_AC23.mean_robert = mean(res_AC23.acc_AC23_robert);

figure();
title("Results for patient AC21");
bar(1, res_AC21.mean_robert);
hold on
bar(2, res_AC21.mean_valeria);
bar(3, res_AC21.mean_paper);
hold off
legend('Roberts Method', 'Valerias Method', 'Paper Method');

figure();
title("Results for patient AC22");
bar(1, res_AC22.mean_robert);
hold on
bar(2, res_AC22.mean_valeria);
bar(3, res_AC22.mean_paper);
hold off
legend('Roberts Method', 'Valerias Method', 'Paper Method');

figure();
title("Results for patient AC23");
bar(1, res_AC23.mean_robert);
hold on
bar(2, res_AC23.mean_valeria);
bar(3, res_AC23.mean_paper);
hold off
legend('Roberts Method', 'Valerias Method', 'Paper Method');
