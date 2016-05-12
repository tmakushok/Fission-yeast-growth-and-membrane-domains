%% The task of the program is to find cell cortex border and determine cell
%% parameters (cell ends, cell length, angle, profile of cell width)
% Result array contains: cell ends(1,2,3,4 (x1,y1,x2,y2)), 
% cell axis angle in degrees(5), cell width close to cell end(6), cell length(7)
function [GoodCells, CellsPixels] = f_CellParams_BrightField_AutoContFilling(InitImage, FluoIm, OutOfZMask)
%--------------------------------------------------------------------------
%!!!--!!! Parameter used for filling in the space between the edges of the
%-- cells determined automaticly (in pixels)
MaxEdgeDistance = 100;
%!!!--!!! Maximal distance between centers of two detected areas when they
%-- are still considered as the same cell detected twice
DistDeDoubling = 45;
%!!!--!!! Minimal area of a cell, in pixels
MinArea = 3000;  
MaxArea = 100000;
MinAreaCont = 200;       % Min area of a contour to be kept
%!!!--!!! Defining the size limits (in pixels) for objects to be recognized as being
%-- S.pombe cells
MinCellWidth = 30;  
MaxCellWidth = 150; 
MinCellLength = 45; 
MaxCellLength = 400; 
%!!!--!!! Final cell mask erosion parameter 
ErodParam = 5;
%!!!--!!! Figure number
AllBinCellsFigNb = 100;
%--------------------------------------------------------------------------
%% Initialisations
Nb_Cell = 1;    
CellEnds = [];
CellWidthEnds = [];
CellsPixels = cell(0,0);
GoodCells = []; 
DoneFlag = [];
AllCellsBinary = zeros(size(InitImage));
%% Subtract image background
% Find the background surface using image opening
BkGdIm = imopen(InitImage, strel('disk',10));
figure; imshow(BkGdIm, []);
% Smooth the background image
BkGdIm = medfilt2(BkGdIm, [11 11]);
figure; imshow(BkGdIm, []);
BkGdIm = imfilter(BkGdIm, fspecial('average', 11), 'replicate');
% Subtract it
InitImage = InitImage - BkGdIm;
figure; imshow(InitImage, []);
%% Measure BF background (for the step where third contours (most external ones) are taken off)
BF_BkGd = f_naturalImageBkGd(InitImage);
%% Filtering of the initial image to smooth the background random changes in intensity    
AverFiltered = InitImage;
AverFiltered = medfilt2(AverFiltered, [3 3]);

h = fspecial('average', 3);        %9);
AverFiltered = imfilter(AverFiltered, h, 'replicate');      
% figure; imshow(AverFiltered, []);
%% Determining the edges of the cells using 'edge'       
[CannyResult, ThresCanny] = edge(AverFiltered, 'canny');
figure;  imshow(CannyResult);         
%% Taking off very short contours
Labels = bwlabel(CannyResult);
Stats = regionprops(Labels, 'Area'); 
[Condition] = find([Stats.Area] > MinAreaCont);
BigContours = ismember(Labels, Condition);
% figure; imshow(BigContours, []); 

Labels = bwlabel(BigContours);
StatsCont = regionprops(Labels, 'PixelList');   

for i = 1:length(StatsCont)            % Loop on all contours    
%     i
    close all;
%% Creating black image with just one white contour on it    
    OneCellInNature = zeros(size(InitImage));
    Pxs = StatsCont(i).PixelList; 
    OneCellInNature(sub2ind(size(OneCellInNature), Pxs(:,2), Pxs(:,1))) = 1;
    % Visualise
%     figure, imshow(InitImage, []);
%     hold on, plot(Pxs(:,1), Pxs(:,2), 'o');
%% Dilate the contour to fill in 1px holes and fill the contour
    Packed = bwpack(OneCellInNature);
    Packed = imdilate(Packed, strel('disk', 1, 0), 'ispacked', size(OneCellInNature,1));
    OneCellInNature = bwunpack(Packed, size(OneCellInNature, 1));
    % Fill it
    OneCellInNature = imfill(OneCellInNature, 'holes');
