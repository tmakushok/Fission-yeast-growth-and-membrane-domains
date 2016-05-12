%% The task of the program is to plot the correlatation
clear
load('_Output/CellNb_P3InitTime_DivisionStart_InTimePts_ManuallyCorrected.mat')
%% Tranform into minutes
P3St_DivSt(:,2) = P3St_DivSt(:,2) * 3 + 7;
P3St_DivSt(:,3) = P3St_DivSt(:,3) * 3 + 7;
%% Plot
figure, plot(P3St_DivSt(:,2), P3St_DivSt(:,3), 'k.', 'MarkerSize', 5);
xlabel('P3 initiation time (min after RS)');
ylabel('Division phase start (min after RS)');
title('Tea1del cells');