%% The task of the program is to extract average patch width for each of
%% the phases of cell growth to see if there is a correlation between speed
%% of cell end growth and the width of the corresponding patch
clear;
close all;
%%
WidthThres = 5;
TimeThres = 6; % In fact, this is a threshold on number of points of patch width during the phase
%%
load('_Input/_AveragePatchWidth_PhaseGrowthSpeed_AllMoviesCombined.mat');

% Widths = WidthsAver_Speed(:,1);  % Average of domain width over individual growth phases
Widths = WidthsAver_Speed(:,2);  % Median of domain width over individual growth phases
Speeds = WidthsAver_Speed(:,3);
% Slopes = WidthsAver_Speed(:,6);
%% Take off NaN values of speed and domain widths smaller than 5px 
for i = length(Speeds):-1:1
   if (isnan(Speeds(i))) || (Widths(i) < WidthThres)
       Speeds(i) = [];
       Widths(i) = [];
%        Slopes(i) = [];
   end
end
%% Transform to microns
Widths = Widths * 0.0707; 
Speeds = Speeds * 0.0707; 
% Slopes = Slopes * 0.0707; 
% Conversion from speed per 3 minutes into speed per hour
Speeds = Speeds * 20; 
% Slopes = Slopes * 20;
%% Visualise
figure, plot(Widths, Speeds, 'k.', 'MarkerSize', 5);
xlabel('Median domain width over phase of growth, in microns');
ylabel('Speed of phase of growth, in microns per hour');
%% ------------------------------------------------------------------------
%% Keep only phases of growth that are long enough
for i = size(WidthsAver_Speed, 1):-1:1
    if WidthsAver_Speed(i, 4) < TimeThres
        WidthsAver_Speed(i, :) = [];
    end
end

Widths = WidthsAver_Speed(:,2); % Median
Speeds = WidthsAver_Speed(:,3);
% Slopes = WidthsAver_Speed(:,6);
%% Take off NaN values of speed and domain widths smaller than 5px 
for i = length(Speeds):-1:1
   if (isnan(Speeds(i))) || (Widths(i) < WidthThres)
       Speeds(i) = [];
       Widths(i) = [];
%        Slopes(i) = [];
   end
end
%% Transform to microns
Widths = Widths * 0.0707; 
Speeds = Speeds * 0.0707; 
% Slopes = Slopes * 0.0707; 
% Conversion from speed per 3 minutes into speed per hour
Speeds = Speeds * 20; 
% Slopes = Slopes * 20;
%% Visualise
figure, plot(Widths, Speeds, 'k.', 'MarkerSize', 5);
xlabel('Median domain width');
ylabel('Speed of growth');
% xlim([0 12]);
% ylim([-1 3.5]);

% figure, plot(Speeds, Slopes, 'k.', 'MarkerSize', 2);
% ylabel('Patch growth rate, in microns per hour');
% xlabel('Speed of cell end growth phase, in microns per hour');
% xlim([-1 4]);
% ylim([-40 40]);

%% Dividing data points into slow and fast growth
SlowNb = find(Speeds < 0.8);
SpeedsSlow = Speeds(SlowNb);
WidthsSlow = Widths(SlowNb);

FastNb = find(Speeds >= 0.8);
SpeedsFast = Speeds(FastNb);
WidthsFast = Widths(FastNb);

% %% Cleaning up the data: chop off the outliers
% KeepNb = find(WidthsSlow < 7);
% SpeedsSlow = SpeedsSlow(KeepNb);
% WidthsSlow = WidthsSlow(KeepNb);
% 
% KeepNb = find((WidthsFast > 5.5) .* (WidthsFast < 7));
% SpeedsFast = SpeedsFast(KeepNb);
% WidthsFast = WidthsFast(KeepNb);
%% Correlation between patch width and speed of growth for slow growth phases
[R_Slow, P_Slow, RLO_Slow, RUP_Slow] = corrcoef(WidthsSlow, SpeedsSlow)
p_Slow = polyfit(WidthsSlow, SpeedsSlow, 1)
Fit = polyval(p_Slow, WidthsSlow); 

% Visualise
figure, plot(WidthsSlow, SpeedsSlow, 'k.', 'MarkerSize', 2);
xlabel('Average patch width over phase of growth, in microns');
ylabel('Speed of phase of growth, in microns per hour');
hold on, plot(WidthsSlow, Fit)

%% Correlation between patch width and speed of growth for fast growth phases
[R_Fast, P_Fast, RLO_Fast, RUP_Fast] = corrcoef(WidthsFast, SpeedsFast)
p_Fast = polyfit(WidthsFast, SpeedsFast, 1)
Fit = polyval(p_Fast, WidthsFast); 

% Visualise
figure, plot(Widths, Speeds, 'k.', 'MarkerSize', 2);
xlabel('Average patch width over phase of growth, in microns');
ylabel('Speed of phase of growth, in microns per hour');
hold on, plot(WidthsFast, Fit)




