%% The task of the program is measure width of SRM patch at slowly growing
%% cell end over time (only for cells growing quickly at one end 
%% and slowly at the other end)
close all;
clear;
%--------------------------------------------------------------------------
OutFile = '_Output/_SmallPeaksPos_FirstTimePt.mat';
%--------------------------------------------------------------------------
load('_Output/AllKymographs.mat');     % Loads the matrix with kymographs
% load('_Output/AllEnds_TimesStartGrowth.mat');    % Loads times of end of plateau, start of growth and start of quick growth
% load('_Output/AllCellEnds.mat');        % Coordinates of cell ends over time         
load('_Output/AllContours.mat');        % Coordinates along all contours in time

PeaksPosAndWidths = cell(length(AllKymos), 1);
for i_cell = 1:length(AllKymos)       % Loop on cells
%     close all;
    Kymo = AllKymos{i_cell};
%     figure, imshow(Kymo, []);
    % If the kymograph for this cell does not exist
    if isempty(Kymo)
        continue
    end
    Kymo_t = Kymo(1, :);        % One line of the kymo corresponding to the time point analysed
    % Taking off zeros at both sides of the actual intensity profile
    Kymo_t = Kymo_t(find(Kymo_t))';
%     figure, plot(Kymo_t, '-*'), grid on;    
    %% Finding positions and widths of all small peaks detectable at the first time point 
    MaxInd = f_SmallDomains(Kymo_t); % First col- peak width, second- peak position    
    
%     hold on, plot(MaxInd, 100*ones(size(MaxInd)), 'r*'), grid on;
%     figure, plot(MaxInd, 'r*'), grid on;  
%     figure, imshow(Kymo_t', []);
%     hold on, plot(MaxInd, ones(size(MaxInd)), 'r*');
%     figure, imshow(Kymo, []);
%     InitInd = find(Kymo(1, :));
%     hold on, plot(MaxInd + InitInd(1), ones(size(MaxInd)), 'r*');  %  "+ InitInd(1)"- to compensate for the black space around the kymo 
    %% Current edges of the kymo line are already at a cell end, so direct normalization to the outline length is possible
    KymoLen = length(Kymo_t);    
    PosEnd2 = round(KymoLen / 2);   % The second cell end is located at the middle of the profile
    PosNorm = MaxInd;
    for i_Ind = 1:length(MaxInd)
        if (MaxInd(i_Ind) >= round(KymoLen/4)) && (MaxInd(i_Ind) <= PosEnd2)
            PosNorm(i_Ind) = PosEnd2 - PosNorm(i_Ind);
        end
        if (MaxInd(i_Ind) > PosEnd2) && (MaxInd(i_Ind) <= round(KymoLen*3/4))
            PosNorm(i_Ind) = PosNorm(i_Ind) - PosEnd2;
        end
        if (MaxInd(i_Ind) > round(KymoLen*3/4)) && (MaxInd(i_Ind) <= KymoLen)
            PosNorm(i_Ind) = KymoLen - PosNorm(i_Ind);
        end  
    end    
%     figure, plot(PosNorm, 'r*'); 
    PosNorm = PosNorm / (round(KymoLen / 4));      % So that PosNorm = 0 at ane of the cell ends and =1 at the cell middle
%     figure, plot(PosNorm, 'r*');    
%     ylim([0 1]), grid on;  
    PeaksPos{i_cell,1} = PosNorm;  
end
%% Output the result        
save(OutFile, 'PeaksPos');




