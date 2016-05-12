%% The task of the program is to take intensity profiles along cell outlines (found on BF)
%%  on fluorescence images and construct kymograph matrices for each cell.
%  Profiles should start from the middle of the cell cortex 
%  (from one of the 'cell width ends').

clear;      % To erase variables that are in memory
close all;
%--------------------------------------------------------------------------
%!!!--!!! File names
ImageFolder = '_InputImages/';
AllContFile = '_Output/AllContours.mat';
% AllProfFile = '_Output\AllProfiles.mat';
AllProfSqFile = '_Output/AllProfiles_Square3.mat';
AllEndsFile = '_Output/AllCellEnds.mat';
%--------------------------------------------------------------------------
load('_Output/output_CellsTracks.mat');
load('_Output/output_CellsPixels.mat');
load('_Output/output_GoodCellsParams.mat');

AllContours = cell(size(CellsTrack));
% AllProfilesTipEnd1 = cell(size(CellsTrack));
AllProfilesSquare = cell(size(CellsTrack));
AllCellEnds = cell(size(CellsTrack));

ImFiles = dir([ImageFolder, 'REG_AVG_*.mat']);  % Obtaining the list of fluo images to get intensities from
for i_Frame = 1:size(CellsTrack, 2) 
%% Opening fluorescence image
    FilePath = strcat(ImageFolder, ImFiles(i_Frame).name);
    FluoImage = load(FilePath);
    FluoImage = FluoImage.RegIm;
%% Cut the fluo image to have BF overlapping with the fluo
    % Add columns
    Horis = 3;
    FluoImage = [zeros(size(FluoImage, 1), Horis), FluoImage(:, 1:size(FluoImage, 2) - Horis)];

    for i_Cell = 1:size(CellsTrack, 1)          
        close all;              
        RealCellNb = CellsTrack(i_Cell, i_Frame);
%% Preparing black image with white pixels belonging to the cell 
%  (to be used to detect outline of the cell)  
        if RealCellNb == 0     % This cell was not well detected on BF image
            continue
        end
        FramePixels = AllCellsPixels{i_Frame};
        CellPixels = FramePixels{RealCellNb};            
%         figure, imshow(FluoImage, []);
        Binary = zeros(size(FluoImage));
        Binary(sub2ind(size(FluoImage), CellPixels(:,2), CellPixels(:,1))) = 1;
%         figure, imshow(Binary);
        CellEnds = AllGoodCells{i_Frame}(RealCellNb, 7:10);    
%% Extracting intensity profiles from fluorescence images 
        % First pre-finding the outline of the cell, starting from
        % non-defined position (first in the list of cell pixels)        
        ContStartPoint = [double(CellPixels(1, 2)), double(CellPixels(1, 1))];      % it should be of type double, but the value should be integer
        Contour = bwtraceboundary(Binary, ContStartPoint, 'N', 8, Inf, 'clockwise');   % Gives [Y X] result             
        % Finding right starting point: min distance from cell 'pre-outline' to
        % the CellEnd number 1 we want to start from 
        x = CellEnds(1);
        y = CellEnds(2);
        DistToCont = (Contour(:, 2) - x).^2 + (Contour(:, 1) - y).^2;
        [a, ind] = min(DistToCont);
        ContStartPoint = [Contour(ind, 1), Contour(ind, 2)];           %[double(uint16(CellWidthEnds(2) + 1)), double(uint16(CellWidthEnds(1)))];      % it should be of type double, but the value should be integer
        Contour = bwtraceboundary(Binary, ContStartPoint, 'N', 8, Inf, 'clockwise');             % Gives [Y X] result
        % Visualise part of the contour
%         hold on
%         plot(Contour(1:20, 2),Contour(1:20, 1),'g','LineWidth',2);
%         %plot(Contour(:,2),Contour(:,1),'g','LineWidth',2);
%         hold off
        % Obtaining intensity profile along the contour
        LinesNb = size(Contour, 1);     
        Y = Contour(:, 1);     % bwtraceboundary gives [Y X] result
        X = Contour(:, 2);
        [cx, cy, IntProfile] = improfile(FluoImage, X, Y, LinesNb, 'bicubic');
%         figure, plot(1:LinesNb, IntProfile, '-o', 'MarkerSize', 3);       
%         grid on;           
        % Instead of normal intensity profile take intensities 
        % from a small square around the point and average them
        reIP = zeros(size(IntProfile));
        for i_reIP = 1:length(IntProfile)
            x_re = round(cx(i_reIP));
            y_re = round(cy(i_reIP));
            if x_re == 1
                % Artificial dealing with the fact that the cell is too
                % close to the border: displacement by one pixel
                x_re = 2;   
            end
            if x_re == 2048
                % Artificial dealing with the fact that the cell is too
                % close to the border: displacement by one pixel
                x_re = 2047;   
            end
            if y_re == 1
                % Artificial dealing with the fact that the cell is too
                % close to the border: displacement by one pixel
                y_re = 2;   
            end
            if y_re == 2048
                % Artificial dealing with the fact that the cell is too
                % close to the border: displacement by one pixel
                y_re = 2047;   
            end
            % Summing elements in the small square in threes            
            reIP(i_reIP) = sum(FluoImage(y_re - 1:y_re + 1, x_re - 1)) + ...
                sum(FluoImage(y_re - 1:y_re + 1, x_re)) + ...
                sum(FluoImage(y_re - 1:y_re + 1, x_re + 1));
            reIP(i_reIP) = reIP(i_reIP) / 9;
        end
%         figure, plot(1:LinesNb, reIP, '-o', 'MarkerSize', 3);       
%         grid on;        
        % Saving data to cell arrays
        % AllContours has this structure: [Y1 X1; Y2 X2; ...]
        AllContours{i_Cell, i_Frame} = Contour;              
%         AllProfilesTipEnd1{i_Cell, i_Frame} = [X, Y, IntProfile];   
        AllProfilesSquare{i_Cell, i_Frame} = [X, Y, reIP]; 
        AllCellEnds{i_Cell, i_Frame} = CellEnds; 
    end     % loop on cells
end         % loop on the movie frames
save(AllContFile, 'AllContours');
% save(AllProfFile, 'AllProfilesTipEnd1');
save(AllProfSqFile, 'AllProfilesSquare');
save(AllEndsFile, 'AllCellEnds');







