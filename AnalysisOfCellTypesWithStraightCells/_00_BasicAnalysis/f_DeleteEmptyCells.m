%% The task of the function is to 'clean' a cell array: take off from
%% columns empty cells
function [Adel] = f_DeleteEmptyCells(A)
Adel = {};
for i_col = 1:size(A,2)     % Loop on columns
    NewCol = {};
    for i_lin = 1:size(A,1)     % Loop on lines
        if ~isempty(A{i_lin, i_col})
            NewCol = [NewCol; A{i_lin, i_col}];
        end
    end
    Adel = [Adel, NewCol];
end