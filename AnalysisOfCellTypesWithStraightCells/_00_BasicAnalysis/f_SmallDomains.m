%% 'Peak' contains:
%% 1) position of the peak in profile's coords
%% 2) width of the peak at half-height
function [Ind] = f_SmallDomains(Y)   
%--------------------------
p_Spline = 0.01;
% PtsLinFit = 5;      % Nb of point for linear fits going along the profile
ThresPeak = 20;     % Smaller intensities are to be considered as non-important noisy values
%--------------------------
[a, b, Y] = find(Y);
%% Smoothing of the curve using running average of size 3
% figure, plot(Y, '-ro', 'MarkerSize', 3), grid on; 
Y = filter(ones(1,3)/3, 1, Y);
% figure, plot(Y, '-ro', 'MarkerSize', 3), grid on; 
%% Taking off background value (background here: minimal intensity value of the profile)
%% from the intensity profile
% figure, plot(Y, '-ro', 'MarkerSize', 3), grid on;
Y = Y - min(Y(2:length(Y)-1));      % Min is found for the profile without first and last point, because they were not smoothed
% h = figure, plot(Y, '-o', 'MarkerSize', 2), grid on;
% Y(find(Y <= ThresPeak)) = 0;
% h = figure, plot(Y, '-ro', 'MarkerSize', 3), grid on; 
%% Getting the overall peaks picture with smoothing spline
FitOptions = fitoptions('Method', 'SmoothingSpline', 'SmoothingParam', p_Spline);
FitType = fittype('smoothingspline');
X = (1:length(Y))';
cfun = fit(X, Y, FitType, FitOptions);
Profile = cfun(X);
% Get rid of small values in the smoothed version
Profile(Profile < ThresPeak) = 0;
% figure(h), hold on, plot(X, Profile, 'r-');
%% Position of the maximum corresponding to the patch (at the smoothed curve)
% Difference matrix
Signs = sign(Profile(2:length(Profile)) - Profile(1:length(Profile) - 1));
% figure, plot(Signs, '-o');
% Find maxima
Signs(Signs < 0) = -12;
Ind = find(Signs(1:length(Signs) - 1) - Signs(2:length(Signs)) == 13);
