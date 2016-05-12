function [CellEnds, CellWidthEnds, CellsPixels, GoodCells] = cell4TipsDetect(BigRegions, ImageFigNb, MinCellWidth, MaxCellWidth, MinCellLength, MaxCellLength)
%--------------------------------------------------------------------------
%!!!--!!! Length of the lines along which we take intensity profiles
%-- to obtain maximum values for the length
    LineLength = MaxCellLength;  
%!!!--!!! Length of the lines along which we take intensity profiles
%-- to obtain maximum values for the width
    LineLengthW = MaxCellWidth;   
%!!!--!!! The value added to the automaticly detected half cell width to
%-- get the initial position of line center for lines along which we take
%-- intensity profiles to obtain maximum values for width
    HWPlus = 0;
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
%----- Finding one of cell tips: going along the major axis of the ellipse
%-- towards the center until finding the line with a point that is white on BigRegions
        BorderFlag = 0;
        HalfLength = (Stats(i).MajorAxisLength / 2) + HWPlus;
        LengthFlag = 0;                           
        while (HalfLength > 0)
            x1 = x0 + HalfLength * cosd(Angle);
            y1 = y0 - HalfLength * sind(Angle); 
            % Condition for the center of the line being inside the image 
            if (uint16(x1) > 0) & (uint16(x1) < n + 1) & (uint16(y1) > 0) & (uint16(y1) < m + 1)
                % At first, calculations in the normal XY axis, but with the center in the
                % center of the cell

                % Calculating coordinates of the center of this perpendicular line
                % It lies on the line perpendicular to cell axis, so Angle +????? 90 degrees
                % It lies at the distance 'HalfWidth' from cell center
                LineCenter = [HalfLength * cosd(Angle), HalfLength * sind(Angle)];  
                % Calculating coordinates of the ends of this perpendicular line
                % It lies on the line parallel to cell axis, so angle is Angle
                % The line has a fixed length: LineLength
                Line1_x = [LineCenter(1) - (LineLengthW/2)*sind(Angle), LineCenter(1) + (LineLengthW/2)*sind(Angle)];
                Line1_y = [LineCenter(2) + (LineLengthW/2)*cosd(Angle), LineCenter(2) - (LineLengthW/2)*cosd(Angle)];  
                % Passage back to normal Oxy axis
                CellCenter = Stats(i).Centroid;                    
                Line1_x = Line1_x + CellCenter(1);
                Line1_y = -Line1_y + CellCenter(2);               
                % Checking the position of the line                    
%                     figure(10); %FigNb = FigNb + 1;
%                     imshow(BigRegions); 
%                     line(Line1_x, Line1_y);  
%                     line(CellCenter(1), CellCenter(2), 'Color', [0 .8 0], 'Marker', 'o');  
%                      line(LineCenter(1) + CellCenter(1), -LineCenter(2) + CellCenter(2), 'Color', [.8 0 0], 'Marker', 'o');  
                % Not to have problems (NaN) when calculating intensity
                % profile, we take as coordinates of the line ends
                % the min/max between the calculated values and the
                % borders of the image
                for i_NaN = 1:2
                   if (uint16(Line1_x(i_NaN)) < 1)
                       Line1_x(i_NaN) = 1;
                   end
                   if (uint16(Line1_x(i_NaN)) > n)
                       Line1_x(i_NaN) = n;
                   end                       
                   if (uint16(Line1_y(i_NaN)) < 1)
                       Line1_y(i_NaN) = 1;
                   end
                   if (uint16(Line1_y(i_NaN)) > m)
                       Line1_y(i_NaN) = m;
                   end                              
                end
                % Calculating intensity profiles for the line 
                PlotProfile = (improfile(BigRegions, Line1_x, Line1_y))';
%                     if (PlotProfile(1) == NaN)     % Cell is at the border
%                         continue
%                     end 
                LengthFlag = max(max(PlotProfile));   % Flag showing that we attained the 'width limit' of the cell                    
%                     figure(FigNb); %FigNb = FigNb + 1;   
%                     plot(PlotProfile, 's', 'MarkerSize', 3); grid on;                     
%                     title('Intensity profile');
%                     xlabel('Position, in pixels');
%                     ylabel('Intensity');                                                                                
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
        LengthFlag = 0;
        while (HalfLength > 0)
            x2 = x0 - HalfLength * cosd(Angle);
            y2 = y0 + HalfLength * sind(Angle);                         
            if (uint16(x2) > 0) & (uint16(x2) < n + 1) & (uint16(y2) > 0) & (uint16(y2) < m + 1)
                % At first, calculations in the normal XY axis, but with the center in the
                % center of the cell

                % Calculating coordinates of the center of this perpendicular line
                % It lies on the line perpendicular to cell axis, so Angle +????? 90 degrees
                % It lies at the distance 'HalfWidth' from cell center
                LineCenter = [-HalfLength * cosd(Angle), -HalfLength * sind(Angle)];  
                % Calculating coordinates of the ends of this perpendicular
                % line
                % It lies on the line parallel to cell axis, so angle is Angle
                % The line has a fixed length: LineLength
                Line1_x = [LineCenter(1) - (LineLengthW/2)*sind(Angle), LineCenter(1) + (LineLengthW/2)*sind(Angle)];
                Line1_y = [LineCenter(2) + (LineLengthW/2)*cosd(Angle), LineCenter(2) - (LineLengthW/2)*cosd(Angle)];  
                % Passage back to normal Oxy axis
                %CellCenter = Stats(i).Centroid;                    
                Line1_x = Line1_x + CellCenter(1);
                Line1_y = -Line1_y + CellCenter(2);               
                % Checking the position of the line
