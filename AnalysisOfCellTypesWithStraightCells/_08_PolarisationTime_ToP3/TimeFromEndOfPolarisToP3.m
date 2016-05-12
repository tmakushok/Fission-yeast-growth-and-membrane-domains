clear
close all

load('BeginningOfP3_InTimePoints.mat');
load('_Output/AllMovies_PolarisTime_TimePtsFromMovieStart.mat');

%% Create a 'mask' matrix having 1s only where there are non-zero values in both
%% matrices
Mask = BeginningOfP3_TimePoints .* PolarisTime_TimePtsFromMovieStart;
Mask(Mask ~= 0) = 1;

BeginningOfP3_TimePoints = BeginningOfP3_TimePoints .* Mask;
PolarisTime_TimePtsFromMovieStart = PolarisTime_TimePtsFromMovieStart .* Mask;

Time_EndPol_P3 = BeginningOfP3_TimePoints - PolarisTime_TimePtsFromMovieStart;
% Transform into minutes
Time_EndPol_P3 = Time_EndPol_P3 * 3;
% Visualise
Show = Time_EndPol_P3(Time_EndPol_P3 ~= 0);
hist(Show, 15)
% Extract statistics
Mean = mean(Time_EndPol_P3(Time_EndPol_P3~=0))
Std = std(Time_EndPol_P3(Time_EndPol_P3~=0))