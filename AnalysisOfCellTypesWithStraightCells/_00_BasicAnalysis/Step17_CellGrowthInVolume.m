%% The task of the program is to measure cell volume growth over time
clear;     
close all;
%% ------------------------------------------------------------------------
ImageSize = [2048, 2048];
dX = 5;     % Size of the step for the integration
% MicronsInPixel = 0.13;   % RS bin2            % 0.065;   RS bin1
% %!!!--!!! Ratio between Z-step in stacks (in microns) and resolution in XY- plane 
% ZspacePx = 0.25 / MicronsInPixel;       % Distance between Z-planes(in X-Y pixel size units)
% PathAllGoodCells = '_OutputGI/output_GoodCellsParams.mat';
% PathCellPixels = '_OutputGI/output_CellsPixels.mat';
% PathMidPlanes = '_OutputGI/AllMiddlePlanes.mat';
%% ------------------------------------------------------------------------
load('_Output/output_CellsTracks.mat');
load('_Output/output_CellsPixels.mat');
load('_Output/output_GoodCellsParams.mat');

% load(PathCellPixels);  % 'AllCellsPixels': one line is one image
% load(PathAllGoodCells);  % 'AllGoodCells': one line is one image
% load(PathMidPlanes); % 'AllMiddlePlanes': middle Z-positions used 

AllContours = cell(size(CellsTrack));
% AllProfilesTipEnd1 = cell(size(CellsTrack));
AllProfilesSquare = cell(size(CellsTrack));
AllCellEnds = cell(size(CellsTrack));

CellVolumes = cell(size(CellsTrack, 1), 1);
for i_Cell = 1:size(CellsTrack, 1)          % Loop on the cells 
    VcellOverTime = zeros(size(CellsTrack, 2), 1);      % Matrix for cell volumes over time for one cell
    for i_Frame = 1:size(CellsTrack, 2) 
        close all;   
        PerimPts = [];
        
        RealCellNb = CellsTrack(i_Cell, i_Frame);
        if RealCellNb == 0     % This cell was not well detected on BF image
            continue
        end        
        FramePixels = AllCellsPixels{i_Frame};
        CellPixels = FramePixels{RealCellNb};
        
        %% Preparing the black image with white pixels belonging to the cell 
        CellMask = zeros(ImageSize);
        CellMask(sub2ind(ImageSize, CellPixels(:,2), CellPixels(:,1))) = 1;
