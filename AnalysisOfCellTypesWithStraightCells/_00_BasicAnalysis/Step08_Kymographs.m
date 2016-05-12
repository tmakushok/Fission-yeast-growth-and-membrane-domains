%% Construction of the kymographs using cell aray 'AllProfiles'
%% !!! Need to check all kymographs to see if they are fine and delete from
%% 'AllKymos' all bad lines
% Do it from two initial points: two cell ends
% OR: 
% ????????????? Cell ends and cell width ends
% Make the 'cut' point in the middle of the kymograph

clear;      % To erase variables that are in memory
close all;
%--------------------------------------------------------------------------
KymoLineLengthMax = 1300;

%!!!--!!! File paths
AllContFile = '_Output/AllContours.mat';
% AllProfFile = '_Output\AllProfiles.mat';
AllProfFile = '_Output/AllProfiles_Square3.mat';
AllEndsFile = '_Output/AllCellEnds.mat';
Out_KymoFile = '_Output/KymographCell_'; 
AllKymosFile = '_Output/AllKymographs.mat'; 
% AllWidthEndsFile = '_Output\AllCellWidthEnds.mat';
%--------------------------------------------------------------------------
load(AllContFile);
load(AllProfFile);
load(AllEndsFile);
% load(AllWidthEndsFile);
% AllProfiles = AllProfilesTipEnd1;
AllProfiles = AllProfilesSquare;
clear AllProfilesSquare;
AllKymos = cell(size(AllProfiles, 1), 1);
%% Assembling the kymograph
% Columns of AllProfilesTipEnd1 contain time points for one cell
for i_cell = 1:size(AllProfiles, 1)        % loop on the cells    
    Kymograph = zeros(size(AllProfiles, 2), KymoLineLengthMax);
    for i_KymoLine = 1:size(AllProfiles, 2)        % loop on the time points for one cell        
        if isempty(AllProfiles{i_cell, i_KymoLine})
            continue
        end
        ProfToAdd = AllProfiles{i_cell, i_KymoLine}(:, 3);
        s_OneProf = size(ProfToAdd);        
%         figure, plot(1:s_OneProf(1), ProfToAdd, '-o', 'MarkerSize', 3);          
%% Invert the profile_to_add to have cell tip position in the middle
        % of the kymograph
        Shift = floor(s_OneProf(1) / 2); % Because of this step we introduce 1 pixel error
        ProfToAdd = circshift(ProfToAdd, Shift);
%% Add black pixels at both sides of the lines
        Add1 = floor((KymoLineLengthMax - s_OneProf(1))/2);     % smaller or equal
        Add2 = ceil((KymoLineLengthMax - s_OneProf(1))/2);      % bigger or equal
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




