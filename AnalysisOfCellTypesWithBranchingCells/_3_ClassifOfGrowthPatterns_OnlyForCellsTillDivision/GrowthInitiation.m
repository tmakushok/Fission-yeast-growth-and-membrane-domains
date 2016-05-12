%% The task of the program is to extract the moment of growth initiation
%% from the data describing the growth dynamics
close all
%---------------------------------------
BigSpeedThres = 0.9 / (20 * 0.0707);      % Threshold transformed to pixels per 3 minutes
% The region of growth has to be at least this long in time points so
% that it can be considered safely as quickly growing
PhaseTimeThres = 5;     % In time points
%---------------------------------------
load('Dynamics.mat');
load('DividingCells.mat');
%% Selecting only the cells that were observed till cell division
Dynamics = Dynamics(logical(Divide_Mov));
%% Growth initiation for each of the cell ends
GrQuick = [];
CellsAllEnds = [];
for i_cell = 1:length(Dynamics) 
    if isempty(Dynamics{i_cell})
        continue
    end
    for i_end = 1:length(Dynamics{i_cell})
        Dyn_OneEnd = Dynamics{i_cell}{i_end};
        for i_k = 1:size(Dyn_OneEnd, 1)  % Loop on growth phases
            Speed = Dyn_OneEnd(i_k, 3);
            if Speed > BigSpeedThres
%                % Check if it is not a small bit going up quickly with
%                % next one going too slow to be called quick (except for the last phase of growth)
%                 PhaseLen = Dyn_OneEnd(i_k, 2) - Dyn_OneEnd(i_k, 1);
%                 if ~(i_k == size(Dyn_OneEnd, 1)) && (PhaseLen < PhaseTimeThres) && (Dyn_OneEnd(i_k + 1, 3) < BigSpeedThres)
%                     continue
%                 end
                % Check if the growth phase is long enough to be called a
                % growth phase
                PhaseLen = Dyn_OneEnd(i_k, 2) - Dyn_OneEnd(i_k, 1);
                if PhaseLen < PhaseTimeThres
                    continue
                end
                GrQuick = [GrQuick; Dyn_OneEnd(i_k, 1)];   % Time of the beginning of this quick phase of growth    
                CellsAllEnds = [CellsAllEnds; i_cell];
                break
            end
        end    
    end
end
%% Transform time points into minutes
GrQuickAllEnds = (GrQuick - 1) * 3 + 10;
%% Visualise
figure, 
[N, Xout] = hist(GrQuickAllEnds, 30);     % Plot the values only for cells that do grow quickly at some point
bar(Xout, N);
xlabel('Start of quick growth, in minutes');
ylabel('N');
title('Wild type');

%% Growth initiation for the first-growing cell end only (one value per cell, proper quick cell growth initiation)
GrQuick = [];
for i_cell = 1:length(Dynamics) 
    if isempty(Dynamics{i_cell})
        continue
    end    
    Quick = [];
    for i_end = 1:length(Dynamics{i_cell})
        Dyn_OneEnd = Dynamics{i_cell}{i_end};
        for i_k = 1:size(Dyn_OneEnd, 1)
            Speed = Dyn_OneEnd(i_k, 3);
            if Speed > BigSpeedThres
%                 % Check if it is not a small bit going up quickly with
%                 % next one going too slow to be called quick (except for the last phase of growth)
%                 PhaseLen = Dyn_OneEnd(i_k, 2) - Dyn_OneEnd(i_k, 1);
%                 if ~(i_k == size(Dyn_OneEnd, 1)) && (PhaseLen < PhaseTimeThres) && (Dyn_OneEnd(i_k + 1, 3) < BigSpeedThres)
%                     continue
%                 end
                % Check if the growth phase is long enough to be called a
                % growth phase
                PhaseLen = Dyn_OneEnd(i_k, 2) - Dyn_OneEnd(i_k, 1);
                if PhaseLen < PhaseTimeThres
                    continue
                end
                Quick = [Quick; Dyn_OneEnd(i_k, 1)];
                break
            end
        end    
    end
    GrQuick = [GrQuick; min(Quick)];  % Take the earliest of the two cell ends
end
%% Transform time points into minutes
GrQuickFirstEnd = (GrQuick - 1) * 3 + 10;
%% Visualise
figure, 
[N, Xout] = hist(GrQuickFirstEnd, 30);     % Plot the values only for cells that do grow quickly at some point
bar(Xout, N);
xlabel('Start of quick growth, in minutes');
ylabel('N');
title('Wild type');

%% Time of NETO
GrQuick = [];
NetoFromGrowthInit = [];
NETO_Cells = [];
for i_cell = 1:length(Dynamics) 
    if isempty(Dynamics{i_cell})
        continue
    end    
    Quick = [];
    for i_end = 1:length(Dynamics{i_cell})
        Dyn_OneEnd = Dynamics{i_cell}{i_end};
        for i_k = 1:size(Dyn_OneEnd, 1)
            Speed = Dyn_OneEnd(i_k, 3);
            if Speed > BigSpeedThres
%                 % Check if it is not a small bit going up quickly with
%                 % next one going too slow to be called quick (except for the last phase of growth)
%                 PhaseLen = Dyn_OneEnd(i_k, 2) - Dyn_OneEnd(i_k, 1);
%                 if ~(i_k == size(Dyn_OneEnd, 1)) && (PhaseLen < PhaseTimeThres) && (Dyn_OneEnd(i_k + 1, 3) < BigSpeedThres)
%                     continue
%                 end
                % Check if the growth phase is long enough to be called a
                % growth phase
                PhaseLen = Dyn_OneEnd(i_k, 2) - Dyn_OneEnd(i_k, 1);
                if PhaseLen < PhaseTimeThres
                    continue
                end
                Quick = [Quick; Dyn_OneEnd(i_k, 1)];
                break
            end
        end    
    end
    if length(Quick) == 2
        GrQuick = [GrQuick; max(Quick)];  % Take the latest of the two cell ends
        NetoFromGrowthInit = [NetoFromGrowthInit; max(Quick) - min(Quick)];  % Moment of NETO measured from the moment of quick cell growth initiation
        NETO_Cells = [NETO_Cells; i_cell];
    end
end
%% Transform time points into minutes
NETOFromRelease = (GrQuick - 1) * 3 + 10;
NetoFromGrowthInit = NetoFromGrowthInit * 3;
%% Visualise
figure, 
[N, Xout] = hist(NETOFromRelease, 10);     % Plot the values only for cells that do grow quickly at some point
bar(Xout, N);
xlabel('NETO time, in minutes from release from starvation');
ylabel('N');
title('Wild type');

figure, 
[N, Xout] = hist(NetoFromGrowthInit, 12);     % Plot the values only for cells that do grow quickly at some point
bar(Xout, N);
xlabel('NETO time, in minutes from quick cell growth initiation');
ylabel('N');
title('Wild type');







