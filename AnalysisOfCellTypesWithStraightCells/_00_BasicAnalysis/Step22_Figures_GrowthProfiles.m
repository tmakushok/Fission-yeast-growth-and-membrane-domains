%% The task of the program is to plot TipsGrowth and find 
%% rates of growth and the moment when the growth starts. 
%% And also to find the width of intensity peaks at the moment when the tip starts to grow.
%% This program should receive the time point from which the movie was
%% started.
close all;
clear;
%--------------------------------------------------------------------------
% Threshold on difference in Y to determine if a point is an outlier
OutlierThres = 3.6;   
% The amount of data left after taking off the outliers should contain at
% least this amount of data points
PtsNbThres = 10;
% The amount of data left after taking off the outliers should correspond
% to at least that amount of time in its time point equivalent
TimeThres = 20;  % In time points
% Threshold on the minimal speed of growth to call a cell end
% growing (obsolete)
SpeedThres = 0;   % Pixels per time point
% Threshold on the minimal speed of growth to call a cell end
% growing quickly
BigSpeedThres = 0.8 / (20 * 0.0707);      % Threshold transformed to pixels per 3 minutes
% Which maximal distance away from the initial cell end position the point
% at the beginning is still considered as being part of the initial plateau
PlatThres = 1;    % Distance, in pixels
% The region of growth has to be at least this long in time points so
% that it can be considered safely as growing or quickly growing
PhaseTimeThres = 4;     % In time points
LastPhaseTimeThres = 10;    % If the last growth phase is shorter than that, ignore it
% How many times repeat MARS algorithm before choosing the best one with
% least-squares
RepeatMars = 10;
% File pathes
TipsLenFile = '_Output/AllTipsLengths.mat'; 
KymosFile = '_Output/AllKymographs.mat'; 
DivisionsFile = '_Output/_DivisionTimes_StartAndEnd.mat';
% Out_Dynamics = '_Output/AllEnds_GrowthDynamics.mat'; 
% Out_Times = '_Output/AllEnds_TimesStartGrowth.mat'; 
% Out_MARS = '_Output/AllEnds_MARSfitted.mat'; 
%--------------------------------------------------------------------------
load(TipsLenFile);
load(KymosFile);
load(DivisionsFile);
% Initialisation
Dynamics = cell(length(TipsLen), 1);
TipsLenMARS = cell(length(TipsLen), 1);
TimeStartGrowth = cell(length(TipsLen), 1);
CellsToTakeOff = [];

for i_cell = 1:length(TipsLen)       % Loop on cells
    i_cell
%     pause(0.1);
    close all;
%     Kymo = AllKymos{i_cell};
    if isempty(TipsLen{i_cell})     % if this cell was not considered
        continue
    end
    if isempty(AllKymos{i_cell})     % if this cell was not considered or taken out at the manual check
        continue
    end
    % Consider only the cells followed till division
    if DivisionTimes(i_cell,1) < 1    
        continue
    end
    
    TimePts = size(TipsLen{i_cell}, 1);   % Number of time points in the movie
    LengthAfterOut = []; 
    figure; % Will be used to plot both ends growth curves
    for i_end = 1:2        
%% Extracting the data to fit
        Y = TipsLen{i_cell}(:, i_end);
        X = (1:length(Y))';   
%% Take off zeros from the analysis
        [ind, b, Y] = find(Y);
        X = X(ind); 
        if X(1) ~= 1        % If no information for the first time point, do not analyse 
            continue
        end
%% Take off outliers from the analysis   
%         figure, plot(X, Y, 'ro'), hold on;
        [X, Y] = f_TakeOffOutliers(X, Y, OutlierThres);        
%         plot(X, Y, '-*'), grid on;
        % Saving
        LengthAfterOut(i_end) = max(X);
%         pause(0.5);
% %% Visualisation of the growth curve
%         figure, plot(X, Y, 'k-');
%         xlabel('Time, min');
%         ylabel('Length, µm');
%% Smoothing the curve      
%         figure, plot(X, Y, 'ro'), hold on;
        [X, Y] = f_CurveSmoothing(X,Y);
%         plot(X, Y, '-o'), grid on;  
%% Changing the units
        X = (X-1) * 3; % From the beginning of the movie, not from GS release
        Y = Y * 0.0707;        
%% Visualisation of the growth curve
        subplot(2,1,i_end);
        plot(X, Y, 'k-', 'LineWidth', 0.5);
        xlabel('Time, min');
        ylabel('Length, µm');
    end  
    %% Saving the plot into the tiff file
    width = 8;        % Width of the figure
    height = 6;         % Height of the figure

    set(gcf, 'PaperUnits', 'centimeters');
    papersize = get(gcf, 'PaperSize');

    left = (papersize(1)- width)/2;
    bottom = (papersize(2)- height)/2;

    FigureSize = [left, bottom, width, height];
    set(gcf, 'PaperPosition', FigureSize);

    print('-dtiff', '-r500', ['_Output/_GrowthProfiles_Cell_' int2str(i_cell)]);
end

