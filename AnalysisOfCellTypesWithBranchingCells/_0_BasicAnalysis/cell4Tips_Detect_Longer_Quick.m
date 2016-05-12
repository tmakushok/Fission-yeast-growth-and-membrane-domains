function [CellEnds, CellWidthEnds, CellsPixels, GoodCells] = cell4TipsDetect(BigRegions, ImageFigNb, MinCellWidth, MaxCellWidth, MinCellLength, MaxCellLength)
%--------------------------------------------------------------------------
%!!!--!!! Additional pixels added on both sides of each cell
%-- (cell will look longer after length detection)
AddLength = 10;
%--------------------------------------------------------------------------
    CellEnds = [];
    CellWidthEnds = []; 
    CellsPixels = [];
    GoodCells = [];
    
    [m, n] = size(BigRegions);
    Labels = bwlabel(BigRegions); 
    Stats = regionprops(Labels, 'Centroid', 'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'PixelList');               
    for i = 1:length(Stats) 
%% Measuring cell length and checking its conformity to normal values
% Calculation of the coordinates of cell ends in format [x1, y1; x2, y2]                        
        x0 = Stats(i).Centroid(1);
        y0 = Stats(i).Centroid(2);
        Angle = Stats(i).Orientation;
        CellCenter = Stats(i).Centroid; 
%----- Finding one of cell tips: going along the major axis of the ellipse
%-- towards the center until finding the line with a point that is white on BigRegions
        HalfLength = (Stats(i).MajorAxisLength / 2) + AddLength;                                           
        x1 = x0 + HalfLength * cosd(Angle);
        y1 = y0 - HalfLength * sind(Angle); 
        % Condition for the center of the line being inside the image 
        if (uint16(x1) > 0) & (uint16(x1) < n + 1) & (uint16(y1) > 0) & (uint16(y1) < m + 1)                                                                                                                                       
            ElemEnds = [x1, y1];                                 
        else            
            continue                 
        end        
%----- Finding the second true cell tip                  
        x2 = x0 - HalfLength * cosd(Angle);
        y2 = y0 + HalfLength * sind(Angle);                         
        if (uint16(x2) > 0) & (uint16(x2) < n + 1) & (uint16(y2) > 0) & (uint16(y2) < m + 1)                                
            CellEnds = [CellEnds; [ElemEnds, x2, y2, CellCenter(1), CellCenter(2)]];                                            
        else            
            continue                  
        end                            

        CellLength = sqrt((x2-x1)^2 + (y2-y1)^2);
        [CE_Lin, a] = size(CellEnds);
        if (CellLength < MinCellLength) | (CellLength > MaxCellLength)                               
            CellEnds(CE_Lin, :) = [];            % Taking this cell from the matrix with cell ends of good cells
            continue 
        end    
%% Measuring cell width and checking its conformity to normal values           
% CellWidthEnds format for one StatsCont entry is [x1, y1, x2, y2, x_CellCenter, y_CellCenter])                                         
%% Get maximum width end 1: Looking at 'intensity profiles' perpendicular
%% to the detected width
        HalfWidth = (Stats(i).MinorAxisLength / 2);
                                      
        x1 = x0 - HalfWidth * sind(Angle);
        y1 = y0 - HalfWidth * cosd(Angle);  
        if (uint16(x1) > 0) & (uint16(x1) < n + 1) & (uint16(y1) > 0) & (uint16(y1) < m + 1) % To make sure coordinates are inside the image   
            ElemWidthEnds = [x1, y1];                                    
        else
            % Take away 'CellEnds' element added already (along the long cell axis the cell is well in the image)
            [CE_Lin, a] = size(CellEnds);
            CellEnds(CE_Lin, :) = [];            
            continue                  
        end                       
%% Get maximum width end 2: Looking at 'intensity profiles' perpendicular
%% to the detected width
        HalfWidth = (Stats(i).MinorAxisLength / 2);      
             
        x2 = x0 + HalfWidth * sind(Angle);
        y2 = y0 + HalfWidth * cosd(Angle);               
        if (uint16(x2) > 0) & (uint16(x2) < n + 1) & (uint16(y2) > 0) & (uint16(y2) < m + 1)                        
            CellWidthEnds = [CellWidthEnds; [ElemWidthEnds, x2, y2, CellCenter(1), CellCenter(2)]];                                   
        else
            % Take away 'CellEnds' element added already (along the long cell axis the cell is well in the image)
            [CE_Lin, a] = size(CellEnds);
            CellEnds(CE_Lin, :) = [];
            continue                   
        end                                                        

        CellWidth = sqrt((x2-x1)^2 + (y2-y1)^2);
        [CWE_Lin, a] = size(CellWidthEnds);
        [CE_Lin, a] = size(CellEnds);
        if (CellWidth < MinCellWidth) | (CellWidth > MaxCellWidth)                 
            CellWidthEnds(CWE_Lin, :) = [];      % Taking this cell from stored 'half-good' cells
            CellEnds(CE_Lin, :) = [];            
            continue
        end  
%% Adding of the cell having good geometry to the CellsPixels and GoodCells array        
        CellsPixels = [CellsPixels; {Stats(i).PixelList}];
        GoodCells = [GoodCells; i, CellLength, CellWidth, Angle, Stats(i).Centroid];
%% Visualisation of geometrical parameters of the selected good cells 
        % Visualisation of the cell length
        %figure(FigNb), ImageFigNb = FigNb; FigNb = FigNb + 1;
        %imshow(InitImage);
        %imagesc(InitImage);
        figure(ImageFigNb); 
        line([CellEnds(CE_Lin, 1), CellEnds(CE_Lin, 3)], [CellEnds(CE_Lin, 2), CellEnds(CE_Lin, 4)]);            
        % Visualisation of the cell width            
        line([CellWidthEnds(CWE_Lin, 1), CellWidthEnds(CWE_Lin, 3)], [CellWidthEnds(CWE_Lin, 2), CellWidthEnds(CWE_Lin, 4)]);            
        % Visualisation of the cell center        
        %line(Stats(i).Centroid(1), Stats(i).Centroid(2), 'Color', [.8 0 0], 'Marker', 'o');  
    end
end
