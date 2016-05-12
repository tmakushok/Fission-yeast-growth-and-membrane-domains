%% The task of the program is to plot the distribution of growth speeds
close all;
% clear;
%% -----------
PhaseLenThres = 10;  % Minimal length of phase to be considered
PhLenThresMax = 5;  % Minimal length of phase for cell max growth speed
%% -----------
load('Dynamics.mat');
load('DivisionTimes.mat');

CellMaxSpeed = [];  % Max speed per cell
MaxSpeeds_LongPhases = [];
MaxSp_LongPh_Div = [];
MaxSpeeds_CellEnd = [];

for i_cell = 1:length(Dynamics)     % Loop on the cells
    % If there is no info for this cell
    if isempty(Dynamics{i_cell})
        continue
    end
    MaxSpeedEnds = [];
    MaxLong = 0;
    MaxLongD = 0;
    for i_end = 1:length(Dynamics{i_cell})        
        if isempty(Dynamics{i_cell}{i_end}) % If there is no info for this cell end
            continue
        end
        D = Dynamics{i_cell}{i_end};
        
        MaxSpeeds_CellEnd = [MaxSpeeds_CellEnd; max(D(:,3))]; % Maximal growth speed for the current cell end
        [Val, Pos] = max(D(:,3));
        MaxSpeedEnds = [MaxSpeedEnds; Val, D(Pos,2) - D(Pos,1)]; % Save the value of the speed and the length of the corresponding phase        
        %% Distribution of max growth speeds for phases longer than threshold   
        for i_ph = 1:size(D,1)
            if D(i_ph, 2) - D(i_ph, 1) > PhLenThresMax                
            	MaxLong = max(MaxLong, D(i_ph,3));
            end
        end               
%         %% Distribution of max growth speeds for phases longer than threshold
%         %% for the cells followed till cell division       
%         if DivisionTimes(i_cell, 1) > 0
%             for i_ph = 1:size(D,1)
%                 if D(i_ph, 2) - D(i_ph, 1) > PhLenThresMax                
%                     MaxLongD = max(MaxLongD, D(i_ph,3));
%                 end
%             end                   
%         end
    end   
    MaxSpeeds_LongPhases = [MaxSpeeds_LongPhases; MaxLong];
%     MaxSp_LongPh_Div = [MaxSp_LongPh_Div; MaxLongD];
    
    [Val, Pos] = max(MaxSpeedEnds(:,1));
    CellMaxSpeed = [CellMaxSpeed; MaxSpeedEnds(Pos, :), i_cell];
end
%% Conversion from pixels into microns
Speeds = Speeds * 0.0707; 
Speeds_LongPhases = Speeds_LongPhases * 0.0707; 
MaxSpeeds = MaxSpeeds * 0.0707; 
CellMaxSpeed(:,1) = CellMaxSpeed(:,1) * 0.0707;

MaxSpeeds_LongPhases = MaxSpeeds_LongPhases * 0.0707;
% MaxSp_LongPh_Div = MaxSp_LongPh_Div * 0.0707;
%% Conversion from speed per 3 minutes into speed per hour
Speeds = Speeds * 20; 
Speeds_LongPhases = Speeds_LongPhases * 20; 
MaxSpeeds = MaxSpeeds * 20; 
CellMaxSpeed(:,1) = CellMaxSpeed(:,1) * 20;

MaxSpeeds_LongPhases = MaxSpeeds_LongPhases * 20;
% MaxSp_LongPh_Div = MaxSp_LongPh_Div * 20;
%% Visualisation
figure,
hist(MaxSpeeds_LongPhases, 20);

% figure,
% hist(MaxSp_LongPh_Div, 20);