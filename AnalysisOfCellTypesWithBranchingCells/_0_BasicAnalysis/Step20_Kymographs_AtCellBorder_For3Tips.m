%% Construction of the kymographs using cell aray 'AllProfiles'
%% !!! Need to check all kymographs to see if they are fine and delete from
%% 'AllKymos' all bad lines
%% This version of the program centeres the kymo around a point on cell
%% border corresponding to cell center (the point does not move in time)

%% If there is a clear shift in the kymograph, that means that there is a
%% new cell end forming in the cell

clear;      % To erase variables that are in memory
close all;
%--------------------------------------------------------------------------
KymoLineLengthMax = 1300;
% Length of the half-line which intersection with cell outline defines
% opening and centering points for each line of the kymograph
HalfLineL = 150;    % This length has to take into account the length of the new end (T-shape)
%!!!--!!! File paths
AllContFile = '_Output/AllContours.mat';
AllProfFile = '_Output/AllProfiles_Square3.mat';
AllEndsFile = '_Output/output_GoodCellsParams.mat';
KymosFile = '_Output/AllKymographs.mat';
Out_KymoFile = '_Output/KymoCenterOfCell_'; 
AllKymosFile = '_Output/AllKymosCenter.mat'; 
TracksFile = '_Output/output_CellsTracks.mat';
%--------------------------------------------------------------------------
load(AllContFile);
load(AllProfFile);
load(AllEndsFile);
load(TracksFile);
OldKymos = load(KymosFile);
OldKymos = OldKymos.AllKymos;
AllProfiles = AllProfilesSquare;
clear AllProfilesSquare;

AllKymos = cell(size(AllProfiles, 1), 1);
%% Assembling the kymograph
% Columns of AllProfilesTipEnd1 contain time points for one cell
for i_cell = 1:size(AllProfiles, 1)        % Loop on all cells    
    i_cell
%     close all
    if isempty(OldKymos{i_cell})        % If the kymograph for this cell is anyway considered bad
        AllKymos{i_cell, 1} = [];
        continue
    end 
    % Cell center at the moment when the kymo actually starts for the
    % current cell
    InitTime = find(CellsTrack(i_cell, :));
    InitTime = InitTime(1);
    CellCenter = AllGoodCells{InitTime}(i_cell, 5:6);    % X and Y of cell center at the initial time point
%% Finding position on cell border that corresponds to the point closest
%% to initial cell center (used then for assembling the kymo (as reference for the opening point))
    Cont = AllContours{i_cell, InitTime};    % Y and X of the contour
    [a, ind] = min(sqrt((CellCenter(1) - Cont(:,2)) .^ 2 + (CellCenter(2) - Cont(:,1)) .^ 2));
    CenterInit = Cont(ind, :);  % Point (Y,X) on the cell border    
%% Defining the line going through 'CenterInit' and 'CellCenter'    
    x1 = CellCenter(1);
    x2 = CenterInit(2);
    y1 = CellCenter(2);  
    y2 = CenterInit(1);
    % Coefficients of the line
    a_Line = (y2-y1) / (x2-x1);
    b_Line = y1 - a_Line * x1;
%% Collecting points belonging to the the half-line which crossing with
%% cell outline produces the kymograph ends
    xSign = sign(x2 - x1);    % Shows if from cell center to line center X increases (xSign > 0) or decreases
    if abs(a_Line) > 1
        dX = 0.95 / abs(a_Line);     % The step in X to have one point per pixel; the coeffecient is to for sure have one pt or two per pixel
    else
        dX = 0.95;
    end
    Xmin = x1;
    % Creating a matrix of the X of the half-line
    for i_Open = 1:HalfLineL 
        HalfLine_Open(i_Open, 1) = Xmin + xSign * i_Open * dX;  % Can be > or < than Xmin, depending on 'xSign'
    end
    % Adding Y to that
    HalfLine_Open(:, 2) = a_Line * HalfLine_Open(:, 1) + b_Line; 
    % Taking off negative values from the coordinates of the line
    [row,col] = find(HalfLine_Open < 0);
    if ~isempty(row)
        [indDel, a] = min(row);
        HalfLine_Open = HalfLine_Open(1:indDel - 1, :);
    end
