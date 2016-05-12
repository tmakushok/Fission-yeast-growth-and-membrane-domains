%% The task of the program is to study the correlation between P3
%% initiation time and division phase start
clear
load('DivisionTimes.mat');
load('TimesStartGrowth_ManuallyCorrected.mat');

P3St_DivSt = [];
for i_cell = 1:size(DivisionTimes,1)
    if DivisionTimes(i_cell,1) == 0
        continue
    end
    if isempty(TimeStartGrowth{i_cell})
        continue
    end
    P3StAllEnds = TimeStartGrowth{i_cell};
    P3Start = [];
    for i_end = 1:length(P3StAllEnds)
        P3Start = [P3Start; P3StAllEnds{i_end}(3)];
    end
    [a, b, P3Start] = find(P3Start);
    if length(P3Start) > 1
        pause(0.5);
    end
    P3St_DivSt = [P3St_DivSt; i_cell, P3Start, DivisionTimes(i_cell,1)];
end
%% Transforming time into minutes
% P3St_DivSt = P3St_DivSt * 3 + 7 % ????????? 




