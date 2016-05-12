%% The task of the program is to plot the distribution of growth speeds
close all;
clear;
%% -----------
PhaseLenThres = 10;  % Minimal length of phase to be considered
%% -----------
load('Dynamics.mat');

Speeds = [];
Speeds_LongPhases = [];
MaxSpeeds = [];
MedSpeeds = [];
CellMaxSpeed = [];
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
        Speeds = [Speeds; D(:,3)];
        MaxSpeeds = [MaxSpeeds; max(D(:,3))];
        MedSpeeds = [MedSpeeds; median(D(:,3))];
        [Val, Pos] = max(D(:,3));
        MaxSpeedEnds = [MaxSpeedEnds; Val, D(Pos,2) - D(Pos,1)]; % Save the value of the speed and the length of the corresponding phase
        %% Distribution of speeds for phases longer than threshold
        for i_ph = 1:size(D,1)
            if D(i_ph, 2) - D(i_ph, 1) > PhaseLenThres
                Speeds_LongPhases = [Speeds_LongPhases; D(i_ph,3)];
            end
        end
    end 
    [Val, Pos] = max(MaxSpeedEnds(:,1));
    CellMaxSpeed = [CellMaxSpeed; MaxSpeedEnds(Pos, :), i_cell];
end
%% Take off NaN values
Speeds(isnan(Speeds)) = [];
Speeds_LongPhases(isnan(Speeds_LongPhases)) = [];
MedSpeeds(isnan(MedSpeeds)) = [];
%% Take off negative values
% Speeds(Speeds < 0) = [];
% MaxSpeeds(MaxSpeeds < 0) = [];
% MedSpeeds(MedSpeeds < 0) = [];
%% Conversion from pixels into microns
Speeds = Speeds * 0.0707; 
Speeds_LongPhases = Speeds_LongPhases * 0.0707; 
MaxSpeeds = MaxSpeeds * 0.0707; 
MedSpeeds = MedSpeeds * 0.0707; 
CellMaxSpeed(:,1) = CellMaxSpeed(:,1) * 0.0707;
%% Conversion from speed per 3 minutes into speed per hour
Speeds = Speeds * 20; 
Speeds_LongPhases = Speeds_LongPhases * 20; 
MaxSpeeds = MaxSpeeds * 20; 
MedSpeeds = MedSpeeds * 20;
CellMaxSpeed(:,1) = CellMaxSpeed(:,1) *20;
%% Visualisation
figure,
hist(Speeds, 100);
xlabel('Speed of cell end growth, in microns per hour');
ylabel('N');
title('Wild type');

figure,
hist(Speeds_LongPhases, 100);
xlabel('Speed of cell end growth for long phases, in microns per hour');
ylabel('N');
title('Wild type');

figure,
hist(MaxSpeeds, 30);
xlabel('Max speed of cell end growth, in microns per hour');
ylabel('N');
title('Wild type');

