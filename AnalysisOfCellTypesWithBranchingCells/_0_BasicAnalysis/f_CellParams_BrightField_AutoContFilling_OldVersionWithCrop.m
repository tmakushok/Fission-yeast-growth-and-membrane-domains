%% The task of the program is to find cell cortex border and determine cell
%% parameters (cell ends, cell length, angle, profile of cell width)
% Result array contains: cell ends(1,2,3,4 (x1,y1,x2,y2)), 
% cell axis angle in degrees(5), cell width close to cell end(6), cell length(7)
function [GoodCells, CellsPixels] = f_CellParams_BrightField(InitImage, FluoIm, OutOfZMask)
%--------------------------------------------------------------------------
% %!!!--!!! Parameter for the artificial taking off of light halo around cells
% AntiHalo = 5;
%!!!--!!! Parameter used for filling in the space between the edges of the
%-- cells determined automaticly (in pixels)
MaxEdgeDistance = 100;
%!!!--!!! Maximal distance between centers of two detected areas when they
%-- are still considered as the same cell detected twice
DistDeDoubling = 45;
%!!!--!!! Max of badly segmented cells on an image (for 'ginput' function)
MaxBadCells = 30;
%!!!--!!! Minimal area of a cell, in pixels
MinArea = 1000;  
MaxArea = 100000;
MinAreaCont = 100;       % Min area of a contour to be kept
%!!!--!!! Defining the size limits (in pixels) for objects to be recognized as being
%-- S.pombe cells
MinCellWidth = 30;  
MaxCellWidth = 90; 
MinCellLength = 45; 
MaxCellLength = 160;    
%!!!--!!! Bigger the coefficient, brighter cells outline
Coeff_OutlineGreyLevel = 2;
%!!!--!!! Bigger the coefficient, less bright the cells 
Coeff_Imshow = 1;
%!!!--!!! Figure number
AllBinCellsFigNb = 100;
%--------------------------------------------------------------------------
% Initialisations
Nb_Cell = 1;    
CellEnds = [];
CellWidthEnds = [];
CellsPixels = cell(0,0);
CellsOutlines = cell(0,0);
GoodCells = []; 
DoneFlag = [];
FigNb = 1;
[m, n] = size(InitImage);        
% FullImWithOneCell = zeros(m, n);
%% Measure BF background (for the step where third contours are taken off)
BF_BkGd = f_naturalImageBkGd(InitImage);
%% Filtering of the initial image to smooth the background random changes in intensity    
AverFiltered = InitImage;
AverFiltered = medfilt2(AverFiltered, [3 3]);

h = fspecial('average', 3);        %9);
AverFiltered = imfilter(AverFiltered, h, 'replicate');      
figure; imshow(AverFiltered, []);
%% Determining the edges of the cells using 'edge'       
[CannyResult, ThresCanny] = edge(AverFiltered, 'canny');
% figure;  imshow(CannyResult);         
%% Taking off very short contours
Labels = bwlabel(CannyResult);
Stats = regionprops(Labels, 'Area'); 
[Condition] = find([Stats.Area] > MinAreaCont);
BigContours = ismember(Labels, Condition);
figure; imshow(BigContours, []); 

[m, n] = size(BigContours);   
Labels = bwlabel(BigContours);
StatsCont = regionprops(Labels, 'FilledImage', 'BoundingBox', 'PixelList');      
figure(AllBinCellsFigNb);
GoodContoursImage = zeros(size(BigContours));
for i = 1:length(StatsCont)            % Loop on all contours (they are not close to the border because of the crop of the whole image)
% %     % loop: looking at all edges longer than a min and not close to image border              
% %     if (StatsCont(i).Area > MinAreaCont) & (StatsCont(i).BoundingBox(1) > 2) & (StatsCont(i).BoundingBox(2) > 2)
    % (StatsCont(i).BoundingBox(1) ~= ???) & (StatsCont(i).BoundingBox(1) ~= ???)                        
    %close all;            
%% Check if current contour is external one. If yes, not analyse it.
% (based on the fact that external contour is above white region around cells on BF image) 
    
%     if f_IsThirdCont(StatsCont(i).PixelList, )
%         continue
%     end
    
    
    
    
    
    
    
    [m_OneCont, n_OneCont] = size(StatsCont(i).FilledImage);
    BinaryImage = StatsCont(i).FilledImage;            
