%% The task of the program is to do registration of home-made videos
clear;   
close all;
%--------------------------------------------------------------------------
%!!!--!!! Basic name for images where we'll get cell geometry 
%-- and cell intensities from 
ListFileName = '_InputImages/REG_AVG_*.mat';
PathAllGoodCells = '_Output/output_GoodCellsParams.mat';
PathCellTracks = '_Output/output_CellsTracks.mat';
PathContours = '_Output/AllContours.mat';
PathKymos = '_Output/AllKymographs.mat';
%--------------------------------------------------------------------------
load(PathAllGoodCells);
load(PathCellTracks);
load(PathContours);
load(PathKymos);
%% Size of the image
ImFiles = dir(ListFileName);  % Obtaining the list of files of BF projections
File = ImFiles(1).name;
Im = load(['_InputImages/' File]);    
Im = Im.RegIm; 
ImSize = size(Im);
%% Loop on cells        
for i_cell = 1:size(CellsTrack, 1)
    i_cell
%% Checking if the cell was concidered good after previous checkings
    if isempty(AllKymos{i_cell})
        continue
    end
%% Defining the borders of the movie for this cell (from final cell outline)  
    for i = length(ImFiles):-1:1
        Coords = AllContours{i_cell, i};      % Cell outline for the last time point when the cell is detected
        if ~isempty(Coords)
            break
        end
    end
    Xmin = max(min(Coords(:,2)) - 75, 1);               % max - to account for image borders
    Ymin = max(min(Coords(:,1)) - 75, 1);   
    Xmax = min(max(Coords(:,2)) + 75, ImSize(2));       % min - to account for image borders
    Ymax = min(max(Coords(:,1)) + 75, ImSize(1));  
    
    CropRect = [Xmin, Ymin, Xmax-Xmin, Ymax-Ymin];
%% Loop on time points of the movie
    for i_File = 1:length(ImFiles)              
        close all;
        RegIm = [];
        % Open fluo file
        File = ImFiles(i_File).name;
        Im = load(['_InputImages/' File]);    
        Im = Im.RegIm;   
%% Overlay of cell outlines on top of RGB fluo image for current time point
        Im = Im / max(max(Im));
        Coords = AllContours{i_cell, i_File};        
        if isempty(Coords)
            RegIm(:,:,1) = Im;
            RegIm(:,:,2) = Im;            
            RegIm(:,:,3) = Im;
        else
            Im(sub2ind(size(Im), Coords(:,1), Coords(:,2))) = 1;
            RegIm(:,:,1) = Im;
            Im(sub2ind(size(Im), Coords(:,1), Coords(:,2))) = 0;
            RegIm(:,:,2) = Im;
            Im(sub2ind(size(Im), Coords(:,1), Coords(:,2))) = 0;
            RegIm(:,:,3) = Im;
        end
        RegIm(find(RegIm < 0)) = 0;
%         figure, imshow(RegIm);
%% Cropping to have small image with current cell in the middle
        RegIm = imcrop(RegIm, CropRect);
%         figure, imshow(RegIm, []);
%% Adding of the next plane to the movie 
        mov(i_File).cdata = RegIm;
        mov(i_File).colormap = [];        
     end
%% Saving the movie  
    Str = sprintf('%03.0f \n', i_cell);   % Adds two zeros in front of Nb = 1 for example    
    SaveName = ['_Output/Movie_Cell_' Str(1:3) '.avi'];
    movie2avi(mov, SaveName, 'compression', 'None');
end