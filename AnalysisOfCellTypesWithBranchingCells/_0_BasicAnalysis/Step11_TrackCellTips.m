%% The task of the program is to assemble growth information for all cell
%% tips (track tips in time). Both 'CellEnds' and 'TipsLen' are rearranged 
close all
clear
% ---------------------------------
% Maximal distance between cell ends on different frames to be considered
% the same cell end
DistSameEnd = 30;
% ---------------------------------
load('_Output/AllCellEnds_2orMoreOfThem.mat');      % The name of the variable is 'CellEnds'
load('_Output/AllTipsLengths.mat');     % The name of the variable is 'TipsLen'

FinTipsLen = cell(size(TipsLen));
FinCellEnds = cell(size(TipsLen));

% % Find the length of the movie (number of frames)
% NbTimePts = 0;
% for i_cell = 1:length(CellEnds)
%     NbTimePts = max(NbTimePts, length(CellEnds{i_cell}));   % Some cells were not detected on last frames
% end

for i_cell = 1:length(CellEnds)
    EndNb = 0;      % Number of the current cell end
    % Number of time points for which the cell is detected
    NbTimePts = length(CellEnds{i_cell});
    % When a point is found, it is taken out of this matrix
    CE_Holes = CellEnds{i_cell};    % For one cell
    if isempty(CE_Holes)
        continue
    end
    while true
        % Find the beginning of a cell end track
        StartTime = 0;
        for i_t = 1:length(CE_Holes)
            if isempty(CE_Holes{i_t})
                continue
            end
            TrackPt = CE_Holes{i_t}(1,:);
            StartTime = i_t;            
            % Add the starting point of a track to the results matrix            
            EndNb = EndNb + 1;      % New cell end track started
            if EndNb == 1
                FinTipsLen{i_cell} = zeros(length(CE_Holes), 1);
                FinCellEnds{i_cell} = cell(length(CE_Holes), 1);
            end
            FinTipsLen{i_cell}(i_t, EndNb) = TipsLen{i_cell}{i_t}(1);
            FinCellEnds{i_cell}{i_t} = [FinCellEnds{i_cell}{i_t}; TrackPt];                        
            % Take off this point from the search matrix
            CE_Holes{i_t}(1,:) = [];
            TipsLen{i_cell}{i_t}(1) = [];
            break
        end
        if StartTime == 0   % Means that no other cell end is to be tracked for this cell
            break
        end
        % Tracking the cell end found over time
        for i_t = StartTime + 1:NbTimePts       % From the time next to the time of the beginning of the track   
            if isempty(CE_Holes{i_t})
                continue
            end
            Dist = [];
            for i_end = 1:size(CE_Holes{i_t}, 1)     % For all cell ends existing for the current cell at current time
                Dist = [Dist; sqrt((TrackPt(1) - CE_Holes{i_t}(i_end, 1)) .^ 2 + (TrackPt(2) - CE_Holes{i_t}(i_end, 2)) .^ 2)];
            end
            [Dist, ind] = min(Dist);            
            % Check if the found point is not too far from the previous
            % time point one (it can be the closest, but still a different
            % cell end)
            if Dist > DistSameEnd
                continue
            end
            TrackPt = CE_Holes{i_t}(ind, :);    % This is the cell end found on the current movie frame
            % Add the result of the tracking
            FinTipsLen{i_cell}(i_t, EndNb) = TipsLen{i_cell}{i_t}(ind);
            FinCellEnds{i_cell}{i_t} = [FinCellEnds{i_cell}{i_t}; TrackPt];
            % Delete this point from the pool of points to be tracked
            CE_Holes{i_t}(ind,:) = [];
            TipsLen{i_cell}{i_t}(ind) = [];             
        end
    end
end
% Save the results
save('_Output/AllCellEnds_Tracked.mat', 'FinCellEnds');      
save('_Output/AllTipsLengths_Tracked.mat', 'FinTipsLen');