%             figure(), imshow(BinaryImage);            
    % Putting some 0s all around the edge (ifnot, edge analysed is too close to the border of the image)
    AddCanvas = 2.5 * MaxEdgeDistance;
    BinaryImage = [zeros(AddCanvas, n_OneCont + 2*AddCanvas); 
        zeros(m_OneCont, AddCanvas), BinaryImage, zeros(m_OneCont, AddCanvas); 
        zeros(AddCanvas, n_OneCont + 2*AddCanvas)];            
%             figure(), imshow(BinaryImage);    
%% Extracting coordinates of the upper left corner and width of the
% bounding box that contained the image with one single edge
%     lc_x = StatsCont(i).BoundingBox(1) - 0.5; 
%     lc_y = StatsCont(i).BoundingBox(2) - 0.5; 
%     wid_x = StatsCont(i).BoundingBox(3); 
%     wid_y = StatsCont(i).BoundingBox(4); 
    % Extracting the filled cell from BinaryImage inside the box 
    % corresponding to the initial BoundingBox
%     CroppedIm = BinaryImage((AddCanvas + 1):(AddCanvas + wid_y), (AddCanvas + 1):(AddCanvas + wid_x));
%% Adding next 'layer' to the segmented image: next cell on
% the black BkGd added to the ones accumulated previously     
    OneCellInNature = zeros(size(InitImage));
    Pxs = StatsCont(i).PixelList; 
    OneCellInNature(sub2ind(size(OneCellInNature), Pxs(:,2), Pxs(:,1))) = 1;
    OneCellInNature = imfill(OneCellInNature, 'holes');
    imshow(OneCellInNature, []);    
%     OneCellInNature = [zeros(lc_y - 1, n); 
%         zeros(wid_y, lc_x - 1), CroppedIm, zeros(wid_y, n - (lc_x - 1) - wid_x); 
%         zeros(m - (lc_y - 1) - wid_y, n)];  
%     FullImWithOneCell = FullImWithOneCell + OneCellInNature;   
%% Checking if the current cell is not in the region with fluorescence out of Z-range    
    if ~isempty(find(OneCellInNature + OutOfZMask == 2))
        continue
    end
                                           
%     figure(AllBinCellsFigNb); 
 
%% Measuring parameters of the filled cells (before it was done for the cell contour only)   
    Labels = bwlabel(OneCellInNature);
    Stats = regionprops(Labels, 'Area');           
%% Discarding cells that have an area that is too small or too big
    if (Stats.Area < MinArea) || (Stats.Area > MaxArea)
        continue
    end    
%% Finding the four cell tips                        
    [OneCell_CellEnds, OneCell_CellWidthEnds, OneCell_CellsPixels, OneCell_GoodCells] = ... 
        f_Cell4TipsDetect(OneCellInNature, AllBinCellsFigNb, MinCellWidth, MaxCellWidth, MinCellLength, MaxCellLength);             
    if isempty(OneCell_GoodCells)
        continue
    end
% Accumulation of data for all the cells in the image
    CellEnds = [CellEnds; OneCell_CellEnds];
    CellWidthEnds = [CellWidthEnds; OneCell_CellWidthEnds];
    CellsPixels = [CellsPixels; OneCell_CellsPixels];
    % 'GoodCells' contains:
    % CellNb|Cell_Lengths|Cell_Width|AxisAngle|Cell_Center: x1|y1|Cell_Tips: x1|x2|y1|y2|Area 
    GoodCells = [GoodCells; Nb_Cell, OneCell_GoodCells(2:6), OneCell_CellEnds(1:4), Stats.Area];

    CellCenter = OneCell_GoodCells(5:6);
    Nb_Cell = Nb_Cell + 1;  
%% Visualisation of all contours found so far on the fluorescence image            
%             if isempty(CellsPixels)
%                 continue
%             end                        
%             for i_OnePix = 1:length(CellsPixels{1})     % Filling with 1s the places where 'final good' cells are detected   
%                 GoodContoursImage(CellsPixels{1}(i_OnePix, 2), CellsPixels{1}(i_OnePix, 1)) = 1;
%             end        
%             BWoutline = bwperim(GoodContoursImage);   % To find perimeter pixels in binary image            
%             Segout = FluoImage; 
%             [OutlineGreyLevel, a, a] = simple_max2D(FluoImage);
%             Segout(BWoutline) = OutlineGreyLevel;     
%             figure, imshow(Segout, []);   

