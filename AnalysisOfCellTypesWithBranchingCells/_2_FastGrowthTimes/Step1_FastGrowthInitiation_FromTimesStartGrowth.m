%% The task of the program is to extract the moment of growth initiation
%% from the data describing the growth dynamics
clear
close all
load('TimesStartGrowth_ManuallyCorrected.mat');
%% Growth initiation for the old end (cell quick growth initiation):
%% Beginning of P3
GrQuick = [];
LateStarters = [];
NbEnds = [];
Check = [];
for i_cell = 1:length(TimeStartGrowth) 
    if isempty(TimeStartGrowth{i_cell})
        continue
    end
    % Quick growth times for all cell ends 
    GrTimes = [];
    for i = 1:length(TimeStartGrowth{i_cell})
        GrTimes = [GrTimes; TimeStartGrowth{i_cell}{i}(3)];
    end        
    Nb = length(find(GrTimes)); % Number of cell ends initiating quick growth
    if Nb == 1
        GrQuick = [GrQuick; max(GrTimes)];  % 'max'- to avoid the zero value
    end
    if Nb == 2
        Check = [Check; i_cell];        
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
X = 0:15:300;
[N, Xout] = hist(GrQuickFirstEnd, X);
% bar(Xout, N, [0.5 0.5 0.5], 'LineWidth', 0.1);
bar(Xout, N, 'FaceColor', [0.3 0.3 0.3], 'EdgeColor', [0.3 0.3 0.3], 'LineWidth', 0.1);
% xlabel('Quick growth initiation moment at old end, in minutes from GS release');
set(gca,'XTick',0:50:350)
xlabel('Beginning of P3 (min from SR)');
ylabel('N');
xlim([0 350]);

% figure, plot(GrQuickFirstEnd, 'ro');

%% Length of P3 (till cell division)
load('TimesStartGrowth_ManuallyCorrected.mat');
load('DivisionTimes.mat');

FromP3ToDivision = [];
for i_cell = 1:length(TimeStartGrowth) 
    if isempty(TimeStartGrowth{i_cell})
        continue
    end
    GrTimes = [];
    for i = 1:length(TimeStartGrowth{i_cell})
        GrTimes = [GrTimes; TimeStartGrowth{i_cell}{i}(3)];
    end        
    Nb = length(find(GrTimes)); % Number of cell ends initiating quick growth

    % For the length of P3: take into account the cells that don't have P4
    % (cells in which there is the beginning of P3 and then cell division)
    if (Nb == 1) && (DivisionTimes(i_cell,1) > 0)
        FromP3ToDivision = [FromP3ToDivision; DivisionTimes(i_cell,1) - max(GrTimes)];    
    end
end

%% Transform time points into minutes (from the release from starvation)
% GrQuickSecondEnd = (GrQuick - 1) * 3 + 10;
% NetoFromGrowthInit = NetoFromGrowthInit * 3;
FromP3ToDivision = FromP3ToDivision * 3;
%% Visualise
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
% ylim([0 15]);

%% Time of the beginning of cell division
Division = DivisionTimes(:,1);
Division = Division(find(Division));
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
% xlabel('Cell division (min from GS release)');
% ylabel('N');
xlim([0 408]);
ylim([0 15]);

