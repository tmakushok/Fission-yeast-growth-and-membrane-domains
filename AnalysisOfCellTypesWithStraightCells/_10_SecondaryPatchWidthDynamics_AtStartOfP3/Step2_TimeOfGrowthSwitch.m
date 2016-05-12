%% The task of the program is to extract the moment of switch in patch width
%% behaviour
close all
%---------------------------------------
%---------------------------------------
%% Finding the moment when shrinking turns into widening
Switch = [];
Dynamics = PatchDynamics_Phases;
for i_cell = 1:length(Dynamics)     
    Dyn_OneEnd = Dynamics{i_cell};
    if isempty(Dyn_OneEnd)
        continue
    end
    for i_k = 1:size(Dyn_OneEnd, 1)
        Speed = Dyn_OneEnd(i_k, 3);
        % The beginning of the first positive-slope growth phase is the
        % moment of the growth switch
        if Speed > 0              
            Switch = [Switch; Dyn_OneEnd(i_k, 1)];
            Flag = 1;
%             Switch(i_cell, 1) = Dyn_OneEnd(i_k, 1);   % Time of the beginning of this phase
            break
        end
    end    
    % To correct an error case when Switch is not added
    if Flag == 0
        Switch = [Switch; -1];
    end
    Flag = 0;
end
%% Subtract from the switch times the times of cell growth initiation
%% to have growth initiation at the other cell end as zero time
TimeCellGrowthInit = TimeCellGrowthInit(TimeCellGrowthInit > 0);
Switch = Switch - TimeCellGrowthInit;
% Switch = Switch - TimeCellGrowthInit(find(TimeCellGrowthInit));
%% Transform time points into minutes
Switch(Switch < 0) = [];    % To get rid of the wrong points
Switch = Switch * 3;
%% Visualise
% Together with those that did not widen at all before shrinking
figure, 
[N, Xout] = hist(Switch, 30);     % Plot the values only for cells that do grow quickly at some point
bar(Xout, N);
xlabel('Switch in widening behaviour, in minutes from cell growth initiation');
ylabel('N');
title('Wild type');
%% Proportion of cells having first a widening phase
PropWid = length(Switch(Switch > 0)) / length(Switch)
%% Visualise
% Only cells that had a widening phase
figure, 
SwitchAfterWid = Switch(Switch ~= 0);
[N, Xout] = hist(SwitchAfterWid, 25);     % Plot the values only for cells that do grow quickly at some point
bar(Xout, N);
xlabel('Switch in widening behaviour, in minutes from cell growth initiation');
ylabel('N');
title('Wild type');

M = mean(SwitchAfterWid)
S = std(SwitchAfterWid)
