%% The task of the program is to track cell tips growth (the two tips often grow differently)
close all;
clear;
%--------------------------------------------------------------------------
AllEndsFile = '_Output/AllCellEnds.mat';
AllKymosFile = '_Output/AllKymographs.mat'; 
AllGoodCellsFile = '_Output/output_GoodCellsParams.mat'; 
Out_TipsLenFile = '_Output/AllTipsLengths.mat'; 
%--------------------------------------------------------------------------
load(AllEndsFile);
load(AllKymosFile); 
load(AllGoodCellsFile); 
TipsLen = cell(size(AllCellEnds, 1), 1);
for i_cell = 1:size(AllCellEnds, 1)       % Loop on cells
    if isempty(AllKymos{i_cell})        % If the kymograph for this cell is anyway considered bad
        continue
    end
    CellEnds = AllCellEnds(i_cell, :);      % Cell end coords for all time points
    Center = AllGoodCells{1,1}(i_cell, 5:6);    
    for i_t = 1:length(CellEnds)        % Loop on time points
        EndsT = CellEnds{i_t};
        if isempty(EndsT)        % If the cell was not detected at that time point
            TipsLen{i_cell}(i_t, 1) = 0;
            TipsLen{i_cell}(i_t, 2) = 0; 
            continue
        end
        % Distances between initial cell center and each of the tips
        D1 = sqrt((EndsT(1) - Center(1)) .^ 2 + (EndsT(2) - Center(2)) .^ 2);
        D2 = sqrt((EndsT(3) - Center(1)) .^ 2 + (EndsT(4) - Center(2)) .^ 2);
        % Accumulation of the distances for the current cell
        TipsLen{i_cell}(i_t, 1) = D1;
        TipsLen{i_cell}(i_t, 2) = D2;        
    end
end
%% Output the result        
save(Out_TipsLenFile, 'TipsLen');  