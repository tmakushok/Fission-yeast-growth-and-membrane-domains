%% The task of the program is to find the cells that pause growth 
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
%--------------------------------------------------------------------------

load('Dynamics.mat');
PausingCells = [];

% The numbers of all cells that were classified manually as pausing growth
CellNbs = [190, 389, 466, 479, 548, 551, 555, 581, 592, 595, ...
    601, 606, 611, 654, 671, 672, 679, 681, 686, 694, 699, 704, 714, ...
    723, 732, 743, 744];

for i = 1:length(CellNbs)       % Loop on cells
    i_cell = CellNbs(i);
    close all;
    if isempty(Dynamics{i_cell})     % if this cell was not considered
        continue
    end
    for i_end = 1:2                  % Loop on cell ends
        % Dynamics of the current cell end
        Dyn_OneEnd = Dynamics{i_cell,1}{i_end};
        %% Finding the beginning of the fast growth for this end
        GrQuick = 0;  
        PhaseFast = 0;
        for i_k = 1:size(Dyn_OneEnd, 1)  % Loop on growth phases
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
                PhaseFast = i_k;    % Growth phase where starts the fast growth
                break
            end
        end 
        % If the cell end did not initiate fast growth at all
        % If the pause was not found, continue the search
        if PhaseFast == 0
            continue
        end                
        %% Finding the beginning of the pause
        PauseStart = 0;
        for i_k = PhaseFast:size(Dyn_OneEnd, 1) % Loop on growth phases starting with the starting fast growth phase
            Speed = Dyn_OneEnd(i_k, 3);
            if Speed < BigSpeedThres
%                 % Check if it is not a short phase
%                 PhaseLen = Dyn_OneEnd(i_k, 2) - Dyn_OneEnd(i_k, 1);
%                 if ~(i_k == size(Dyn_OneEnd, 1)) && (PhaseLen < PhaseTimeThres)
%                     continue
%                 end
                PauseStart = Dyn_OneEnd(i_k, 1);   % Time of the beginning of this quick phase of growth                              
                break
            end
        end 
        % If the pause was not found, continue the search
        if PauseStart == 0
            continue
        end
        %% Finding the end of the pause
        PauseEnd = 0;
        for i_k = PauseStart+1:size(Dyn_OneEnd, 1) % Loop on growth phases starting with the starting pause phase + 1
            Speed = Dyn_OneEnd(i_k, 3);
            if Speed > BigSpeedThres
                PauseEnd = Dyn_OneEnd(i_k, 1);   % Time of the beginning of this quick phase of growth                              
                break
            end
        end 
%         % If the end of the pause is not found, we discard it
%         if PauseEnd == 0
%             continue
%         end        
        %% Saving the data about the pause:
        % Contains the number of the cell pausing growth 
        % and the number of the cell end
        % and the time of the beginning of fast growth
        % and the beginning of the pause
        % and the end of the pause
        PausingCells = [PausingCells; i_cell, i_end, GrQuick, PauseStart, PauseEnd];      
    end
end
