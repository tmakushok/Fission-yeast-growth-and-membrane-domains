%% The task of the program is to extract the moment of growth initiation
%% from the data describing the growth dynamics
clear
close all
load('TimesStartGrowth.mat');
%% Growth initiation for the old end (cell quick growth initiation):
%% Beginning of P3
GrQuick = [];
LateStarters = [];
for i_cell = 1:length(TimeStartGrowth) 
    if isempty(TimeStartGrowth{i_cell})
        continue
    end
    % Quick growth times for both cell ends 
    GrTimes = [TimeStartGrowth{i_cell}{1}(3); TimeStartGrowth{i_cell}{2}(3)];
    Nb = length(find(GrTimes)); % Number of cell ends initiating quick growth
    if Nb == 0
        continue
    end
    if Nb == 1
        GrQuick = [GrQuick; max(GrTimes)];  % 'max'- to avoid the zero value
    end
    if Nb == 2
        GrQuick = [GrQuick; min(GrTimes)];  % the first of the two growth initiation times is taken
    end
%     % Save numbers of cells that initiate growth really late, to check them
%     % The four are checked and are truly just starting late
%     if GrQuick(length(GrQuick)) > 64 
%         LateStarters = [LateStarters; i_cell];
%     end
end

%% Transform time points into minutes (from the release from starvation)
GrQuickFirstEnd = (GrQuick - 1) * 3 + 10;
%% Visualise
figure, 
% [N, Xout] = hist(GrQuickFirstEnd, 20);     % Plot the values only for cells that do grow quickly at some point
%% !!!
%% !!!
X = 0:20:340;
[N, Xout] = hist(GrQuickFirstEnd, X);
% bar(Xout, N, [0.5 0.5 0.5], 'LineWidth', 0.1);
bar(Xout, N, 'FaceColor', [0.3 0.3 0.3], 'EdgeColor', [0.3 0.3 0.3], 'LineWidth', 0.1);
% xlabel('Quick growth initiation moment at old end, in minutes from GS release');
set(gca,'XTick',0:50:350)
% xlabel('Beginning of P3 (min from SR)');
% ylabel('N');
xlim([0 371]);
ylim([0 130]);

% figure, plot(GrQuickFirstEnd, 'ro');

%% NETO time: Beginning of P4
%% (using only long movies)
load('TimesStartGrowth_LongMovies.mat');
load('DivisionTimes.mat');

GrQuick = [];
NetoFromGrowthInit = []; % Is the length of P3
FromP3ToDivision = [];
CellsHavingP4 = [];
for i_cell = 1:length(TimeStartGrowth) 
    if isempty(TimeStartGrowth{i_cell})
        continue
    end
    % Quick growth times for both cell ends 
    GrTimes = [TimeStartGrowth{i_cell}{1}(3); TimeStartGrowth{i_cell}{2}(3)];
    Nb = length(find(GrTimes)); % Number of cell ends initiating quick growth
    if Nb == 2
        % Moment of NETO from release from GS
        GrQuick = [GrQuick; max(GrTimes)];  % the biggest of the two growth initiation times is taken
        % Moment of NETO from quick growth initiation
        NetoFromGrowthInit = [NetoFromGrowthInit; max(GrTimes) - min(GrTimes)];
        CellsHavingP4 = [CellsHavingP4; i_cell];
    end
    % For the length of P3: take into account the cells that don't have P4
    % (cells in which there is the beginning of P3 and then cell division)
    if (Nb == 1) && (DivisionTimes(i_cell,1) > 0)
        FromP3ToDivision = [FromP3ToDivision; DivisionTimes(i_cell,1) - max(GrTimes)];
    end
end

