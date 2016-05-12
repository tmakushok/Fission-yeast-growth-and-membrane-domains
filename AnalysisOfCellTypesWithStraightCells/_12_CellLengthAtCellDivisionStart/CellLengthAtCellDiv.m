%% The task of the program is to plot the cell length at the initiation of
%% cell division phase
% clear
load('DivStart_LenAtDiv_3Movies.mat');
% Preparing the data 
CellLengths = DivStart_LenAtDiv_3Movies(:,2);
CellLengths = CellLengths(CellLengths > 0);
% Transition from pixels to microns
CellLengths = CellLengths * 0.0707;
% Stitistics
mean(CellLengths)
std(CellLengths)