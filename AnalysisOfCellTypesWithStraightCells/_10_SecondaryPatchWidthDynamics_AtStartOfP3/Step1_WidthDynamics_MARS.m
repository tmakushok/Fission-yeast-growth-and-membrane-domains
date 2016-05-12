%% The task of the program is to analyse cell width dynamics. 
close all;
clear;
%--------------------------------------------------------------------------
% Threshold on difference in Y to determine if a point is an outlier
OutlierThres = 20;   
% The amount of data left after taking off the outliers should contain at
% least this amount of data points
PtsNbThres = 15;
% The amount of data left after taking off the outliers should correspond
% to at least that amount of time in its time point equivalent
TimeThres = 45;  % In time points
% Threshold on the minimal speed of growth to call a cell end
% growing (obsolete)
SpeedThres = 0.1;   % Pixels per time point
% Threshold on the minimal speed of growth to call a cell end
% growing quickly
% BigSpeedThres = 1.065 / (20 * 0.0707);      % Threshold transformed to pixels per 3 minutes
% Which maximal distance away from the initial cell end position the point
% at the beginning is still considered as being part of the initial plateau
PlatThres = 1;    % Distance, in pixels
% The region of growth has to be at least this long in time points so
% that it can be considered safely as growing or quickly growing
PhaseTimeThres = 5;     % In time points
% How many times repeat MARS algorithm before choosing the best one with
% least-squares
RepeatMars = 10;
% File pathes
% TipsLenFile = '_Output/AllTipsLengths.mat'; 
% KymosFile = '_Output/AllKymographs.mat'; 
% Out_Dynamics = 'WidthDynamics.mat'; 
% Out_Times = '_Output/AllEnds_TimesStartGrowth.mat'; 
%--------------------------------------------------------------------------
load('SecondaryPatchWidths_AllMovies.mat');
% Initialisation
Dynamics_Phases = cell(length(PeaksWidthsAll), 1);
MarsCurves = cell(length(PeaksWidthsAll), 1);
% TipsLenMARS = cell(length(PeaksWidthsAll), 1);
TimeStartGrowth = cell(length(PeaksWidthsAll), 1);
CellsToTakeOff = [];

for i_cell = 1:length(PeaksWidthsAll)       % Loop on cells
    i_cell
%     pause(0.1);
    close all;
%     Kymo = AllKymos{i_cell};
    if isempty(PeaksWidthsAll{i_cell})     % if this cell was not considered
        continue
    end
    TimePts = size(PeaksWidthsAll{i_cell}, 1);   % Number of time points during which the cell was followed
         
%% Extracting the data to fit
    Y = [];
    for i_t = 1:TimePts
        if isempty(PeaksWidthsAll{i_cell}(i_t).Width)
           continue 
        end
        Y(i_t, 1) = PeaksWidthsAll{i_cell}(i_t).Width;
    end
%     figure, plot(Y, 'r*')
    
    X = (1:length(Y))';   
%% Take off zeros from the analysis
    % Take off undetected patches represented by '-1s'
    Y(Y == -1) = 0;
    [ind, b, Y] = find(Y);
    X = X(ind);    
%% Take off outliers from the analysis   
    figure, plot(X, Y, 'ro'), hold on;
    [X, Y] = f_TakeOffOutliers(X, Y, OutlierThres);        
    plot(X, Y, '-*'), grid on;

%         pause(0.5);
%% Checking if enough points left after taking off outliers 
%% and if the last point is late enough
    if (length(X) < PtsNbThres) || (X(length(X)) < TimeThres)
        continue;
    end
%% Smoothing the curve      
    figure, plot(X, Y, 'ro'), hold on;
    [X, Y] = f_CurveSmoothing(X,Y);
    plot(X, Y, '-o'), grid on;             
%% Fitting with MARS 
%% Do it several times and choose the best regression best on least-squares
%% approach              
    Knots = cell(RepeatMars, 1);
    Mars = cell(RepeatMars, 1);
    for i_rep = 1:RepeatMars
        ens = ares;
        % Get the default training parameter and modify the number of training partitions
        % (enstrainparams.nr cv partitions):
        enstrainparams = get(ens, 'trainparams');
        % Allow only linear piece-wise model
        enstrainparams.max_interactions = 0;
        % Train the ensemble:
        ens = train(ens, X, Y, [], enstrainparams, 0.05);           
        % Extracting the results
        Knots{i_rep} = get(ens, 'splitsites');  
        % Obtain the result of the regression
        Mars{i_rep} = calc(ens, X);
        % The aim is to minimize the sum of squares of residuals
        SqSum(i_rep) = sum((Y - Mars{i_rep}).^2);
        % Visualisation
%             figure, plot(X, Mars{i_rep});
%             grid on, hold on;
%             plot(X, Y, 'ro')
    end
    % Minimize the sum of squares of residuals and extract the result
    [a, ind] = min(SqSum);
    Knots = Knots{ind};
    Mars = Mars{ind};
    % ????????? Combine together regions with small differences in
    % slopes (not to have too many regions without biological
    % meaning)        

    % Visualisation of the final regression
    figure, plot(X, Mars);
    grid on, hold on;
    plot(X, Y, 'ro')
%% Put the results together        
    % Sort knots in ascending way and take off repeating values
    Knots = unique([Knots{:}])';
    % Add first and last time points where the cell was detected
    Knots = [X(1); Knots; X(length(X))];
    Dyn_OneEnd = zeros(length(Knots) - 1, 3);
    for i_ph = 1:length(Knots) - 1      % Loop on phases of growth
        t_st = Knots(i_ph);
        t_end = Knots(i_ph + 1);
        % Indexes corresponding to 't_st' and 't_end'
        ind_st = find(X == t_st);
        ind_end = find(X == t_end);
        Speed = (Mars(ind_end) - Mars(ind_st)) / (t_end - t_st);
        Dyn_OneEnd(i_ph, :) = [t_st, t_end, Speed];    % Speed is in pixels per 3 minutes             
    end
    Dynamics_Phases{i_cell,1} = Dyn_OneEnd;
    MarsCurves{i_cell,1} = [X, Mars];
    TimeCellGrowthInit(i_cell,1) = X(1);
    pause(1);  
end
%% Output the results        
% save(Out_Dynamics, 'Dynamics');
% save(Out_Times, 'TimeStartGrowth');




