%% The task of the program is measure and analyse the width of SRM patch 
%% for each growth phase to correlate it later with the speed of growth
%% From the beginning of the movie till the end of the 'Dynamics' data
%% (should be till cell division only)
close all;
clear;
%--------------------------------------------------------------------------
OutFile = '_Output/_AveragePatchWidth_PhaseGrowthSpeed.mat';
%--------------------------------------------------------------------------
load('_Output/AllKymographs.mat');     % Loads the matrix with kymographs
load('_Output/AllEnds_GrowthDynamics.mat');    
load('_Output/AllCellEnds.mat');        % Coordinates of cell ends over time         
load('_Output/AllContours.mat');        % Coordinates along all contours in time

PeaksWidths = [];
PeakTimes = [];
WidthsAver_Speed = [];
for i_cell = 1:length(AllKymos)       % Loop on cells
    i_cell
%     close all;
    Kymo = AllKymos{i_cell};
    % If the kymograph for this cell is anyway considered bad
    if isempty(Kymo)             
        continue
    end
    for i_end = 1:2
        if isempty(Dynamics{i_cell})                 
            continue
        end        
        Dyn_OneEnd = Dynamics{i_cell}{i_end}; % Dynamics data for one cell end
        
        for i_ph = 1:size(Dyn_OneEnd, 1)  % Loop on phases of growth
            for i_t = Dyn_OneEnd(i_ph,1):Dyn_OneEnd(i_ph,2)   % From the beginning till the end of the growth phase 
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
                X_end = CellEnds(1 + 2*(i_end - 1));
                Y_end = CellEnds(2 + 2*(i_end - 1));
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
                PeaksWidths = [PeaksWidths; f_Peak_CellEnd(Kymo_t, Ind)]; % First col- peak width, second- peak position        
                PeakTimes = [PeakTimes; i_t];
        %         pause(0.1);
            end 
            %% Visualise patch width over the time of the growth phase
%             figure, plot(PeakTimes, [PeaksWidths.Width], 'r*')        
            %% Averaging of the patch width over the time of the growth phase
            %% Saving average width of the patch with the corresponding speed
            %% of growth and the time span of the growth phase 
            %% and the number of width points that were used
            %% and the slope of patch width variation
            p = polyfit(PeakTimes', [PeaksWidths.Width], 1);
%             hold on, plot(PeakTimes, polyval(p, PeakTimes));
            WidthsAver_Speed = [WidthsAver_Speed; mean([PeaksWidths.Width]), median([PeaksWidths.Width]), Dyn_OneEnd(i_ph,3), Dyn_OneEnd(i_ph,2) - Dyn_OneEnd(i_ph,1) + 1, length(PeaksWidths), p(1)];
            PeaksWidths = []; % Reinitialise  
            PeakTimes = [];
%             pause(0.5);
        end
    end
end
%% Output the result        
save(OutFile, 'WidthsAver_Speed');




