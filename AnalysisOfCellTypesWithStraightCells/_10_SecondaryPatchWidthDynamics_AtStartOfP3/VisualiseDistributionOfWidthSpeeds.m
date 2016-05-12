%% The task of the program is to plot the distribution 
close all;
% clear;

% load('_Dynamics_All4Movies.mat');

Speeds = [];
MaxSpeeds = [];
MedSpeeds = [];
MinSpeeds = [];

% !!! The results of the two cell ends are put together, as if the two cell
% !!! ends were independent
for i_cell = 1:length(Dynamics)     % Loop on the cells
    % If there is no info for this cell
    if isempty(Dynamics{i_cell})
        continue
    end            
       
    D = Dynamics{i_cell};
    
    Speeds = [Speeds; D(:,3)];
    MaxSpeeds = [MaxSpeeds; max(D(:,3))];
    MinSpeeds = [MinSpeeds; min(D(:,3))];
    MedSpeeds = [MedSpeeds; median(D(:,3))];
end
% %% Take off NaN values
% Speeds(isnan(Speeds)) = [];
% MedSpeeds(isnan(MedSpeeds)) = [];
% %% Take off negative values
% Speeds(Speeds < 0) = [];
% MaxSpeeds(MaxSpeeds < 0) = [];
% MedSpeeds(MedSpeeds < 0) = [];
%% Conversion from pixels into microns
Speeds = Speeds * 0.0707; 
MaxSpeeds = MaxSpeeds * 0.0707; 
MedSpeeds = MedSpeeds * 0.0707; 
MinSpeeds = MinSpeeds * 0.0707; 
%% Conversion from speed per 3 minutes into speed per hour
Speeds = Speeds * 20; 
MaxSpeeds = MaxSpeeds * 20; 
MedSpeeds = MedSpeeds * 20;
MinSpeeds = MinSpeeds * 20;
%% Visualisation
figure,
hist(Speeds, 100);
xlabel('Speed of secondary patch widening, in microns per hour');
ylabel('N');
title('Wild type');

figure,
hist(MaxSpeeds, 50);
xlabel('Max speed of secondary patch widening, in microns per hour');
ylabel('N');
title('Wild type');

figure,
hist(MedSpeeds, 50);
xlabel('Median speed of secondary patch widening, in microns per hour');
ylabel('N');
title('Wild type');

figure,
hist(MinSpeeds, 50);
xlabel('Min speed of secondary patch widening, in microns per hour');
ylabel('N');
title('Wild type');