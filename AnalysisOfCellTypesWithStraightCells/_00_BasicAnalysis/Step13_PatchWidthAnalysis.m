%% The task of the program is measure widthes of SRM patches at the moments
%% of cell growth start and cell growth change (these moments are determined 
%% in the function 'Step11_GrowthAnalysis_MARS.m')
close all;
clear;
%--------------------------------------------------------------------------
OutFile = '_Output/_CEndPatchesAtGrowthTimes.mat';
%--------------------------------------------------------------------------
load('_Output/AllKymographs.mat');     % Loads the matrix with kymographs
load('_Output/AllEnds_TimesStartGrowth.mat');    % Loads times of end of plateau, start of growth and start of quick growth
load('_Output/AllCellEnds.mat');        % Coordinates of cell ends over time         
load('_Output/AllContours.mat');        % Coordinates along all contours in time

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
    for i_end = 1:2
        for i_t = 1:3       % Gives access to one of the three moments of cell growth history
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
            CellEnds = AllCellEnds{i_cell, t};  % AllCellEnds{cellNb, Time} is [x1,y1,x2,y2]
            if isempty(CellEnds)    % To avoid weird problem
                continue
            end
            X_end = CellEnds(1 + 2*(i_end - 1));
            Y_end = CellEnds(2 + 2*(i_end - 1));
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
            AllPeaks{i_cell}{i_end}(i_t) = f_Peak_CellEnd(Kymo_t, Ind); % First col- peak width, second- peak position        
%             pause(0.5);
        end    
    end
%     plot(AllPeaks{i_cell,1}(:,1), '-*'), grid on;
end
%% Output the result        
save(OutFile, 'AllPeaks');




%% BackUp
% Check if this particular time point is represented in the
% kymo
% if isempty(find(Kymo_t))
%     AllPeaks{i_cell}(i_t,:) = [0,0];
%     continue;
% end



