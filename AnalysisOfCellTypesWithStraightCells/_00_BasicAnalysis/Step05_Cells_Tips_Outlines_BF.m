%----- The task of the program is to 
%-- 2) Recognise the borders of each cell and to find it's axis / tips
%-- (output in a file only the ones with reasonable value of width);

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
MaxCellLength = 400;    %140;% for bin 2
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
    imshow(BrFieldIm, []);
    % Open fluo projection image
    FileFl = regexprep(File, 'REG_BF_AVG_', 'REG_AVG_');                  
    FluoIm = load(['_InputImages/' FileFl]);
    FluoIm = FluoIm.RegIm;
%% Obtaining cell parameters from transmission image       
    % Function for bright field images, 
    % second parameter is for visualisation of cell outlines on fluo image                                          
    % third and fourth parameters are most bottom and most top images of the stack
    % (to subtract cells coming out of Z-range)
    % 'GoodCells' contains:
    % CellNb|Cell_Lengths|Cell_Width|AxisAngle|Cell_Center: x1|y1|Cell_Tips: x1|y1|x2|y2|Area   
    OutOfZMask = zeros(size(BrFieldIm));
    [GoodCells, CellsPixels] = f_CellParams_BrightField_AutoContFilling(BrFieldIm, FluoIm, OutOfZMask);  
    AllCellsPixels(i_File) = {CellsPixels};  % Each line corresponds to one image  
    AllGoodCells(i_File) = {GoodCells};  % Each line corresponds to one image 
%% Save each outlines_on_top_of_fluo image as control 
    saveas(gcf, ['_Output/CellOutlines_Frame' int2str(i_File) '.fig'])    % 'gcf' returns the handle of the current figure
    % Temporary saving of the data, to have the possibility to stop the
    % program
    save(PathTMP, 'AllCellsPixels', 'AllGoodCells');
end            
save(PathAllCellsPixels, 'AllCellsPixels');
save(PathAllGoodCells, 'AllGoodCells');





