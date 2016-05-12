%% This version of the function detects cell tips until the point where
%% cell axes cross cell outline (going inwards along these axes)
function [CellEnds, CellWidthEnds, CellsPixels, GoodCells] = f_Cell4TipsDetect(BigRegions, ImageFigNb, MinCellWidth, MaxCellWidth, MinCellLength, MaxCellLength)
%--------------------------------------------------------------------------
%!!!--!!! The value added to the automaticly detected half cell width to
%-- get the initial position to obtain maximum values for width
    HWPlus = 5;
%--------------------------------------------------------------------------
    CellEnds = [];
    CellWidthEnds = []; 
    CellsPixels = [];
    GoodCells = [];
    
    [m, n] = size(BigRegions);
    Labels = bwlabel(BigRegions); 
    Stats = regionprops(Labels, 'Centroid', 'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'PixelList');               
    for i = 1:length(Stats) 
%         CellCenter = Stats(i).Centroid;                    
%% Measuring cell length and checking its conformity to normal values
% Calculation of the coordinates of cell ends in format [x1, y1; x2, y2]                        
        x0 = Stats(i).Centroid(1);
        y0 = Stats(i).Centroid(2);
        Angle = Stats(i).Orientation;            
%----- Finding one of cell tips: going along the major axis of the ellipse
%-- towards the center until finding the line with a point that is white on BigRegions
        BorderFlag = 0;
        HalfLength = (Stats(i).MajorAxisLength / 2) + HWPlus;
        HalfLength0 = HalfLength;
        LengthFlag = 0;                           
        while (HalfLength > - HalfLength)
            x1 = x0 + HalfLength * cosd(Angle);
            y1 = y0 - HalfLength * sind(Angle); 
            % Condition for the position being inside the image 
            if (uint16(x1) > 0) & (uint16(x1) < n + 1) & (uint16(y1) > 0) & (uint16(y1) < m + 1)
                LengthFlag = BigRegions(uint16(y1), uint16(x1));
                if (LengthFlag == 1)   
                    ElemEnds = [x1, y1];
                    break
                else
                    HalfLength = HalfLength - 1;
                end                
            else
                BorderFlag = 1;     % The cell is at the border of the image
                break                   
            end
        end
        if (BorderFlag == 1)    % If the cell was at the border, not continue with the analysis
            continue
        end
%----- Finding the second true cell tip
        BorderFlag = 0;
        HalfLength = (Stats(i).MajorAxisLength / 2) + HWPlus;
        HalfLength0 = HalfLength;
        LengthFlag = 0;
        while (HalfLength > - HalfLength)
            x2 = x0 - HalfLength * cosd(Angle);
            y2 = y0 + HalfLength * sind(Angle);                         
            if (uint16(x2) > 0) & (uint16(x2) < n + 1) & (uint16(y2) > 0) & (uint16(y2) < m + 1)  
                LengthFlag = BigRegions(uint16(y2), uint16(x2));
                if (LengthFlag == 1)   
                    CellCenter = [(x1 + x2)/2; (y1 + y2)/2];
                    CellEnds = [CellEnds; [ElemEnds, x2, y2, CellCenter(1), CellCenter(2)]];                        
                    break
                else
                    HalfLength = HalfLength - 1;
                end
            else
                BorderFlag = 1;     % The cell is at the border of the image
                break                   
            end                    
        end                        
        if BorderFlag == 1      % The cell is at the border of the image               
            continue
        end

        CellLength = sqrt((x2-x1)^2 + (y2-y1)^2);
        [CE_Lin, a] = size(CellEnds);
        if (CellLength < MinCellLength) | (CellLength > MaxCellLength)  
            if ~isempty(CellEnds)
                CellEnds(CE_Lin, :) = [];            % Taking this cell from the matrix with cell ends of good cells
            end
            continue 
        end    
%% Measuring cell width and checking its conformity to normal values           
% CellWidthEnds format for one StatsCont entry is [x1, y1, x2, y2, x_CellCenter, y_CellCenter])                                         
%% Get maximum width end 1: Looking at 'intensity profiles' perpendicular
%% to the detected width
        BorderFlag = 0;
        HalfWidth = (Stats(i).MinorAxisLength / 2) + HWPlus;
        HalfWidth0 = HalfWidth;
        WidthFlag = 0;                        
        while (HalfWidth > - HalfWidth0)
            x1 = x0 - HalfWidth * sind(Angle);
            y1 = y0 - HalfWidth * cosd(Angle);  

            if (uint16(x1) > 0) & (uint16(x1) < n + 1) & (uint16(y1) > 0) & (uint16(y1) < m + 1) % To make sure coordinates are inside the image
                WidthFlag = BigRegions(uint16(y1), uint16(x1));
                if (WidthFlag == 1)    % End of cell width is reached                       
                    ElemWidthEnds = [x1, y1];                        
                    break
                else
                    HalfWidth = HalfWidth - 1;
                end                
            else
                BorderFlag = 1;     % The cell is at the border of the image
                break                   
            end
        end
        if BorderFlag == 1      % The cell is at the border of the image  
        % Take away 'CellEnds' element added already (along the long cell axis the cell is well in the image)
            [CE_Lin, a] = size(CellEnds);
            CellEnds(CE_Lin, :) = [];            
            continue
        end            
%% Get maximum width end 2: Looking at 'intensity profiles' perpendicular
%% to the detected width
        HalfWidth = (Stats(i).MinorAxisLength / 2) + HWPlus;
        HalfWidth0 = HalfWidth;
        BorderFlag = 0;
        WidthFlag = 0;
        while (HalfWidth > - HalfWidth0)        % In case an object can be very thin in the middle
            x2 = x0 + HalfWidth * sind(Angle);
            y2 = y0 + HalfWidth * cosd(Angle);               
            if (uint16(x2) > 0) & (uint16(x2) < n + 1) & (uint16(y2) > 0) & (uint16(y2) < m + 1)
                WidthFlag = BigRegions(uint16(y2), uint16(x2));
                if (WidthFlag == 1)                          
                    CellWidthEnds = [CellWidthEnds; [ElemWidthEnds, x2, y2, CellCenter(1), CellCenter(2)]];
                    break
                else
                    HalfWidth = HalfWidth - 1;
                end
            else
                BorderFlag = 1;     % The cell is at the border of the image
                break                   
            end                    
        end                        
        if BorderFlag == 1      % The cell is at the border of the image
        % Take away 'CellEnds' element added already (along the long cell axis the cell is well in the image)
            [CE_Lin, a] = size(CellEnds);
            CellEnds(CE_Lin, :) = [];
            continue
        end

        CellWidth = sqrt((x2-x1)^2 + (y2-y1)^2);
        [CWE_Lin, a] = size(CellWidthEnds);
        [CE_Lin, a] = size(CellEnds);
        if (CellWidth < MinCellWidth) || (CellWidth > MaxCellWidth)                 
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
        hold on;
        line([CellEnds(CE_Lin, 1), CellEnds(CE_Lin, 3)], [CellEnds(CE_Lin, 2), CellEnds(CE_Lin, 4)]);            
        % Visualisation of the cell width            
        line([CellWidthEnds(CWE_Lin, 1), CellWidthEnds(CWE_Lin, 3)], [CellWidthEnds(CWE_Lin, 2), CellWidthEnds(CWE_Lin, 4)]);            
        % Visualisation of the cell center        
        %line(Stats(i).Centroid(1), Stats(i).Centroid(2), 'Color', [.8 0 0], 'Marker', 'o');  
        hold off;
    end
end
