%% The task of the function is to visualise the position of each cell end
%% found for a / some time point / -s of a movie
clear;

load('_Output/AllCellEnds_2orMoreOfThem.mat');
for i_t = 33:33
    load('_InputImages/REG_BF_AVG_Experiment_Pos004_S001_t32.mat');
    figure, imshow(RegIm, []);
    for i_cell = 1:length(CellEnds)
        if isempty(CellEnds{i_cell})
            continue
        end
        for i_end = 1:size(CellEnds{i_cell}{i_t}, 1)
            x = CellEnds{i_cell}{i_t}(i_end, 1);
            y = CellEnds{i_cell}{i_t}(i_end, 2);
            text(x, y, 'x', 'FontWeight', 'bold', 'FontSize', 11);
        end
    end
end