%% Collecting points belonging to the the half-line which crossing with
%% cell outline produces the center of each of the kymograph lines
    % Creating a matrix of the X of the half-line
    for i_Cent = 1:HalfLineL 
        % This half-line is on the other side from cell center in
        % comparison with HalfLine_Open
        HalfLine_Cent(i_Cent, 1) = Xmin - xSign * i_Cent * dX;  % Can be > or < than Xmin, depending on 'xSign'
    end
    % Adding Y to that
    HalfLine_Cent(:, 2) = a_Line * HalfLine_Cent(:, 1) + b_Line;
    % Taking off negative values from the coordinates of the line
    [row,col] = find(HalfLine_Cent < 0);
    if ~isempty(row)
        [indDel, a] = min(row);
        HalfLine_Cent = HalfLine_Cent(1:indDel - 1, :);   
    end
    % Another loop just for the check at the end of the loop if the
    % 'new' end is in the middle part of the kymo, ifnot- repeat with
    % replacement of opening and centering points
    for i_Test_SideOfKymo = 1:2     
%% Initialisations
        Kymograph = zeros(size(AllProfiles, 2), KymoLineLengthMax);
        KymoEnd1 = [];
        KymoEnd2 =[];
        KymoCE1 =[];
        KymoCE2 =[];
        Added =[];
        FlagNonZeroLine = 0;      % Flag showing the current number of the non-black lines
        for i_KymoLine = 1:size(AllProfiles, 2)        % loop on the time points for one cell     
            if isempty(AllProfiles{i_cell, i_KymoLine})
                % Putting the same point as previous to the visualisation matrixes
                KymoEnd1 = [KymoEnd1; KymoEnd1(length(KymoEnd1))];
                KymoEnd2 = [KymoEnd2; KymoEnd2(length(KymoEnd2))];   
                KymoCEs{i_KymoLine} = KymoCEs{i_KymoLine - 1};
                Added = [Added; Add1];
                continue
            end
            FlagNonZeroLine = FlagNonZeroLine + 1;  % Flag showing the current number of the non-black lines
            ProfToAdd = AllProfiles{i_cell, i_KymoLine}(:, 3);
            s_OneProf = size(ProfToAdd);        
%         figure, plot(1:s_OneProf(1), ProfToAdd, '-o', 'MarkerSize', 3);      
%% Find the position at cell border around which the kymo will be opened
%% This opening position is on the line defined by 'a_Line' and 'b_Line'
            Cont = AllContours{i_cell, i_KymoLine};    % Y and X of the contour         
            if FlagNonZeroLine == 1      % For the first non-black line we have to compare distances for each point of the half-line 
                for i_FromCenter = 1:size(HalfLine_Open,1)
                    D = sqrt((HalfLine_Open(i_FromCenter, 1) - Cont(:,2)) .^ 2 + (HalfLine_Open(i_FromCenter, 2) - Cont(:,1)) .^ 2);
                    [minD, ind] = min(D);                
                    if minD < 1
                        Shift = - ind;
                        break
                    end
                end
                OldCrossPt_Open = i_FromCenter;
            else        % For non-black lines from second on we know where was the previous intersection
                for i_FromCenter = max(OldCrossPt_Open - 15, 1):size(HalfLine_Open,1)     % '-5' for the case cell outline comes closer to the previous cell center
                    D = sqrt((HalfLine_Open(i_FromCenter, 1) - Cont(:,2)) .^ 2 + (HalfLine_Open(i_FromCenter, 2) - Cont(:,1)) .^ 2);
                    [minD, ind] = min(D);              
                    if minD < 1
                        Shift = - ind;
                        break
                    end
                end            
            end    
            D2Open = i_FromCenter;
%             figure, plot(D), grid on
%% Shift the profile_to_add to have one cell border position at the tips of the kymograph
            ProfToAdd = circshift(ProfToAdd, Shift);
%         figure, plot(ProfToAdd), grid on
            ContShifted = circshift(Cont, Shift);
%         figure, plot(ContShifted), grid on
%% Findind the position around which current line has to be centered        
            % Now at the two ends of the ContShifted we have the position at
            % which we opened the contour (close to 'Center').
            if FlagNonZeroLine == 1      % For the first non-black line we have to compare distances for each point of the half-line 
                for i_FromCenter = 1:size(HalfLine_Cent,1)
                    D = sqrt((HalfLine_Cent(i_FromCenter, 1) - ContShifted(:,2)) .^ 2 + (HalfLine_Cent(i_FromCenter, 2) - ContShifted(:,1)) .^ 2);
                    [minD, ind] = min(D);                
                    if minD < 1
                        ToCenter = ind; 
                        break
                    end
                end
                OldCrossPt_Cent = i_FromCenter;
            else        % For non-black lines from second on we know where was the previous intersection
                for i_FromCenter = max(OldCrossPt_Cent - 15, 1):size(HalfLine_Cent,1)     % '-5' for the case cell outline comes closer to the previous cell center
                    D = sqrt((HalfLine_Cent(i_FromCenter, 1) - ContShifted(:,2)) .^ 2 + (HalfLine_Cent(i_FromCenter, 2) - ContShifted(:,1)) .^ 2);
                    [minD, ind] = min(D);              
                    if minD < 1
                        ToCenter = ind; 
                        break
                    end
                end            
            end  
            D2Cent = i_FromCenter;
