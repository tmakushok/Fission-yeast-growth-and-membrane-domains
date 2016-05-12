%% The task of the program is to extract cell lengths at the beginning of
%% the cell division phase
clear
load('_Output/_DivisionTimes_StartAndEnd.mat');
load('_Output/AllTipsLengths.mat');
% Preparing the output matrix
DivStart_LenAtDiv = DivisionTimes(:,1);
for i_cell = 1:length(TipsLen)
    DivTime = DivStart_LenAtDiv(i_cell,1);
    if DivTime < 1
        continue
    end
    CellLen = TipsLen{i_cell}(DivTime, 1) + TipsLen{i_cell}(DivTime, 2);
    DivStart_LenAtDiv(i_cell,2) = CellLen;
end


