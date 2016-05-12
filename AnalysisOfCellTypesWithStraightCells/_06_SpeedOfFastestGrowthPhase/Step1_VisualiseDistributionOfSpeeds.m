%% The task of the program is to plot the distribution of growth speeds
close all;
clear;
%% -----------
PhaseLenThres = 7;  % Minimal length of phase to be considered
%% -----------
load('Dynamics.mat');

Speeds = [];
Speeds_LongPhases = [];
MaxSpeeds = [];     % Max speed per cell end
MedSpeeds = [];
CellMaxSpeed = [];  % Max speed per cell
% !!! The results of the two cell ends are put together, as if the two cell
% !!! ends were independent
for i_cell = 1:length(Dynamics)     % Loop on the cells
    % If there is no info for this cell
    if isempty(Dynamics{i_cell})
        continue
    end
    MaxSpeedEnds = [];
    for i_end = 1:length(Dynamics{i_cell})        
        if isempty(Dynamics{i_cell}{i_end}) % If there is no info for this cell end
            continue
        end
        D = Dynamics{i_cell}{i_end};
        % 
        Speeds = [Speeds; D(:,3), i_cell * ones(size(D(:,3))), i_end * ones(size(D(:,3)))];   % 'ones' is needed because there are multiple entries for each cell ends
        MaxSpeeds = [MaxSpeeds; max(D(:,3))];
        MedSpeeds = [MedSpeeds; median(D(:,3))];
        [Val, Pos] = max(D(:,3));
        MaxSpeedEnds = [MaxSpeedEnds; Val, D(Pos,2) - D(Pos,1)]; % Save the value of the speed and the length of the corresponding phase
        %% Distribution of speeds for phases longer than threshold
        for i_ph = 1:size(D,1)
            if D(i_ph, 2) - D(i_ph, 1) >= PhaseLenThres
                Speeds_LongPhases = [Speeds_LongPhases; D(i_ph,3), i_cell, i_end, i_ph];
            end
        end
    end    
    [Val, Pos] = max(MaxSpeedEnds(:,1));
    CellMaxSpeed = [CellMaxSpeed; MaxSpeedEnds(Pos, :), i_cell];
end
%% Conversion from pixels into microns
Speeds(:,1) = Speeds(:,1) * 0.0707; 
Speeds_LongPhases(:,1) = Speeds_LongPhases(:,1) * 0.0707; 
%% Conversion from speed per 3 minutes into speed per hour
Speeds(:,1) = Speeds(:,1) * 20; 
Speeds_LongPhases(:,1) = Speeds_LongPhases(:,1) * 20; 
%% Find the maximal growth speed
[Sp, Pos] = max(Speeds_LongPhases(:,1));

%% Number of cells considered when finding the maximal speed 
NbCells = length(unique(Speeds_LongPhases(:,2)))
