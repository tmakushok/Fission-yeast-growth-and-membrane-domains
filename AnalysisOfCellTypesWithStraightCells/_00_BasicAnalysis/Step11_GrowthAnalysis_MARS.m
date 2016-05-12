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
% KymosFile = '_Output/AllKymographs.mat'; 
Out_Dynamics = '_Output/AllEnds_GrowthDynamics.mat'; 
Out_Times = '_Output/AllEnds_TimesStartGrowth.mat'; 
Out_MARS = '_Output/AllEnds_MARSfitted.mat'; 
%--------------------------------------------------------------------------
load(TipsLenFile);
load(KymosFile);
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
    TimePts = size(TipsLen{i_cell}, 1);   % Number of time points in the movie
    LengthAfterOut = []; 
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
        figure, plot(X, Y, 'ro'), hold on;
        [X, Y] = f_TakeOffOutliers(X, Y, OutlierThres);        
        plot(X, Y, '-*'), grid on;
        % Saving
        LengthAfterOut(i_end) = max(X);
%         pause(0.5);
%% Checking if enough points left after taking off outliers 
%% if not- taking off the entire cell (after the loop)
        if (length(X) < PtsNbThres) || (X(length(X)) < TimeThres)
            CellsToTakeOff = [CellsToTakeOff; i_cell];
        end
%% Smoothing the curve      
        figure, plot(X, Y, 'ro'), hold on;
        [X, Y] = f_CurveSmoothing(X,Y);
        plot(X, Y, '-o'), grid on;             
%% Defining if the end is non-growing 
% Definition of non-growing: global growth was smaller than 
% Total_number_of_time_points * 'SpeedThres' pixels
%         GrowthFlag = 1;
%         if (range(Y)) < SpeedThres * TimePts
%             % Output data is: [starting time of a growth phase, 
%             % ending time of a growth phase, growth speed]
%             Dynamics{i_cell,1}{i_end} = [1, TimePts, 0];
%             GrowthFlag = 0;
%         end
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
        Dynamics{i_cell,1}{i_end} = Dyn_OneEnd;
        TipsLenMARS{i_cell,1}{i_end} = [X, Mars];
%% Extract information about when the cell end starts to grow
%         if GrowthFlag == 0   % non-growing
%             TimeStartGrowth{i_cell,1}{i_end} = 0;
%         else      % growing
%% 1) Is there a plateau at the beginning when the cell end does not grow at all?
        % Plateau is defined as points at the beginning of the movie at
        % max 'PlatThres' distance from the initial position of the cell end
        TGr_OneEnd = [];
        PlatEnd = 1;
        for i_pl = 2:length(Y)
            if abs(Y(i_pl) - Y(1)) <= PlatThres
                PlatEnd = i_pl;
            else 
                break
            end                    
        end
%% 2) When is the phase of the cell end growing too slowly to be considered
%% growing
        GrStart = 1;
        for i_k = 1:size(Dyn_OneEnd, 1)
            Speed = Dyn_OneEnd(i_k, 3);
            if Speed > SpeedThres
                % Check if it is not a small bit going up with
                % next one going too slow to be called growing (except
                % for the last phase of growth)
                PhaseLen = Dyn_OneEnd(i_k, 2) - Dyn_OneEnd(i_k, 1);
                if ~(i_k == size(Dyn_OneEnd, 1)) && (PhaseLen < PhaseTimeThres) && (Dyn_OneEnd(i_k + 1, 3) < SpeedThres)
                    continue
                end
                GrStart = Dyn_OneEnd(i_k, 1);   % Time of the beginning of this phase of growth                
                break
            end
        end
        % Visualisation
        plot(GrStart, Y(find(X == GrStart)), 'gd', 'MarkerSize', 11, 'MarkerFaceColor', 'g');
%% 3) When does the cell start to grow quickly
        GrQuick = 0;        
        for i_k = 1:size(Dyn_OneEnd, 1)
            Speed = Dyn_OneEnd(i_k, 3);
            if Speed > BigSpeedThres
                % Check if it is not a small bit going up quickly with
                % next one going too slow to be called quick (except for the last phase of growth)
                PhaseLen = Dyn_OneEnd(i_k, 2) - Dyn_OneEnd(i_k, 1);
                if ~(i_k == size(Dyn_OneEnd, 1)) && (PhaseLen < PhaseTimeThres) && (Dyn_OneEnd(i_k + 1, 3) < BigSpeedThres)
                    continue
                end
                % If it is the last growth phase, ignore it if the phase is short (too many chances it's a mistake)
                if (i_k == size(Dyn_OneEnd, 1)) && (PhaseLen < LastPhaseTimeThres) 
                    break
                end
                
                GrQuick = Dyn_OneEnd(i_k, 1);   % Time of the beginning of this quick phase of growth               
                % Visualisation
                plot(GrQuick, Y(find(X == GrQuick)), 'rd', 'MarkerSize', 11, 'MarkerFaceColor', 'r'); 
                break
            end
        end                       
%% Putting the time results together:
%% 1st column: time point when the distance from the cell end to its
%% initial position becomes bigger than 'PlatThres'
%% 2nd column: time point when the speed of growth becomes bigger than
%% 'SpeedThres' (cell starts to grow slowly)
%% 3rd column: time point when the speed of growth becomes bigger than
%% 'BigSpeedThres' (cell starts to grow quickly)
        TimeStartGrowth{i_cell,1}{i_end} = [PlatEnd, GrStart, GrQuick];
%         pause(1);
    end  
%% Take off the growth time values that are above the outlyers cut-off
%% (from both cell ends): growth detected after cell divided, for example
    % For cell end one
    CutOff = find(TimeStartGrowth{i_cell,1}{1} > min(LengthAfterOut));
    if ~isempty(CutOff)
        TimeStartGrowth{i_cell,1}{1}(CutOff) = 0;
    end  
    % For cell end two    
    CutOff = find(TimeStartGrowth{i_cell,1}{2} > min(LengthAfterOut));
    if ~isempty(CutOff)
        TimeStartGrowth{i_cell,1}{2}(CutOff) = 0;
    end         
%% Take off growth dynamics values that are above the outlyers cut-off
%% (from both cell ends): growth detected after cell divided, for example
    % For cell end one
    CutOff = find(Dynamics{i_cell,1}{1}(:,1) > min(LengthAfterOut) );
    if ~isempty(CutOff)
        Dynamics{i_cell,1}{1}(CutOff,:) = [];
    end  
    % For cell end two   
    CutOff = find(Dynamics{i_cell,1}{2}(:,1) > min(LengthAfterOut) );
    if ~isempty(CutOff)
        Dynamics{i_cell,1}{2}(CutOff,:) = [];
    end      
end
%% Take off from the results the cells that were not considered good
CellsToTakeOff = unique(CellsToTakeOff);
for i = length(CellsToTakeOff):-1:1
    Dynamics{CellsToTakeOff(i)} = [];
    TimeStartGrowth{CellsToTakeOff(i)} = [];
end
%% Output the results        
save(Out_Dynamics, 'Dynamics');
save(Out_Times, 'TimeStartGrowth');
save(Out_MARS, 'TipsLenMARS');




