% clear;
% close all;

load('_Output/AllEnds_TimesStartGrowth.mat');

Plat = [];
Slow = [];
Quick = [];
for i_c = 1:length(TimeStartGrowth)
    Gr = TimeStartGrowth{i_c};
    if isempty(Gr)      % Kymo for this cell was not concidered good
        continue
    end
    if Gr{1} == 0       % If one of the two cell ends was not growing
        if Gr{2} == 0   % The case when both cell ends did not grow
            continue
        end
        Gr{1} = Gr{2};  % Artificial, to have 'min' working
    end
    if Gr{2} == 0
        Gr{2} = Gr{1};
    end
%% Accumulate numbers for end of plateau time (minimum out of the two cell ends)
    Plat = [Plat; min(Gr{1}(1), Gr{2}(1))];
%% Accumulate numbers for start of slow growth time (minimum out of the two cell ends)
    Slow = [Slow; min(Gr{1}(2), Gr{2}(2))];
%% Accumulate numbers for start of fast growth time (minimum out of the two cell ends)
    Quick = [Quick; min(Gr{1}(3), Gr{2}(3))];
end
%% Plot all the values
% X = (1:length(Plat))' * 3 + 7;
figure, 
[N, Xout] = hist(Plat, 20);
bar(Xout * 3 + 7, N);
xlabel('End of plateau, in minutes');
ylabel('N');

figure, 
[N, Xout] = hist(Slow, 20);
bar(Xout * 3 + 7, N);
xlabel('Start of slow growth, in minutes');
ylabel('N');

figure, 
[N, Xout] = hist(Quick(find(Quick)), 20);     % Plot the values only for cells that do grow quickly at some point
bar(Xout * 3 + 7, N);
xlabel('Start of quick growth, in minutes');
ylabel('N');
%% Determining the proportion of cells that do initiate quick growth
ProporQuickGrowth = length(find(Quick)) / length(Quick);




