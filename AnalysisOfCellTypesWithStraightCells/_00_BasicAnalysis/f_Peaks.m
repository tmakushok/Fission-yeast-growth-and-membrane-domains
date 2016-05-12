%% 'Peak' contains:
%% 1) position of the peak in profile's coords
%% 2) width of the peak at half-height
function [Peaks] = f_Peaks(Y)
%--------------------------
p_Spline = 0.01;
PtsLinFit = 5;      % Nb of point for linear fits going along the profile
ThresPeak = 30;     % To be considered as non-important values (to get rid of too small peaks)
ThresDiff = 1;     % To be considered as non-important values of difference matrix
ToLookForMax = 5;   % Nb of pts to left and to right from found maximum to find the complete maximum
%--------------------------
[a, b, Y] = find(Y);
Peaks = [];
%% Taking off background value from the intensity profile and get rid of negative values
Y = Y - f_ProfileBkGd(Y);
Y(find(Y <= ThresPeak)) = 0;
h = figure, plot(Y, '-o', 'MarkerSize', 2), grid on;
% h = figure, plot(Y, '-ro', 'MarkerSize', 3), grid on; 
%% Take off one pixel holes (zeros after threshold) in the patches
Zer = find(Y == 0);
ZerosToTakeOff = [];
% Check if the first point was a single zero
if (Zer(2) ~= Zer(1) + 1)
    ZerosToTakeOff = [ZerosToTakeOff; Zer(1)];
end
% Check if the second point was a single zero
if (Zer(1) ~= Zer(2)-1) && (Zer(3) ~= Zer(2)+1)
    ZerosToTakeOff = [ZerosToTakeOff; Zer(2)];
end
% Middle points
for i = 3:length(Zer)-1
    % For one zero point 
    if (Zer(i-1) ~= Zer(i)-1) && (Zer(i+1) ~= Zer(i)+1) 
        ZerosToTakeOff = [ZerosToTakeOff; Zer(i)];
    end
    % If there are two zeros next to each other surrounded by other values
    if (Zer(i-2) ~= Zer(i)-2) && (Zer(i-1) == Zer(i)-1) && (Zer(i+1) ~= Zer(i)+1) 
        ZerosToTakeOff = [ZerosToTakeOff; Zer(i); Zer(i-1)];
    end
end
% Check if the last point was a single zero
if (Zer(length(Zer) - 1) ~= Zer(length(Zer)) - 1)
    ZerosToTakeOff = [ZerosToTakeOff; Zer(length(Zer))];
end
% hold on, plot(ZerosToTakeOff, 1:length(ZerosToTakeOff), 'r*');
% Changing the values in the initial matrix
Y(ZerosToTakeOff) = 1;
figure, plot(Y);
% Keep the matrix in its state before further changes
Y_Thresholded = Y;
%% Smoothing of the curve   
FitOptions = fitoptions('Method', 'SmoothingSpline', 'SmoothingParam', p_Spline);
FitType = fittype('smoothingspline');
X = (1:length(Y))';
cfun = fit(X, Y, FitType, FitOptions);
Profile = cfun(X);
% Get rid of negative values in the smoothed version
Profile(find(Profile < ThresDiff)) = 0;
figure(h), hold on, plot(X, Profile, '-');
%% Position of all maxima
MaxPosAll = f_FindMaxima(Profile);
%% For all peaks
for i_Peak = 1:length(MaxPosAll) % Loop on all the peaks detected on the current intensity profile
    Peak = [];
    Y = Y_Thresholded; % Re-initialise Y, in case it was changed for the previous peak analysis
    %% Width of the peak at the intensity threshold level
    % Going in Ox direction from peak max until finding the first 
    % zero value of the thresholded smoothed profile
    MaxPos = MaxPosAll(i_Peak);
    ind1 = find(Y(MaxPos:length(Y)) == 0);
    if ~isempty(ind1)
        ind1 = ind1(1) - 1;         % '-1' because at ind1(1) it is already under- threshold value
    else  % In case ind1 is not found, take the border of the profile        
        Y = [Y; Y(1:100)];  % Adding the initial piece at the end of the profile
        ind1 = find(Y(MaxPos:length(Y)) == 0);
        if isempty(ind1)
            continue
        end
        ind1 = ind1(1) - 1;
    end
    % Going in -Ox direction from peak max until finding first negative value
    ind2 = find(Y(MaxPos:-1:1) == 0);
    if ~isempty(ind2)
        ind2 = ind2(1) - 1;         % '-1' because at ind1(1) it is already under- threshold value
    else        % In case ind2 is not found, it means that the peak is continued on the other end of the profile
        continue
%         Y = [Y(length(Y)-100:length(Y)); Y];  % Adding the initial piece at the end of the profile
%         ind2 = find(Y(MaxPos:-1:1) == 0);
%         ind2 = ind2(1) - 1;   
    end
    % Translating distance to the peak maximum into coordinates along the profile
    RInd1 = MaxPos - ind2 + 1;
    RInd2 = MaxPos + ind1 - 1;
    % Visualisation
    % figure(h), hold on, plot(RInd1, Y(RInd1), 'g*', 'MarkerSize', 7);
    % figure(h), hold on, plot(RInd2, Y(RInd2), 'g*', 'MarkerSize', 7);    
    % Peak width at the threshold level 
    Peak.Width = RInd2 - RInd1 + 1;     % '+1' - because there is half a pixel more on each side of the peak
    % If the peak is just one point wide, do not consider it
    if Peak.Width < 2
        continue
    end
    % Peak center position in coords of the outline
    % Calculated as the middle between the two points of peak width 
    Peak.PositionOfPeakCenter = (RInd1 + RInd2) / 2;         
    % Check if this was not a peak that after smoothing became one peak with two maxima 
    if (~isempty(Peaks)) && (Peak.PositionOfPeakCenter == Peaks(length(Peaks)).PositionOfPeakCenter)
        continue
    end
    Peak.MaxIntens = max(Y(RInd1:RInd2));   % Maximum intensity of the peak
    % All peaks for current time point put together
    Peaks = [Peaks; Peak];
end


