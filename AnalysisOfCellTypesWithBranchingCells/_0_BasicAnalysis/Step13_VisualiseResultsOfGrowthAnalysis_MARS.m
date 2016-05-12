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
%% Create a list of cell ends that were detected for this cell    
    GoodEnds = 1:length(Gr);    % Ends for which growth was detected
    for i_end = length(Gr):-1:1
        if max(Gr{i_end}) == 0 || max(isnan(Gr{i_end})) == 1
        	GoodEnds(i_end) = [];
        end        
    end
    if isempty(GoodEnds)   
        continue
    end            
%% Accumulate numbers for end of plateau time (minimum out of the two cell ends)
    AllPlat = [];
    for i = 1:length(GoodEnds)
        AllPlat = [AllPlat; Gr{GoodEnds(i)}(1)];
    end
    AllPlat = AllPlat(find(AllPlat));   % Take off occasional zeros
    Plat = [Plat; min(AllPlat)];
%% Accumulate numbers for start of slow growth time (minimum out of the two cell ends)
    AllSlow = [];
    for i = 1:length(GoodEnds)
        AllSlow = [AllSlow; Gr{GoodEnds(i)}(2)];
    end
    AllSlow = AllSlow(find(AllSlow));   % Take off occasional zeros
    Slow = [Slow; min(AllSlow)];
%% Accumulate numbers for start of fast growth time (minimum out of the two cell ends)
    AllQuick = [];
    for i = 1:length(GoodEnds)
        AllQuick = [AllQuick; Gr{GoodEnds(i)}(3)];
    end
    AllQuick = AllQuick(find(AllQuick));   % Take off occasional zeros
    Quick = [Quick; min(AllQuick)];
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




