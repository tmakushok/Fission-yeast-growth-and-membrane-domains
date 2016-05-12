%% The task of the program is measure width of SRM patch at slowly growing
%% cell end over time (only for cells growing quickly at one end 
%% and slowly at the other end)
close all;
clear;
%--------------------------------------------------------------------------
OutFile = '_Output/_AllPatchesOverTime.mat';
%--------------------------------------------------------------------------
load('_Output/AllKymographs.mat');     % Loads the matrix with kymographs
load('_Output/AllEnds_GrowthDynamics.mat');    
load('_Output/AllCellEnds.mat');        % Coordinates of cell ends over time         
load('_Output/AllContours.mat');        % Coordinates along all contours in time

for i_cell = 49:length(AllKymos)       % Loop on cells
    i_cell
%     close all;
    Peaks = [];
    Kymo = AllKymos{i_cell};
    % If the kymograph for this cell is anyway considered bad
    if isempty(Kymo)             
        continue
    end    
    for i_t = 1:size(AllContours, 2)   % Loop on time
        close all;
        Kymo_t = Kymo(i_t, :);        % One line of the kymo corresponding to the time point analysed
        % Taking off zeros at both sides of the actual intensity
        % profile
        Kymo_t = Kymo_t(find(Kymo_t))';        
%        figure, plot(Kymo_t, '-*'), grid on;                    
        if isempty(Kymo_t)    % If this line of the kymo is absent
            continue
        end
        %% Finding parameters of all peaks at that time
        Peaks{i_t,1} = f_Peaks(Kymo_t);             
%         pause(0.1);
    end 
    % Combining data from all cells
    PeaksAll{i_cell,1} = Peaks;
end    
%% Output the result        
save(OutFile, 'PeaksAll');




