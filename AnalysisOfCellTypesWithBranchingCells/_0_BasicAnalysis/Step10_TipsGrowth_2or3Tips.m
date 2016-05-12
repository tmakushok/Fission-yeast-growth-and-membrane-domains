%% The task of the program is to detect all cell ends and distances from
%% cell ends to initial cell center
clear;      % To erase variables that are in memory
close all;
%--------------------------------------------------------------------------
KymoLineLengthMax = 1300;
% Length of the half-line which intersection with cell outline defines
% opening and centering points for each line of the kymograph
HalfLineL = 150;    % This length has to take into account the length of the new end (T-shape)
% Distance between two cell ends when the two are considered as being one
DistOneEnd = 45;
%!!!--!!! File paths
AllContFile = '_Output/AllContours.mat';
AllProfFile = '_Output/AllProfiles_Square3.mat';
AllEndsFile = '_Output/output_GoodCellsParams.mat';
KymosFile = '_Output/AllKymographs.mat';
TracksFile = '_Output/output_CellsTracks.mat';
Out_TipsLenFile = '_Output/AllTipsLengths.mat';
CellEndsFile = '_Output/AllCellEnds_2orMoreOfThem.mat';
%--------------------------------------------------------------------------
load(AllContFile);
load(AllProfFile);
load(AllEndsFile);
load(TracksFile);
Kymos = load(KymosFile);
Kymos = Kymos.AllKymos;
AllProfiles = AllProfilesSquare;
clear AllProfilesSquare;

for i_cell = 1:size(AllProfiles, 1)        % Loop on all cells    
    i_cell
%     close all
    if isempty(Kymos{i_cell})        % If the kymograph for this cell is anyway considered bad        
        TipsLen{i_cell, 1} = [];
        CellEnds{i_cell, 1} = [];
        continue
    end   
    Center = AllGoodCells{1,1}(i_cell, 5:6);  
    for i_t = 1:size(AllProfiles, 2)
        close all;        
        Cont = AllContours{i_cell, i_t};    % Y and X of the contour
        if isempty(Cont)        % Contour was not detected for this cell at this moment
            continue
        end
        % Invert positions of the columns
        Cont(:,3) = Cont(:,1);
        Cont(:,1) = Cont(:,2);
        Cont(:,2) = Cont(:,3);
        Cont(:,3) = [];         % X and Y of the contour
%% Finding cell ends positions  
        % Finding indexes of the two or three cell ends        
        TrueCellNb = CellsTrack(i_cell, i_t);
        if TrueCellNb == 0
            TipsLen{i_cell, 1}{i_t, 1} = [];
            CellEnds{i_cell, 1}{i_t, 1} = [];
            continue
        end
%         CurrCenter = AllGoodCells{i_t}(TrueCellNb, 5:6);  % Cell center at this time point, (x, y)
        [EndsInd] = f_3CellEnds(Cont, Center);     % Function receives shifted contour and cell center
        if length(EndsInd) < 2          % If less than two cell ends are detected
            TipsLen{i_cell, 1}{i_t, 1} = [];
            CellEnds{i_cell, 1}{i_t, 1} = [];
            continue
        end              
        Ends = Cont(EndsInd, :);        % (x,y)
%% Checking if two cell ends are not too close (in case there is more than two cell ends)
%% because if they are close, then they are probably one end
        EndsToTakeOff = [];
        EndsToAdd = [];
        if length(Ends) > 2         
            for i_end1 = 1:length(Ends) - 1
                for i_end2 = i_end1 + 1:length(Ends)
                    Dist = sqrt((Ends(i_end1, 1) - Ends(i_end2, 1)) .^ 2 + (Ends(i_end1, 2) - Ends(i_end2, 2)) .^ 2);
                    if Dist < DistOneEnd
                        % Find the point at the middle between the two
                        % suspicious points
                        RealEnd = [round((Ends(i_end1, 1) + Ends(i_end2, 1)) / 2), round((Ends(i_end1, 2) + Ends(i_end2, 2)) / 2)];
                        % Find the point on the contour corresponding to
                        % this middle point
                        DCont = sqrt((RealEnd(1) - Cont(:,1)) .^ 2 + (RealEnd(2) - Cont(:,2)) .^ 2);
                        [a, ind] = min(DCont);
                        RealEnd = Cont(ind, :);
                        EndsToTakeOff = [EndsToTakeOff; i_end1; i_end2];
                        EndsToAdd = [EndsToAdd; RealEnd];
                    end
                end
            end
            % Replacing the double ends with the right ones
            EndsToTakeOff = sort(unique(EndsToTakeOff), 'descend');
            for i = 1:length(EndsToTakeOff)
                Ends(EndsToTakeOff(i), :) = []; 
            end
            for i = 1:size(EndsToAdd, 1)
                Ends = [Ends; EndsToAdd(i, :)];
            end            
        end 
%% Measuring distances from the initial cell center to each of the cell ends detected  
        D = zeros(size(Ends, 1), 1);
        for i_end = 1:size(Ends, 1)     % Loop on all cell ends detected (should be 2 or 3)
            % Distances between initial cell center and each of the tips
            D(i_end) = sqrt((Ends(i_end, 1) - Center(1)) .^ 2 + (Ends(i_end, 2) - Center(2)) .^ 2);                    
        end
        TipsLen{i_cell, 1}{i_t, 1} = D;
        CellEnds{i_cell, 1}{i_t, 1} = Ends;
    end
end
%% Output the result        
save(Out_TipsLenFile, 'TipsLen');  
save(CellEndsFile, 'CellEnds');







