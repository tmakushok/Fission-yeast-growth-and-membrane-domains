%% The task of the program is to find for each time point to which cell
%% number on previous frame each cell corresponds 

% Result is the matrix with numbers of lines of 'AllGoodCells' matrix
% Structure of 'AllGoodCells' matrix is: lines = cell numbers, columns = frame numbers

% NB: cells that were not detected on the first time point are not
% considered even if they were well detected on subsequent frames

% --------------------------------------------------------
% Less than this distance should be between the cell center of one cell and 
% initial cell center of the other cell to conclude that the two are the same cell
DistThres = 60;    % Distance threshold, in pixels, the value depends on typical cell diameter
% --------------------------------------------------------
load('_Output/output_GoodCellsParams.mat');     % The name of the variable loaded is 'AllGoodCells'

%% Initialise cell numbers with line numbers in 'AllGoodCells' 
%% (for the first time point)
CellsTrack = zeros(size(AllGoodCells{1}, 1), size(AllGoodCells, 1));    % Lines are cell numbers, columns are time points
CellsTrack(:,1) = (1:size(AllGoodCells{1}, 1))';        
% Extracting just cell numbers (column 1) and cell centers (columns 5 and 6) from 'AllGoodCells' matrix
% 'AllGoodCells' contains this information:
%   CellNb|Cell_Lengths|Cell_Width|AxisAngle|Cell_Center:
%   x1|y1|Cell_Tips: x1|y1|x2|y2|Area   
Nbs_Centers_Ref = [AllGoodCells{1}(:,5), AllGoodCells{1}(:,6)]; % Reference: centers of all cells for the first time point

%% Find in the final list which cell center is the closest to initial
%% cell center
for i_t = 2:length(AllGoodCells)    % Loop on all time points but the first one
    Nbs_Centers = [AllGoodCells{i_t}(:,5), AllGoodCells{i_t}(:,6)]; % Centers of all cells for the current time point
    for i_c = 1:size(Nbs_Centers, 1)        % Loop on cell centers (to find corresponding number for each cell)
        TheCenter = Nbs_Centers(i_c,:);     % The center of the current cell
        % Creating the matrix of distances between the center of the
        % current cell and all the centers of 'reference' cells to find
        % minimal distance
        Dist = sqrt((Nbs_Centers_Ref(:, 1) - TheCenter(1)) .^ 2 + (Nbs_Centers_Ref(:, 2) - TheCenter(2)) .^ 2);
        [Dmin, ind] = min(Dist); 
        if Dmin < DistThres     % Ths test is necessary in case the current cell was not detected at the first time point
            CellsTrack(ind, i_t) = i_c;
        end
    end
end
% Save the result
save('_Output/output_CellsTracks.mat', 'CellsTrack');