%             AllCellEnds{i_Frame, Nb_Cell} = CellEnds;              
%             AllWidthEnds{i_Frame, Nb_Cell} = CellWidthEnds;                                                 
%% Solving the problem of having two or three detected areas overlapping 
%% (steming out from inner and outer edges of a cell) with slightly different widths 
%             AddedFlag = 0;            
    [LenWE, a] = size(CellWidthEnds);  
    if LenWE < 2
        continue
    end
    % Check if this cell was not already treated 
    % (if it was, then the third inner contour is looked at and we want to avoid keeping it)
    s_F = size(DoneFlag);
    if ~isempty(DoneFlag)
        FlagDist = sqrt((DoneFlag(1:s_F(1), 1) - CellCenter(1)).^2 + (DoneFlag(1:s_F(1), 2) - CellCenter(2)).^2);                
        if min(FlagDist) <= DistDeDoubling
            % Taking away the last cell's information from geometry arrays
            [LinG, a] = size(CellEnds);
            CellWidthEnds(LinG, :) = [];
            CellEnds(LinG, :) = []; 
            GoodCells(LinG, :) = []; 
            CellsPixels(LinG) = [];
            continue
        end        
    end
    % Finding the good contour to keep
    for i_UnDoubl = (LenWE - 1):-1:1  % back count as more chances to have an overlap with one of the 'closely previous' areas             
        % Calculation of the distance between current cell center and the
        % cell number i_DeDoubling center
        CentersDist = sqrt((CellWidthEnds(i_UnDoubl, 5) - CellCenter(1))^2 + (CellWidthEnds(i_UnDoubl, 6) - CellCenter(2))^2);                
        if CentersDist <= double(DistDeDoubling)    % if centers of the two cells are very close
            CellWidthOld = GoodCells(i_UnDoubl, 3);     %sqrt((CellWidthEnds(i_UnDoubl, 3) - CellWidthEnds(i_UnDoubl, 1))^2 + (CellWidthEnds(i_UnDoubl, 4) - CellWidthEnds(i_UnDoubl, 2))^2);
            CellWidth = OneCell_GoodCells(3);            
            if CellWidth < CellWidthOld                        
%                         i_ToRemove = find(Result((OldLenRes + 1):ResLen, 3) == CellWidthEnds(i_UnDoubl, 5) & Result((OldLenRes + 1):ResLen, 4) == CellWidthEnds(i_UnDoubl, 6));       
%                         i_ToRemove = i_ToRemove_CP + OldLenRes;
%                         Result(i_ToRemove, :) = [];   
                % Remove those lines also in geometry matrixes                        
                CellWidthEnds(i_UnDoubl, :) = [];
                CellEnds(i_UnDoubl, :) = [];
                GoodCells(i_UnDoubl, :) = [];
                % Taking away from the pixels set
                CellsPixels(i_UnDoubl) = [];
                % Adding the cell center in the list of cells treated
                % (to avoid keeping the third (most inner) outline)
                DoneFlag = [DoneFlag; CellCenter];
                % Adding of the good information to 'Result'
%                         Result = [Result; CellLength, CellWidth, CellCenter];                         
                % Adding to the pixels set
%                         CellsPixels = [CellsPixels; {Stats.PixelList}];                                                
%                         AddedFlag = 1;
                break
            else                        
%                         AddedFlag = 1;   
                % Taking away the last cell's information from
                % geometry arrays
                [LinG, a] = size(CellEnds);
                CellWidthEnds(LinG, :) = [];
                CellEnds(LinG, :) = []; 
                GoodCells(LinG, :) = []; 
                CellsPixels(LinG) = [];
                % Adding the cell center in the list of cells treated
                % (to avoid keeping the third (most inner) outline)
                DoneFlag = [DoneFlag; CellCenter];
                break
            end
        end
    end
