%% The task of the program is to find for each time point to which cell on
%% previous frame each cell corresponds 
%% (result is in numbers of line in 'AllCellsPixels', each line = one cell, each column = frame number)
% ----------------------------
% Less that this distance should be between a cell center and initial
% cell center to be concidered the same cell
DistThres = 60;    
% ----------------------------

% load('_Output/output_CellsPixels.mat');
load('_Output/output_GoodCellsParams.mat');

%% !!! Use line numbers in resulting matrices instead of cell numbers in col 1

%% Initialise cell numbers with line numbers in 'AllCellsPixels'
% If a cell will be found next that does not belong to first frame's
% situation, it will not be added to analysed cells
CellsTrack = zeros(size(AllGoodCells{1}, 1), size(AllGoodCells, 1));
CellsTrack(:,1) = (1:size(AllGoodCells{1}, 1))';
% Extracting just cell numbers (1) and cell centers (col 5,6) from 'AllGoodCells' matrix
% 'GoodCells' contains:
%   CellNb|Cell_Lengths|Cell_Width|AxisAngle|Cell_Center:
%   x1|y1|Cell_Tips: x1|y1|x2|y2|Area   
Nbs_Centers_Ref = [AllGoodCells{1}(:,5), AllGoodCells{1}(:,6)];

%% For each cell center look to which cell it corresponded on previous
%% frame, starting from the cell number this line had on previous frame

%% Or find in the final list which cell center is the closest to initial
%% cell center
for i_t = 2:length(AllGoodCells)    % Loop on all time points but 1
    Nbs_Centers = [AllGoodCells{i_t}(:,5), AllGoodCells{i_t}(:,6)];
    for i_c = 1:size(Nbs_Centers, 1)         % Loop on cell centers (to find corresponding one)
        TheCenter = Nbs_Centers(i_c,:);
        Dist = sqrt((Nbs_Centers_Ref(:, 1) - TheCenter(1)) .^ 2 + (Nbs_Centers_Ref(:, 2) - TheCenter(2)) .^ 2);
        [Dmin, ind] = min(Dist); 
        if Dmin < DistThres
            CellsTrack(ind, i_t) = i_c;
        end
    end
end
save('_Output/output_CellsTracks.mat', 'CellsTrack');