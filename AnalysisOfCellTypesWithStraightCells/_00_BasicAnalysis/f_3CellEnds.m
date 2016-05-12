%% The task of the function is to find positions of the cell ends
%% corresponding to positions of peaks on distance 
%% from cell center to outline
function [Ends] = f_3CellEnds(Cont, Center)
%% Creating distances matrix
Dist = sqrt((Cont(:,2) - Center(1)) .^ 2 + (Cont(:,1) -  Center(2)) .^ 2);
% plot(Dist), grid on;

%% Smoothing of the curve   
FitOptions = fitoptions('Method', 'SmoothingSpline', 'SmoothingParam', 0.01);
FitType = fittype('smoothingspline');
X = (1:length(Dist))';
cfun = fit(X, Dist, FitType, FitOptions);
DistSmoo = cfun(X);

% hold on, plot(DistSmoo, '-r');
% Get rid of negative values in the smoothed version
% Profile(find(Profile < ThresDiff)) = 0;
% figure(h), hold on, plot(X, Profile, '-');

%% Position of central peak maximum
% Difference matrix
Signs = sign(DistSmoo(2:length(DistSmoo)) - DistSmoo(1:length(DistSmoo) - 1));
% figure, plot(Signs, '-o');
%% Cycle 'Signs': put first element at the end
%% to catch the case when a peak is exactly at the profile opening point
Signs = [Signs; Signs(1)];
%% Find maxima
Signs(find(Signs < 0)) = -11;
Ends = find(Signs(1:length(Signs) - 1) - Signs(2:length(Signs)) == 12) + 1;
