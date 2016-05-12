%% The task of the program is to do registration of home-made videos
clear;   
% function [] = Step07_CellsTips_Intens_Edges_Trans
close all;
%--------------------------------------------------------------------------
%!!!--!!! Minimal area of a cell, in pixels
MinArea = 1000;       
%!!!--!!! Defining the size limits for objects to be recognized as being
%-- S.pombe cells
MinCellWidth = 30;  %15; for bin 2
MaxCellWidth = 100; %50;% for bin 2
MinCellLength = 90; %45;% for bin 2
MaxCellLength = 320;    %140;% for bin 2
%!!!--!!! Bigger the coefficient, brighter cells outline
Coeff_OutlineGreyLevel = 2;
%!!!--!!! Bigger the coefficient, less bright the cells 
Coeff_Imshow = 1;
%!!!--!!! Basic name for images where we'll get cell geometry 
%-- and cell intensities from 
ListFileName = '_InputImages/REG_BF_AVG_*.mat';
PathAllCellsPixels = '_Output/output_CellsPixels.mat';
PathAllGoodCells = '_Output/output_GoodCellsParams.mat';
PathTMP = '_Output/__TMP_Pixels_GoodCells';
%--------------------------------------------------------------------------
ImFiles = dir(ListFileName);  % Obtaining the list of files of BF projections
ImFluoFiles = dir('_InputImages/*.tif');     % List of all fluo files (non-projected)
AllCellsPixels = cell(length(ImFiles), 1);
AllGoodCells = cell(length(ImFiles), 1);
for i_File = 1:length(ImFiles)              % Loop on BF image files to analyse 
    i_File
    close all;
    File = ImFiles(i_File).name;
    BrFieldIm = load(['_InputImages/' File]);    
    BrFieldIm = BrFieldIm.RegIm;
    
    I = imcrop(BrFieldIm, [870 72 300 260]);
    figure, imshow(I, []);
    pause(0.2);
    % Saving the figure
    save(['Small/' File], 'I');
end




