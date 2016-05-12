%% The task of the program in to determine the length of the pause in cells
%% pausing growth
clear
close all

%% Data coming from the manual analysis of the pausing cells (file 'PauseInfo.xlsx')
PauseLen = [33-23; 54-43; 73-43; 77-45; 35-21; 63-41; 55-49; 84-45;...
            81-28; 108-31; 96-36; 90-58; 61-38; 105-20; 70-49; 70-45; ...
            106-38; 86-38; 111-26; 112-26; 85-45; 105-27; 64-16];
%% Transform time points into minutes
PauseLen = PauseLen * 3;
%% Statistics
LenAvg = mean(PauseLen);
LenStd = std(PauseLen);
