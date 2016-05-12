%% The task of the program is to overlay cell outlines (of the cells that were concidered OK based on kymo check) 
%% on both phase contrast and fluo movies, entire fields of view
clear;   
close all;
%--------------------------------------------------------------------------
ListFileName = '_InputImages/REG_AVG_*.mat';
PathAllGoodCells = '_Output/output_GoodCellsParams.mat';
PathCellTracks = '_Output/output_CellsTracks.mat';
PathContours = '_Output/AllContours.mat';
PathKymos = '_Output/AllKymographs.mat';
%--------------------------------------------------------------------------
load(PathAllGoodCells);
% load(PathCellTracks);
load(PathContours);
load(PathKymos);
ImFiles = dir(ListFileName);  % Obtaining the list of files of projections

for i_File = 1:length(ImFiles)     % Loop on time points of the movie   
    i_File
    close all;
    RegIm = [];
    % Open image file
    File = ImFiles(i_File).name;
    Im = load(['_InputImages/' File]);    
    Im = Im.RegIm;
    Im = Im / max(max(Im));
    % Initialization of the image with all outlines
    RegIm(:,:,1) = Im;
    RegIm(:,:,2) = Im;            
    RegIm(:,:,3) = Im;

    for i_cell = 1:size(AllContours, 1)     % Loop on cells                
%         %% Checking if the cell was concidered good after previous checks
%         if isempty(AllKymos{i_cell})
%             continue
%         end
        %% Overlay of cell outlines on top of RGB image for current time point
%         Im = Im / max(max(Im));
        Coords = AllContours{i_cell, i_File};        
        if ~isempty(Coords)
            % Red channel
            Outline = zeros(size(Im));            
            Outline(sub2ind(size(Outline), Coords(:,1), Coords(:,2))) = 1;
            Outline(:,:,1) = imdilate(Outline(:,:,1), strel('disk', 3));
            RedIm = RegIm(:,:,1);
            RedIm(logical(Outline)) = 1;            
            RegIm(:,:,1) = RedIm;
            % Blue and green
            BGIm = RegIm(:,:,2);
            BGIm(logical(Outline)) = 0;
            RegIm(:,:,2) = BGIm;
            RegIm(:,:,3) = BGIm;
%             figure, imshow(RegIm, []);
        end                
    end  
    imwrite(RegIm, ['_Output/Outlines_AllCells/AllOutlines_Fluo_' sprintf('%03.0f', i_File) '.tif'], 'tiff', 'Resolution', 500);
%% Adding of the next plane to the movie 
%     mov(i_File).cdata = RegIm;
%     mov(i_File).colormap = [];             
end
%% Saving the movie     
% SaveName = ['_Output/AllOutlines_PhaseContr.avi'];
% movie2avi(mov, SaveName, 'compression', 'None');