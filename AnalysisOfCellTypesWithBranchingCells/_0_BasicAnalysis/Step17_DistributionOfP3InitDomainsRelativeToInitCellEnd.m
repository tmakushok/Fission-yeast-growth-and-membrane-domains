%% The task of the program is measure widthes of SRM patches at the moments
%% of cell growth start and cell growth change (these moments are determined 
%% in the function 'Step11_GrowthAnalysis_MARS.m')
close all;
clear;
%--------------------------------------------------------------------------
OutFile = '_Output/_WidthAndPosAtP3Init.mat';
%--------------------------------------------------------------------------
load('_Output/AllKymographs.mat');     % Loads the matrix with kymographs
load('_Output/AllEnds_TimesStartGrowth.mat');    % Loads times of end of plateau, start of growth and start of quick growth
load('_Output/AllCellEnds_Tracked.mat');        % Coordinates of cell ends over time         
load('_Output/AllContours.mat');        % Coordinates along all contours in time
AllCellEnds = FinCellEnds;

AllPeaks = cell(length(AllKymos), 1);


for i_cell = 1:length(AllKymos)       % Loop on cells
    i_cell
%     close all;
    Kymo = AllKymos{i_cell};
    % If the kymograph for this cell is anyway considered bad
    if isempty(Kymo) || isempty(TimeStartGrowth{i_cell})       
        AllPeaks{i_cell} = [];
        continue
    end
    Peaks = zeros(size(Kymo,1), 2);
        
    for i_end = 1:length(TimeStartGrowth{i_cell})        
        for i_t = 3:3       % Gives access to one of the three moments of cell growth history
            close all;
            % If there is no info about growth of the cell end
            if (TimeStartGrowth{i_cell}{i_end} == 0)
                continue
            end
            t = TimeStartGrowth{i_cell}{i_end}(i_t);    % Real time point when the growth event happened
            if t == 0   % If no such growth phase was detected
                Peak.Width = -2;
                Peak.PositionOfPeakCenter = -2;     
                Peak.DistFromCEnd = -2;
                Peak.MaxIntens = -2;   
                AllPeaks{i_cell}{i_end}(i_t) = Peak;
                continue
            end
            Kymo_t = Kymo(t, :);        % One line of the kymo corresponding to the time point analysed
            % Taking off zeros at both sides of the actual intensity
            % profile
%             plot(Kymo_t, '-*'), grid on;
            Kymo_t = Kymo_t(find(Kymo_t))';
%             figure, plot(Kymo_t, '-*'), grid on;
            %% Coordinates of the current cell end 
            % The ones that were used to measure cell growth dynamics:
            CellEnds = AllCellEnds{i_cell}{t};  % AllCellEnds{cellNb, Time} is [x1,y1,x2,y2]
            if isempty(CellEnds)    % To avoid weird problem
                continue
            end
            X_end = CellEnds(i_end, 1);
            Y_end = CellEnds(i_end, 2);
            % Translating the real coords into indexes along the intensity
            % profile
            Cont = AllContours{i_cell, t};      % 'Cont' is [Y, X]
            % Finding the point on the cell contour that is closest to the
            % current cell end
            [a, ind] = min(sqrt((Cont(:, 2) - X_end) .^ 2 + (Cont(:, 1) - Y_end) .^ 2));
            % If the intensity profile is open on this cell end, shift the
            % profile to have the cell end in the middle of the int. profile
            Ind = ind;
            Shift = round(size(Kymo_t, 1) / 2);
%             % Because during kymo construction each profile was shifted, now
%             % this operation has to be inversed.
            
            Kymo_t = circshift(Kymo_t, -Shift);   
            
            if ind < 50     % The index is close to the beginning of the profile
                Kymo_t = circshift(Kymo_t, Shift);
                % Changing the value of the index to correspond to the shifted
                % intensity profile
                Ind = ind + Shift;
            elseif ind > length(Kymo_t) - 50      % The index is close to the end of the profile
                Kymo_t = circshift(Kymo_t, -Shift);
                % Changing the value of the index to correspond to the shifted
                % intensity profile
                Ind = ind - Shift;
            end            
%             figure, plot(Kymo_t, '-*'), grid on;            
            %% Finding the width and position of the peak corresponding to the current cell end            
            Peaks = f_Peak_CellEnd_SignedPos(Kymo_t, Ind); % First col- peak width, second- peak position, third- normalized domain position        
            %% If the domain is at the third (newly formed) cell end, find the along-the-perimeter distance from domain center to one of the initial cell ends
            if (i_end == 3)
                DistToEnd1 = sqrt((CellEnds(1, 1) - X_end) .^ 2 + (CellEnds(1, 2) - Y_end) .^ 2);
                DistToEnd2 = sqrt((CellEnds(2, 1) - X_end) .^ 2 + (CellEnds(2, 2) - Y_end) .^ 2);
                if DistToEnd1 < DistToEnd2   % Cell end 1 is closer to the newly forming cell end
                    X_end1 = CellEnds(1, 1);
                    Y_end1 = CellEnds(1, 2);
                else
                    X_end1 = CellEnds(2, 1);
                    Y_end1 = CellEnds(2, 2);
                end                
                [a, Pos1] = ismember([Y_end1, X_end1], Cont, 'rows');   % Closest of the initial cell ends
                [a, Pos2] = ismember([Y_end, X_end], Cont, 'rows');     % Newly forming end
                % Go from the position of the newly forming end to the
                % position of the domain center
                Peaks.DistFromClosestCEnd = Peaks.DistFromCEnd; 
                Pos2 = Pos2 + Peaks.DistFromCEnd;
                if abs(Pos2 - Pos1) < size(Cont,1)/2  % Dealing with the fact that the two positions can be too close to the top and bottom of 'Cont'
                    Peaks.DistFromCEnd = abs(Pos2 - Pos1);
                else
                    Peaks.DistFromCEnd = size(Cont,1) - abs(Pos2 - Pos1) + 1;
                end                                
            end
            %% Current edges of the kymo line are already at a cell end, so direct normalization to the outline length is possible
            KymoLen = length(Kymo_t); 
            Peaks.DistFromCEnd = abs(Peaks.DistFromCEnd);
            Peaks.NormPos = Peaks.DistFromCEnd / (KymoLen / 4);      % So that PosNorm = 0 at ane of the cell ends and =1 at the cell middle
            
%             if Peaks.NormPos > 1
%                 figure;
%             end
            
            Peaks.CellPerimeter = KymoLen;
            Peaks.TimePoint = t;
            AllPeaks{i_cell}{i_end}(i_t) = Peaks; % First col- peak width, second- peak position, third- normalized domain position   
            i_cell
            Peaks
        end    
    end
%     plot(AllPeaks{i_cell,1}(:,1), '-*'), grid on;
end
%% Output the result        
save(OutFile, 'AllPeaks');