%                     figure(FigNb); FigNb = FigNb + 1;
%                     imshow(BigRegions); 
%                     line(Line1_x, Line1_y);  
%                     line(CellCenter(1), CellCenter(2), 'Color', [0 .8 0], 'Marker', 'o');  
%                     line(LineCenter(1) + CellCenter(1), -LineCenter(2) + CellCenter(2), 'Color', [.8 0 0], 'Marker', 'o');  
                % Not to have problems (NaN) when calculating intensity
                % profile, we take as coordinates of the line ends
                % the min/max between the calculated values and the
                % borders of the image
                for i_NaN = 1:2
                   if (uint16(Line1_x(i_NaN)) < 1)
                       Line1_x(i_NaN) = 1;
                   end
                   if (uint16(Line1_x(i_NaN)) > n)
                       Line1_x(i_NaN) = n;
                   end                       
                   if (uint16(Line1_y(i_NaN)) < 1)
                       Line1_y(i_NaN) = 1;
                   end
                   if (uint16(Line1_y(i_NaN)) > m)
                       Line1_y(i_NaN) = m;
                   end                              
                end
                % Calculating intensity profiles for the line 
                PlotProfile = (improfile(BigRegions, Line1_x, Line1_y))';     
                LengthFlag = max(max(PlotProfile));   % Flag showing that we attained the 'width limit' of the cell
%                     figure(FigNb); %FigNb = FigNb + 1;   
%                     plot(PlotProfile, 's', 'MarkerSize', 3); grid on;                     
%                     title('Intensity profile');
%                     xlabel('Position, in pixels');
%                     ylabel('Intensity');                           
                if (LengthFlag == 1)   
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
            CellEnds(CE_Lin, :) = [];            % Taking this cell from the matrix with cell ends of good cells
            continue 
        end    
%% Measuring cell width and checking its conformity to normal values           
% CellWidthEnds format for one StatsCont entry is [x1, y1, x2, y2, x_CellCenter, y_CellCenter])                                         
%% Get maximum width end 1: Looking at 'intensity profiles' perpendicular
%% to the detected width
        BorderFlag = 0;
        HalfWidth = (Stats(i).MinorAxisLength / 2) + HWPlus;
        WidthFlag = 0;                        
        while (HalfWidth > 0)
            x1 = x0 - HalfWidth * sind(Angle);
            y1 = y0 - HalfWidth * cosd(Angle);  

            if (uint16(x1) > 0) & (uint16(x1) < n + 1) & (uint16(y1) > 0) & (uint16(y1) < m + 1) % To make sure coordinates are inside the image
                % At first, calculations in the normal XY axis, but with the center in the
                % center of the cell

                % Calculating coordinates of the center of this perpendicular line
                % It lies on the line perpendicular to cell axis, so Angle +????? 90 degrees
                % It lies at the distance 'HalfWidth' from cell center
                LineCenter = [HalfWidth * cosd(Angle + 90), HalfWidth * sind(Angle + 90)];  
                % Calculating coordinates of the ends of this perpendicular line
                % It lies on the line parallel to cell axis, so angle is Angle
                % The line has a fixed length: LineLength
                Line1_x = [LineCenter(1) - (LineLength/2)*sind(Angle + 90), LineCenter(1) + (LineLength/2)*sind(Angle + 90)];
                Line1_y = [LineCenter(2) + (LineLength/2)*cosd(Angle + 90), LineCenter(2) - (LineLength/2)*cosd(Angle + 90)];  
                % Passage back to normal Oxy axis
                %CellCenter = Stats(i).Centroid;                    
                Line1_x = Line1_x + CellCenter(1);
                Line1_y = -Line1_y + CellCenter(2);               
                % Checking the position of the line