%         figure, plot(D), grid on        
%% Add black pixels at both sides of the lines
            Add1 = floor(KymoLineLengthMax/2) - ToCenter;     % smaller or equal
            Added = [Added; Add1];
            ProfLenShort = length(ProfToAdd);
            Add2 = ceil(KymoLineLengthMax/2) - ProfLenShort + ToCenter;      % bigger or equal
            ProfToAdd = [zeros(1, Add1), ProfToAdd', zeros(1, Add2)];
%         ProfToAdd = [-20 * ones(1, Add1), ProfToAdd', -20 * ones(1, Add2)];        
%         figure, plot(1:KymoLineLengthMax, ProfToAdd, '-o', 'MarkerSize', 3);     
%% Adding of the border line positions        
            Kymograph(i_KymoLine, :) = ProfToAdd;     
            KymoEnd1 = [KymoEnd1; Add1];
            KymoEnd2 = [KymoEnd2; Add1 + ProfLenShort];        
%% Adding of the cell ends line positions  
            % Finding indexes of the two or three cell ends
            % ContShifted is [y,x]; CellCenter is [x,y]
            TrueCellNb = CellsTrack(i_cell, i_KymoLine);
            CurrCenter = AllGoodCells{i_KymoLine}(TrueCellNb, 5:6);  % Cell center at this time point
            [EndsInd] = f_3CellEnds(ContShifted, CurrCenter);     % Function receives shifted contour and cell center
            KymoCEs{i_KymoLine} = EndsInd;    % Each element of the cell array is one time point                                       
        end
%% Checking if the 'new' end is in the middle part of the kymo,
%% if not (if it is divided in two at the borders of the kymo),
%% then redo the kymo once again, but with different orientation of 
%% opening and centering points
        if (D2Cent > D2Open)       % Distance from old center to the opening point is smaller than to the centering point
            break       % for i_SideOfKymo = 1:2
        else
            tmp = HalfLine_Open;
            HalfLine_Open = HalfLine_Cent;
            HalfLine_Cent = tmp;                                    
        end         
    end
%% Visualise and save kymographs 
    close all; 
    % Cut the kymo so that it is cut at its borders
    Start = Add1 - 200;        % X coordinate of the beginning of the last line of the kymograph
    End = Add1 + ProfLenShort + 200;
    KymoForShow = Kymograph(:, Start:End);
    % Visualise
    h = figure;    
    imshow(KymoForShow, []);
    hold on;
    % Add ends of the kymo on the kymo
    i = 1:length(KymoEnd1);
    plot(KymoEnd1 - Start + 2, i, 'yo', 'MarkerSize', 1);   %'y-', 'LineWidth', 0.5);
    plot(KymoEnd2 - Start + 1, i, 'yo', 'MarkerSize', 1);   %'y-', 'LineWidth', 0.5);
    % Smooth cell ends positions
    x = 1:length(Added);
    p_SmSpline = 0.1;
    FitOptions = fitoptions('Method', 'SmoothingSpline', 'SmoothingParam', p_SmSpline);
    FitType = fittype('smoothingspline');
    cfun = fit(x', Added, FitType, FitOptions);
    AddedSmoo = cfun(x);
    % Add cell ends to the kymo
    for i_Line = 1:size(AllProfiles, 2) 
        plot(KymoCEs{i_Line} + Added(i_Line) - Start + 1, i_Line * ones(length(KymoCEs{i_Line}),1), 'bo', 'MarkerSize', 1);
    end
    % Save the figure and the .eps file    
    saveas(h, [Out_KymoFile int2str(i_cell) '.fig']);
        
    f_removeFigEdges;
    set(gcf, 'PaperPositionMode', 'auto');
    saveas(gcf, ['_Output/ImKymo_Cell' int2str(i_cell)], 'epsc'); 
    % Collecting the result for the current cell    
    AllKymos{i_cell, 1} = Kymograph;        
end
save(AllKymosFile, 'AllKymos');
    
    
    
    
    
    
    

