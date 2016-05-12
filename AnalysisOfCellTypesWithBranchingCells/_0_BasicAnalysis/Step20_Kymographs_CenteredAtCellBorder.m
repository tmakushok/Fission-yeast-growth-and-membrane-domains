%% Construction of the kymographs using cell aray 'AllProfiles'
%% !!! Need to check all kymographs to see if they are fine and delete from
%% 'AllKymos' all bad lines
%% This version of the program centeres the kymo around a point on cell
%% border corresponding to cell center (the point does not move in time)

clear;      % To erase variables that are in memory
close all;
%--------------------------------------------------------------------------
KymoLineLengthMax = 1300;

%!!!--!!! File paths
AllContFile = '_Output\AllContours.mat';
% AllProfFile = '_Output\AllProfiles.mat';
AllProfFile = '_Output\AllProfiles_Square3.mat';
AllEndsFile = '_Output\output_GoodCellsParams.mat';
KymosFile = '_Output/AllKymographs.mat';
Out_KymoFile = '_Output\KymoCenterOfCell_'; 
AllKymosFile = '_Output\AllKymosCenter.mat'; 
% AllWidthEndsFile = '_Output\AllCellWidthEnds.mat';
%--------------------------------------------------------------------------
load(AllContFile);
load(AllProfFile);
load(AllEndsFile);
OldKymos = load(KymosFile);
OldKymos = OldKymos.AllKymos;
% load(AllWidthEndsFile);
% AllProfiles = AllProfilesTipEnd1;
AllProfiles = AllProfilesSquare;
clear AllProfilesSquare;
AllKymos = cell(size(AllProfiles, 1), 1);
%% Assembling the kymograph
% Columns of AllProfilesTipEnd1 contain time points for one cell
for i_cell = 1:size(AllProfiles, 1)        % loop on the cells    
    i_cell
    close all
    Kymograph = zeros(size(AllProfiles, 2), KymoLineLengthMax);
    Center = AllGoodCells{1}(i_cell, 5:6);    % X and Y of cell center at the initial time point
    for i_KymoLine = 2:size(AllProfiles, 2)        % loop on the time points for one cell        
        if isempty(AllProfiles{i_cell, i_KymoLine})
            continue
        end
        if isempty(OldKymos{i_cell})        % If the kymograph for this cell is anyway considered bad
            AllKymos{i_cell, 1} = [];
            continue
        end
        ProfToAdd = AllProfiles{i_cell, i_KymoLine}(:, 3);
        s_OneProf = size(ProfToAdd);        
%         figure, plot(1:s_OneProf(1), ProfToAdd, '-o', 'MarkerSize', 3);          !
%% Find the position at cell border around which the kymo will be centered
        Cont = AllContours{i_cell, i_KymoLine};    % Y and X of the contour        
        [Sorted, ind] = sort(sqrt((Center(1) - Cont(:,2)) .^ 2 + (Center(2) - Cont(:,1)) .^ 2));
        Shift = - ind(1);        
%% Invert the profile_to_add to have one cell border position at the tips of the kymograph
        figure, plot(ProfToAdd, '-o');
        ProfToAdd = circshift(ProfToAdd, Shift);
        ContShifted = circshift(Cont, Shift);
        
        D = sqrt((Center(1) - ContShifted(:,2)) .^ 2 + (Center(2) - ContShifted(:,1)) .^ 2);
        [a, ToCenter] = min(D(30:length(D) - 30));
        ToCenter = ToCenter + 30;
%         figure, plot(ProfToAdd, '-o');        
%% Add black pixels at both sides of the lines
        Add1 = floor(KymoLineLengthMax/2) - ToCenter;     % smaller or equal
        Add2 = ceil(KymoLineLengthMax/2) - length(ProfToAdd) + ToCenter;      % bigger or equal
        ProfToAdd = [zeros(1, Add1), ProfToAdd', zeros(1, Add2)];        
%         figure, plot(1:KymoLineLengthMax, ProfToAdd, '-o', 'MarkerSize', 3);     
%% Adding of the line        
        Kymograph(i_KymoLine, :) = ProfToAdd;
    end
%% Visualise and save kymographs 
%     close all;
    h = figure; 
    imshow(Kymograph(:, floor(KymoLineLengthMax/3):KymoLineLengthMax - floor(KymoLineLengthMax/3)), []);  % Middle part of the kymograph for one cell
    saveas(h, [Out_KymoFile int2str(i_cell) '.fig']);
    AllKymos{i_cell, 1} = Kymograph;
end
save(AllKymosFile, 'AllKymos');




