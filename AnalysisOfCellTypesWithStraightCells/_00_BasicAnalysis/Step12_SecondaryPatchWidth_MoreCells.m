%% The task of the program is measure width of SRM patch at slowly growing
%% cell end over time (only for cells growing quickly at one end 
%% and slowly at the other end)
close all;
clear;
%--------------------------------------------------------------------------
OutFile = '_Output/_SlowEndPatchWidthOverTime.mat';
OutEndsFile = '_Output/_SlowlyGrowingCellEnds.mat';
%--------------------------------------------------------------------------
load('_Output/AllKymographs.mat');     % Loads the matrix with kymographs
load('_Output/AllEnds_TimesStartGrowth.mat');    % Loads times of end of plateau, start of growth and start of quick growth
load('_Output/AllCellEnds.mat');        % Coordinates of cell ends over time         
load('_Output/AllContours.mat');        % Coordinates along all contours in time

%% The cells that were classified as unstable secondary patch cells
QuestionCells = [25];

PeaksWidths = cell(length(AllKymos), 1);
for i = 1:length(QuestionCells)       % Loop on cells
    i_cell = QuestionCells(i);
    i_cell
%     close all;
    Kymo = AllKymos{i_cell};
    % If the kymograph for this cell is anyway considered bad
    if isempty(Kymo) || isempty(TimeStartGrowth{i_cell})       
        AllPeaks{i_cell} = [];
%         continue
    end
    %% Choose the cell end corresponding to the slow growth (only in 'monopolar' cells)
%     GrTimes = [TimeStartGrowth{i_cell}{1}(3); TimeStartGrowth{i_cell}{2}(3)];
%     Nb = length(find(GrTimes)); % Number of cell ends initiating quick growth
%     % If the cell does not initiate quick growth or does NETO, do not consider it
%     if (Nb == 0) || (Nb == 2)
%         pause(0.1);
%     end
%     End = find(GrTimes == 0);       % Take the cell end that does not initiate quick growth
%     GrowEnd = find(GrTimes);        % Quickly growing end
        
    for i_t = 1:121      %max(TimeStartGrowth{i_cell}{GrowEnd}(3),1):size(AllContours, 2)       % From the moment of cell growth initiation till the end of the movie
        close all;
        Kymo_t = Kymo(i_t, :);        % One line of the kymo corresponding to the time point analysed
        % Taking off zeros at both sides of the actual intensity
        % profile
%             plot(Kymo_t, '-*'), grid on;
        Kymo_t = Kymo_t(find(Kymo_t))';
%             figure, plot(Kymo_t, '-*'), grid on;
        %% Coordinates of the current cell end 
        % The ones that were used to measure cell growth dynamics:
        CellEnds = AllCellEnds{i_cell, i_t};  % AllCellEnds{cellNb, Time} is [x1,y1,x2,y2]
        if isempty(CellEnds)    % To avoid weird problem
            continue
        end
        X_end = CellEnds(1 + 2*(End - 1));
        Y_end = CellEnds(2 + 2*(End - 1));
        % Translating the real coords into indexes along the intensity
        % profile
        Cont = AllContours{i_cell, i_t};      % 'Cont' is [Y, X]
        % Finding the point on the cell contour that is closest to the
        % current cell end
        [a, ind] = min(sqrt((Cont(:, 2) - X_end) .^ 2 + (Cont(:, 1) - Y_end) .^ 2));
        % If the intensity profile is open on this cell end, shift the
        % profile to have the cell end in the middle of the int. profile        
        Ind = ind;
        Shift = floor(size(Kymo_t, 1) / 2);
        % Because during kymo construction each profile was shifted, now
        % this operation has to be inversed.
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
        %% Finding the width of the peak corresponding to the current
        % cell end            
        PeaksWidths{i_cell}(i_t, 1) = f_Peak_CellEnd(Kymo_t, Ind); % First col- peak width, second- peak position        
%         pause(0.1);
    end    
%% Plot patch width behaviour for the current cell end
    Width = [];
    for i_t = 1:length(PeaksWidths{i_cell})
        if isempty(PeaksWidths{i_cell}(i_t).Width)
           continue 
        end
        Width(i_t) = PeaksWidths{i_cell}(i_t).Width;
    end
    figure, plot(Width, 'r*'), grid on;
%     pause(1);
%% Save the number of the cell end considered as the slowly growing one
    SlowEnds(i_cell,1) = End;
end
%% Output the result        
save(OutFile, 'PeaksWidths');
save(OutEndsFile, 'SlowEnds');



