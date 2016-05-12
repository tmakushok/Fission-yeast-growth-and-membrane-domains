%% The task of the program in to 
%% a) determine the time from the beginning of P3 to
%% the beginning of the pause (for the cells that pause in P4 it is also 
%% from the beginning of P3)
clear
close all

%% Data coming from the manual analysis of the pausing cells (file 'PauseInfo.xlsx')
PauseStart = -[1-23; 8-43; 5-42; 7-43; 10-45; 10-21; 10-41; 15-49; 23-45;...
            11-28; 10-36; 22-58; 9-20; 24-44; 3-49; 14-45; ...
            11-38; 9-26; 9-26; 12-45; 18-27];
%% Transform time points into minutes
PauseStart = PauseStart * 3;
%% Statistics
StartAvg = mean(PauseStart);
StartStd = std(PauseStart);


%% b) determine the time from the beginning of P4 to the beginning of the
%% pause for the cells that pause in P4

%% Data coming from the manual analysis of the cells pausing in P4 (file 'PauseInfo.xlsx')
PauseStartP4 = [21-13; 45-27; 45-27];
%% Transform time points into minutes
PauseStartP4 = PauseStartP4 * 3;
%% Statistics
StartAvgP4 = mean(PauseStartP4);
StartStdP4 = std(PauseStartP4);