%% Transform time points into minutes (from the release from starvation)
GrQuickSecondEnd = (GrQuick - 1) * 3 + 10;
NetoFromGrowthInit = NetoFromGrowthInit * 3;
FromP3ToDivision = FromP3ToDivision * 3;
%% Visualise
figure, 
X = 0:35:370;
[N, Xout] = hist(GrQuickSecondEnd, X);
bar(Xout, N, 'FaceColor', [0.3 0.3 0.3], 'EdgeColor', [0.3 0.3 0.3], 'LineWidth', 0.1);
set(gca,'XTick',0:50:350)
xlabel('Beginning of P4 (min from SR)');
ylabel('N');
xlim([0 370]);
ylim([0 9]);

% Plot all the data points instead of a histogram
figure, plot(GrQuickSecondEnd, 'ro');
figure, plot(NetoFromGrowthInit, 'ro');

figure, 
X = 0:25:300;
[N, Xout] = hist(NetoFromGrowthInit, X);
bar(Xout, N, 'FaceColor', [0.3 0.3 0.3], 'EdgeColor', [0.3 0.3 0.3], 'LineWidth', 0.1);
set(gca,'XTick',0:50:300);
set(gca,'YTick',0:5:10);
xlabel('Length of P3 (min)');
ylabel('N');
xlim([0 315]);
ylim([0 10]);


% Plot all the data points instead of a histogram
figure, plot(NetoFromGrowthInit, 'ro');
figure, plot(FromP3ToDivision, 'ro');
% Histogram of length of P3 for cells not doing NETO
figure, 
X = 0:25:300;
[N, Xout] = hist(FromP3ToDivision, X);
bar(Xout, N, 'FaceColor', [0.3 0.3 0.3], 'EdgeColor', [0.3 0.3 0.3], 'LineWidth', 0.1);
set(gca,'XTick',0:50:300)
xlabel('Length of P3 (min)');
ylabel('N');
xlim([0 315]);
ylim([0 15]);
%% Length of P4
P4Len = zeros(length(DivisionTimes),1);
for i = 1:size(DivisionTimes, 1)
    if DivisionTimes(i,1) > 0
        % Quick growth times for both cell ends 
        GrTimes = [TimeStartGrowth{i}{1}(3); TimeStartGrowth{i}{2}(3)];
        Nb = length(find(GrTimes)); % Number of cell ends initiating quick growth
        if Nb == 2  % If NETO actually happened
            TimeNETO = max(GrTimes);        
            % Calculating length of P4    
            P4Len(i,1) = DivisionTimes(i,1) - TimeNETO;
        end            
    end
%     if DivisionTimes(i,1) == -1     % Means that cell did not divide till the end of the movie
%         P4Len(i,1) = 700;
%     end
end
% Keep only positive values of P4 length
P4Len(find(P4Len < 1)) = [];
P4Len = P4Len';
% Going from time points to minutes
P4Len = P4Len * 3;
%% Visualise
figure, 
X = 0:25:200;
[N, Xout] = hist(P4Len, X);
bar(Xout, N, 'FaceColor', [0.3 0.3 0.3], 'EdgeColor', [0.3 0.3 0.3], 'LineWidth', 0.1);
set(gca,'XTick',0:50:200)
xlabel('Length of P4 (min)');
ylabel('N');
xlim([0 215]);
ylim([0 11]);

% Plot all the data points instead of a histogram
figure, plot(P4Len, 'ro');
%% Time of the beginning of cell division
Division = DivisionTimes(:,1);
Division = Division(find(Division > 0));
% Transform time points into minutes (from the release from starvation)
Division = Division * 3 + 7;
% Visualise
figure, plot(Division, 'ro');
% Histogram of length of P3 for cells not doing NETO
figure, 
X = 0:30:400;
[N, Xout] = hist(Division, X);
bar(Xout, N, 'FaceColor', [0.3 0.3 0.3], 'EdgeColor', [0.3 0.3 0.3], 'LineWidth', 0.1);
set(gca,'XTick',0:50:400)
set(gca,'YTick',0:5:20)
% xlabel('Cell division time (min from SR)');
% ylabel('N');
xlim([0 408]);
ylim([0 20]);