%% 'Peak' contains:
%% 1) position of the peak in profile's coords
%% 2) width of the peak at half-height
function [Peak] = f_Peak_CellEnd_ForWidthSpeedCorrelation(Y, CEndPos)   % CEndPos is the position of the current cell end in coordinates of the intensity profile
%--------------------------
p_Spline = 0.01;
% PtsLinFit = 5;      % Nb of point for linear fits going along the profile
ThresPeak = 16;     % Smaller intensities are to be considered as non-important noisy values
% ThresDiff = 15;     % To be considered as non-important values of difference matrix
% ToLookForMax = 5;   % Nb of pts to left and to right from found maximum to find the complete maximum
% Max distance between cell end and patch center for the patch to be
% considered to be at the cell end
CellEndThres = 50;  
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
% Take the max closest to the cell end of interest
[a, ind] = min(abs(Ind - CEndPos));
MaxPos = Ind(ind) + 1;  
%% Width of the peak at the intensity threshold level
% Going in Ox direction from peak max until finding the first 
% zero value of the thresholded smoothed profile
ind1 = find(Profile(MaxPos:length(Y)) == 0);
if ~isempty(ind1)
    ind1 = ind1(1) - 1;         % '-1' because at ind1(1) it is already under- threshold value
else  % In case ind1 are not found 
    MaxPos;
    % There is no patch at the cell end or the patch is weird
    Peak.Width = -1; 
    Peak.PositionOfPeakCenter = -1; 
    Peak.DistFromCEnd = -1; 
    Peak.MaxIntens = -1; 
    return
end
% Going in -Ox direction from peak max until finding first negative value
ind2 = find(Profile(MaxPos:-1:1) == 0);
if ~isempty(ind2)
    ind2 = ind2(1) - 1;         % '-1' because at ind1(1) it is already under- threshold value
else        % In case ind2 are not found 
    MaxPos;
    % There is no patch at the cell end or the patch is weird
    Peak.Width = -1; 
    Peak.PositionOfPeakCenter = -1; 
    Peak.DistFromCEnd = -1; 
    Peak.MaxIntens = -1; 
    return
end
% Translating distance to the peak maximum into coordinates along the profile
RInd1 = MaxPos + ind1 - 1;
RInd2 = MaxPos - ind2 + 1;
% Visualisation
% figure(h), hold on, plot(RInd1, Profile(RInd1), 'k*');
% figure(h), hold on, plot(RInd2, Profile(RInd2), 'k*');
%% Correction to the patch width: using values from non-splined data
Corr = Y;
Corr(Corr < ThresPeak) = 0;
NonZero = find(Corr);     % Location of non-zero values
[a, a1] = min(abs(NonZero - RInd1));
[a, a2] = min(abs(NonZero - RInd2));
RInd2 = NonZero(a1);
RInd1 = NonZero(a2);
% Visualisation
% hold on, plot(RInd1, Y(RInd1), 'g*', 'MarkerSize', 7);
% hold on, plot(RInd2, Y(RInd2), 'g*', 'MarkerSize', 7);
% '-1' because 'MaxPos' was counted twice
Peak.Width = RInd2 - RInd1;    % Peak width at the threshold level 
% Peak center position in coords of the outline
% Calculated as the middle between the two points of peak width 
Peak.PositionOfPeakCenter = (RInd1 + RInd2) / 2;     
Peak.DistFromCEnd = abs(Peak.PositionOfPeakCenter - CEndPos);
Peak.MaxIntens = max(Y(RInd1:RInd2));   % Maximum intensity of the peak
%% Threshold on the distance from the cell end to the position 
%% of the center of the patch: if too far, it is not at cell end anymore
if Peak.DistFromCEnd > CellEndThres
    Width = Peak.Width;
    PositionOfPeakCenter = Peak.PositionOfPeakCenter;
    DistFromCEnd = Peak.DistFromCEnd;
    MaxIntens = Peak.MaxIntens;
    RInd1;
    RInd2;
    % There is no patch at the cell end
    Peak.Width = 0; 
    Peak.PositionOfPeakCenter = -1; 
    Peak.DistFromCEnd = -1; 
    Peak.MaxIntens = -1; 
    
    Width = Peak.Width;
    PositionOfPeakCenter = Peak.PositionOfPeakCenter;
    DistFromCEnd = Peak.DistFromCEnd;
    MaxIntens = Peak.MaxIntens;
    RInd1;
    RInd2;
    return
end
Width = Peak.Width;
PositionOfPeakCenter = Peak.PositionOfPeakCenter;
DistFromCEnd = Peak.DistFromCEnd;
MaxIntens = Peak.MaxIntens;
Peak.MaxIntens;
RInd1;
RInd2;