%             if AddedFlag == 0   % There was no cells with cell centers so close that it could have been an overlap
% %                 Result = [Result; CellLength, CellWidth, CellCenter];                                
% %                 CellsPixels = [CellsPixels; {Stats.PixelList}];		
% %                 AddedToRes = AddedToRes + 1;
%             end             
end              
% end     
%% Visualisation of cell objects after the un-overlapping procedure
FinalImage = zeros(m, n);
% Filling with 1s the places where 'final good' cells are detected
for i_vis = 1:length(CellsPixels)
    for i_OnePix = 1:length(CellsPixels{i_vis})     % Better to use 'size', but here it doesn't matter
%             i_OnePix = 1:length(CellsPixels{i_vis});
        FinalImage(CellsPixels{i_vis}(i_OnePix, 2), CellsPixels{i_vis}(i_OnePix, 1)) = 1;
    end
end
%     figure, imshow(FinalImage, []);
%% Representing borders of the segmented image overlaid with fluorescence image 
BWoutline = bwperim(FinalImage);   % To find perimeter pixels in binary image
Segout = FluoIm;   
Segout(BWoutline) = max(max(Segout));     
figure, imshow(Segout, []);    
% Putting geometrical parameters on this overlaid image
Len_Res = length(CellsPixels);     
for i_vis = 1:Len_Res    
    % Visualisation of the cell length 
    line([CellEnds(i_vis, 1), CellEnds(i_vis, 3)], [CellEnds(i_vis, 2), CellEnds(i_vis, 4)]);            
    % Visualisation of the cell width            
    line([CellWidthEnds(i_vis, 1), CellWidthEnds(i_vis, 3)], [CellWidthEnds(i_vis, 2), CellWidthEnds(i_vis, 4)]);                    
    % Visualisation of the cell center        
%         line(GoodCells(i_vis, 5), GoodCells(i_vis, 6), 'Color', [.8 0 0], 'Marker', 'o');  
end   
% %% Taking off the cells that are not well segmented (with mouse clicks)
% [CellOff_x, CellOff_y] = ginput(MaxBadCells);  % User mouse-clicks-in coordinates, 'Enter' to continue    
% % Find actually existing cells
% %     GoodCellsLabels = bwlabel(FinalImage);         
% for i_Off = 1:length(CellOff_x)     % Loop on the cells clicked        
%     i_Pix = 1;
%     while i_Pix < (length(CellsPixels) + 1)            
%         % Finding lines in CellsPixels{i_Pix} in which we have x =
%         % clicked_x and y = clicked_y              
%         LinCl = find(int16(CellsPixels{i_Pix}(:, 1)) == int16(CellOff_x(i_Off)) & int16(CellsPixels{i_Pix}(:, 2)) == int16(CellOff_y(i_Off)));                                    
%         if ~isempty(LinCl) % if it is the cell number i_Pix that contain clicked coordinates   
% %                 GoodCellsLabels(find(GoodCellsLabels(:,:) == i_Pix)) = 0;               
%             CellEnds(i_Pix, :) = [];  
%             CellWidthEnds(i_Pix, :) = [];
%             GoodCells(i_Pix, :) = [];
%             CellsPixels(i_Pix) = [];                
%             break                          
%         end
%         i_Pix = i_Pix + 1;
%     end
% end  
%     figure, imshow(BigRegions, []);    
%     GoodCellsLabels(find(GoodCellsLabels)) = 1;     
%     figure, imshow(GoodCellsLabels, []);       
%% Visualisation of the 'good cells' centers     
%figure(ResFigNb);
[Lin_CPix, Col_CPix] = size(CellEnds);
for i_GC = 1:Lin_CPix     % Loop on the good cells        
%         Fig = figure(); 
%         imshow(InitImage, []);
    line(CellEnds(i_GC, 5), CellEnds(i_GC, 6), 'Color', [.8 0 0], 'Marker', 'o');  
%         saveas(Fig, ['Output/CellNumber' num2str(i_GC)]);
end  
% %% Final output
% CellParams = [CellEnds(:, 1:4), GoodCells(:, 4), GoodCells(:, 3), GoodCells(:, 2), ];










%% Backup
% Dilate and smooth the image to get to the true cell border (as seen on fluorescence images)
%             se =  strel('disk', 2, 0);
%             OneCellInNature = imdilate(OneCellInNature, se);    % [se0 se90]);            
%             h = fspecial('average', 5);
%             CroppedIm = imfilter(CroppedIm, h, 'replicate');       