%     figure, imshow(OneCellInNature, []);
%% Measuring parameters of the filled cells (before it was done for the cell contours only)   
    Labels = bwlabel(OneCellInNature);
    Stats = regionprops(Labels, 'Area');           
%% Discarding cells that have an area that is too small or too big
%% (including unfilled contours)
    if (Stats.Area < MinArea) || (Stats.Area > MaxArea)
        continue
    end        
%% Adding next 'layer' to the segmented image: 
% next cell on the black BkGd added to the ones accumulated previously     
    AllCellsBinary = AllCellsBinary + OneCellInNature;
%     figure, imshow(AllCellsBinary, []);  
%% Check if current contour is external one. If yes, not analyse it.
% (based on the fact that external contour is above white region around cells on BF image)  
    if f_IsThirdCont(OneCellInNature, InitImage, BF_BkGd)
        continue
    end
%% Erode cell borders to have a closer to reality position of the border
    Packed = bwpack(OneCellInNature);
    Packed = imerode(Packed, strel('disk', 6, 0), 'ispacked', size(OneCellInNature,1));
    OneCellInNature = bwunpack(Packed, size(OneCellInNature, 1));
%% Checking if the current cell is not in the region with fluorescence out of Z-range    
    if ~isempty(find(OneCellInNature + OutOfZMask == 2))
        continue
    end      
%% Finding the four cell tips                        
    [OneCell_CellEnds, OneCell_CellWidthEnds, OneCell_CellsPixels, OneCell_GoodCells] = ... 
        f_Cell4TipsDetect(OneCellInNature, AllBinCellsFigNb, MinCellWidth, MaxCellWidth, MinCellLength, MaxCellLength);             
    % If no good cell were detected or after image erosion 
    % two cells were created instead of one, ignore this object
    if isempty(OneCell_GoodCells) || isempty(OneCell_CellEnds) || size(OneCell_GoodCells, 1) > 1  
        continue
    end
%% Accumulation of data for all the cells in the image
    CellEnds = [CellEnds; OneCell_CellEnds];
    CellWidthEnds = [CellWidthEnds; OneCell_CellWidthEnds];
    CellsPixels = [CellsPixels; OneCell_CellsPixels];
    % 'GoodCells' contains:
    % CellNb|Cell_Lengths|Cell_Width|AxisAngle|Cell_Center: x1|y1|Cell_Tips: x1|x2|y1|y2|Area 
    GoodCells = [GoodCells; Nb_Cell, OneCell_GoodCells(2:6), OneCell_CellEnds(1:4), Stats.Area];

    CellCenter = OneCell_GoodCells(5:6);
    Nb_Cell = Nb_Cell + 1;                                                
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
            if CellWidth > CellWidthOld                        
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
end              
% end     
%% Visualisation of cell objects after the un-overlapping procedure
FinalImage = zeros(size(InitImage));
% Filling with 1s the places where 'final good' cells are detected
for i_vis = 1:length(CellsPixels)
    for i_OnePix = 1:length(CellsPixels{i_vis})     % Better to use 'size', but here it doesn't matter
%             i_OnePix = 1:length(CellsPixels{i_vis});
        FinalImage(CellsPixels{i_vis}(i_OnePix, 2), CellsPixels{i_vis}(i_OnePix, 1)) = 1;
    end
end
%     figure, imshow(FinalImage, []);
%% Representing borders of the segmented image overlaid with BF image 
BWoutline = bwperim(FinalImage);   % To find perimeter pixels in binary image
Segout = InitImage;   
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
%% Visualisation of the 'good cells' centers     
%figure(ResFigNb);
[Lin_CPix, Col_CPix] = size(CellEnds);
for i_GC = 1:Lin_CPix     % Loop on the good cells        
%         Fig = figure(); 
%         imshow(InitImage, []);
    line(CellEnds(i_GC, 5), CellEnds(i_GC, 6), 'Color', [.8 0 0], 'Marker', 'o');  
%         saveas(Fig, ['Output/CellNumber' num2str(i_GC)]);
end  