%         figure, imshow(CellMask);       
%         %% Making a black frame around the image, in case cell mask touches
%         %% the image border (without this step 'bwperim' doesn't work)
%         CellMask(:,1:2) = 0;
%         figure, imshow(CellMask);       
        %% Creating the matrix with cell outline coordinates
        [PerimPts(:,2), PerimPts(:,1)] = find(bwperim(CellMask)); % 'Outline' is [X,Y]    
%         figure, plot(PerimPts(:, 1), PerimPts(:, 2), 'r.');
        %% Retrieve the parameters of the cell
        Angle = AllGoodCells{i_Frame}(RealCellNb, 4);        
        CellTips = AllGoodCells{i_Frame}(RealCellNb, 7:10);     
        CellTips = [CellTips(1), CellTips(2); CellTips(3), CellTips(4)];% [x1, y1; x2, y2]                        
%         line([CellTips(1), CellTips(2)], [CellTips(3), CellTips(4)]);     % Visualisation of the position of the cell tips                  
        %% Going into reference system with bottom cell tip as 0 and rotating
        % Choosing the right tip
        if CellTips(1, 2) > CellTips(2, 2)
            TheTip = CellTips(1,:);
        else
            TheTip = CellTips(2,:);
        end
        % Transforming coordinates
        PerimPtsRot = zeros(size(PerimPts));
        % figure, hold on
        AngleRot = -Angle;
        % Putting 0 of the reference system in the bottom cell tip
        PerimPts(:, 1) = PerimPts(:, 1) - TheTip(1);
        PerimPts(:, 2) = PerimPts(:, 2) - TheTip(2);
        % Rotating the cell outline to have cell axis lying on the Ox
        PerimPtsRot(:, 1) = PerimPts(:, 1) * cosd(AngleRot) + PerimPts(:, 2) * sind(AngleRot);   % X
        PerimPtsRot(:, 2) = - PerimPts(:, 1) * sind(AngleRot) + PerimPts(:, 2) * cosd(AngleRot); % Y
%         figure, plot(PerimPtsRot(:, 1), PerimPtsRot(:, 2), 'r.'), grid on;
        %% 
        %% Take only the upper half
        LinesToKeep = PerimPtsRot(:,2) > 0;
        UpperHalf = PerimPtsRot(LinesToKeep, :);
%         figure, plot(UpperHalf(:, 1), UpperHalf(:, 2), 'r.'), grid on;
        %% If any points' X are beyond the limits of the cell length,
        %% discard these points
        tmp = UpperHalf;
        [a, Ind1] = min(tmp(:,2));        
        tmp(Ind1,:) = [max(tmp(:,2)), max(tmp(:,2))];
        [a, Ind2] = min(tmp(:,2));
        if UpperHalf(Ind1, 1) < UpperHalf(Ind2, 1)
            MinXind = Ind1;
            MaxXind = Ind2;
        else 
            MinXind = Ind2;
            MaxXind = Ind1;
        end
        MinX = UpperHalf(MinXind, 1);
        MaxX = UpperHalf(MaxXind, 1);
        DiscardMin = find(UpperHalf(:, 1) < MinX);
        DiscardMax = find(UpperHalf(:, 1) > MaxX);
        UpperHalf([DiscardMin; DiscardMax], :) = [];        
%         figure, plot(UpperHalf(:, 1), UpperHalf(:, 2), 'r.'), grid on;
        %% Sum up the volumes of the slices produced by the rotation of the
        %% upper half of the cell outline
        Vcell_Upper = 0;
        for i_Slice = 1:(MaxX - MinX)/dX + 1
            SliceMinX = MinX + (i_Slice - 1) * dX;
            SliceMaxX = SliceMinX + dX;
            
            SlicePtsYs = UpperHalf(find((UpperHalf(:,1) >= SliceMinX) & (UpperHalf(:,1) < SliceMaxX)), 2);
            Ri = mean(SlicePtsYs);
            VSlice = pi * Ri^2 * dX;
            Vcell_Upper = Vcell_Upper + VSlice;
        end
        %%
        %% Take only the lower half
        LinesToKeep = PerimPtsRot(:,2) < 0;
        LowerHalf = PerimPtsRot(LinesToKeep, :);
        % Invert the half-outline to have positive Ys
        LowerHalf(:,2) = -LowerHalf(:,2);
%         figure, plot(LowerHalf(:, 1), LowerHalf(:, 2), 'r.'), grid on;
        %% If any points' X are beyond the limits of the cell length,
        %% discard these points
        tmp = LowerHalf;
        [a, Ind1] = min(tmp(:,2));        
        tmp(Ind1,:) = [max(tmp(:,2)), max(tmp(:,2))];
        [a, Ind2] = min(tmp(:,2));
        if LowerHalf(Ind1, 1) < LowerHalf(Ind2, 1)
            MinXind = Ind1;
            MaxXind = Ind2;
        else 
            MinXind = Ind2;
            MaxXind = Ind1;
        end
        MinX = LowerHalf(MinXind, 1);
        MaxX = LowerHalf(MaxXind, 1);
        DiscardMin = find(LowerHalf(:, 1) < MinX);
        DiscardMax = find(LowerHalf(:, 1) > MaxX);
        LowerHalf([DiscardMin; DiscardMax], :) = [];
%         figure, plot(LowerHalf(:, 1), LowerHalf(:, 2), 'r.'), grid on;
        %% Sum up the volumes of the slices produced by the rotation of the
        %% upper half of the cell outline
        Vcell_Lower = 0;
        for i_Slice = 1:(MaxX - MinX)/dX + 1
            SliceMinX = MinX + (i_Slice - 1) * dX;
            SliceMaxX = SliceMinX + dX;
            
            SlicePtsYs = LowerHalf(find((LowerHalf(:,1) >= SliceMinX) & (LowerHalf(:,1) < SliceMaxX)), 2);
            Ri = mean(SlicePtsYs);
            VSlice = pi * Ri^2 * dX;
            Vcell_Lower = Vcell_Lower + VSlice;
        end
        %%
        %% Total cell volume
        Vcell = (Vcell_Upper + Vcell_Lower) / 2;
        VcellOverTime(i_Frame) = Vcell;        % Accumulate the volumes of the cells over all time frames
    end
    CellVolumes{i_Cell} = VcellOverTime;
end