%                     figure(FigNb); FigNb = FigNb + 1;
%                     imshow(BigRegions); 
%                     line(Line1_x, Line1_y);  
%                     line(CellCenter(1), CellCenter(2), 'Color', [0 .8 0], 'Marker', 'o');  
%                     line(LineCenter(1) + CellCenter(1), -LineCenter(2) + CellCenter(2), 'Color', [.8 0 0], 'Marker', 'o');  
                % Not to have problems (NaN) when calculating intensity
                % profile, we take as coordinates of the line ends
                % the min/max between the calculated values and the
                % borders of the image
                for i_NaN = 1:2
                   if (uint16(Line1_x(i_NaN)) < 1)
                       Line1_x(i_NaN) = 1;
                   end
                   if (uint16(Line1_x(i_NaN)) > n)
                       Line1_x(i_NaN) = n;
                   end                       
                   if (uint16(Line1_y(i_NaN)) < 1)
                       Line1_y(i_NaN) = 1;
                   end
                   if (uint16(Line1_y(i_NaN)) > m)
                       Line1_y(i_NaN) = m;
                   end                              
                end
                % Calculating intensity profiles for the line 
                PlotProfile = (improfile(BigRegions, Line1_x, Line1_y))';     
                WidthFlag = max(max(PlotProfile));   % Flag showing that we attained the 'width limit' of the cell
%                     figure(FigNb); %FigNb = FigNb + 1;   
%                     plot(PlotProfile, 's', 'MarkerSize', 3); grid on;                     
%                     title('Intensity profile');
%                     xlabel('Position, in pixels');
%                     ylabel('Intensity');                     
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
        BorderFlag = 0;
        WidthFlag = 0;
        while (HalfWidth > 0)
            x2 = x0 + HalfWidth * sind(Angle);
            y2 = y0 + HalfWidth * cosd(Angle);               
            if (uint16(x2) > 0) & (uint16(x2) < n + 1) & (uint16(y2) > 0) & (uint16(y2) < m + 1)
                % At first, calculations in the cartesian XY axis, but with the center in the
                % center of the cell

                % Calculating coordinates of the center of this perpendicular line
                % It lies on the line perpendicular to cell axis, so Angle +????? 90 degrees
                % It lies at the distance 'HalfWidth' from cell center
                LineCenter = [-HalfWidth * cosd(Angle + 90), -HalfWidth * sind(Angle + 90)];
                % Calculating coordinates of the ends of this perpendicular line
                % It lies on the line parallel to cell axis, so angle is Angle
                % The line has a fixed length: LineLength
                Line1_x = [LineCenter(1) - (LineLength/2)*sind(Angle + 90), LineCenter(1) + (LineLength/2)*sind(Angle + 90)];
                Line1_y = [LineCenter(2) + (LineLength/2)*cosd(Angle + 90), LineCenter(2) - (LineLength/2)*cosd(Angle + 90)];  
                % Passage back to normal Oxy axis
                %CellCenter = Stats(i).Centroid;                    
                Line1_x = Line1_x + CellCenter(1);
                Line1_y = -Line1_y + CellCenter(2);               
                % Checking the position of the line
%                     figure(FigNb); FigNb = FigNb + 1;
%                     imshow(BigRegions); 
%                     line(Line1_x, Line1_y);  
%                     line(CellCenter(1), CellCenter(2), 'Color', [0 .8 0], 'Marker', 'o');  
%                     line(LineCenter(1) + CellCenter(1), -LineCenter(2) + CellCenter(2), 'Color', [.8 0 0], 'Marker', 'o');  
                % Not to have problems (NaN) when calculating intensity
                % profile, we take as coordinates of the line ends
                % the min/max between the calculated values and the
                % borders of the image
                for i_NaN = 1:2
                   if (uint16(Line1_x(i_NaN)) < 1)
                       Line1_x(i_NaN) = 1;
                   end
                   if (uint16(Line1_x(i_NaN)) > n)
                       Line1_x(i_NaN) = n;
                   end                       
                   if (uint16(Line1_y(i_NaN)) < 1)
                       Line1_y(i_NaN) = 1;
                   end
                   if (uint16(Line1_y(i_NaN)) > m)
                       Line1_y(i_NaN) = m;
                   end                              
                end
                % Calculating intensity profiles for the line 
                PlotProfile = (improfile(BigRegions, Line1_x, Line1_y))';     
                WidthFlag = max(max(PlotProfile));   % Flag showing that we attained the 'width limit' of the cell
%                     figure(FigNb); %FigNb = FigNb + 1;   
%                     plot(PlotProfile, 's', 'MarkerSize', 3); grid on;                     
%                     title('Intensity profile');
%                     xlabel('Position, in pixels');
%                     ylabel('Intensity');                                         
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
        hold on;
        line([CellEnds(CE_Lin, 1), CellEnds(CE_Lin, 3)], [CellEnds(CE_Lin, 2), CellEnds(CE_Lin, 4)]);            
        % Visualisation of the cell width            
        line([CellWidthEnds(CWE_Lin, 1), CellWidthEnds(CWE_Lin, 3)], [CellWidthEnds(CWE_Lin, 2), CellWidthEnds(CWE_Lin, 4)]);            
        % Visualisation of the cell center        
        %line(Stats(i).Centroid(1), Stats(i).Centroid(2), 'Color', [.8 0 0], 'Marker', 'o');  
        hold off;
    end
end
