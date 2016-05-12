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
ListFileName = '_InputImages/REG_AVG_*.mat';
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
    
    I = imcrop(BrFieldIm, [1420 650 200 120]);
    figure, imshow(I, []);
    % Reconstruction of the image from three separate colours images
    RegIm(:,:,1) = I;
    RegIm(:,:,2) = I;
    RegIm(:,:,3) = I;
    RegIm(find(RegIm < 0)) = 0;
    RegIm(:,:,1) = RegIm(:,:,1) / max(max(RegIm(:,:,1)));
    RegIm(:,:,2) = RegIm(:,:,2) / max(max(RegIm(:,:,2)));
    RegIm(:,:,3) = RegIm(:,:,3) / max(max(RegIm(:,:,3)));
%     h= figure, image(BrFieldIm, []);
%     pause(0.1);
    figure, imshow(RegIm(:,:,1));
    figure, imshow(RegIm(:,:,2));
    figure, imshow(RegIm(:,:,3));    
%     Croped = crop
    % Creating Matlab movie 
    mov(i_File).cdata = RegIm;
    mov(i_File).colormap = [];        
%     % Save the registered image    
%     SaveFileName = ImFiles(i_Frame).name;          
%     save([ImageFolder 'REG_' SaveFileName], 'RegIm');          
%     RefIm = RegIm;      % Current image becomes reference image for the next round
end
movie2avi(mov, 'WT_Cell72.avi', 'compression', 'None');