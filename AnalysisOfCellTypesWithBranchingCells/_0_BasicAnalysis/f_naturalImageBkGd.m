function [BkGd] = f_naturalImageBkGd(InImage) 
%--------------------------------------------------------------------------
p_SmSpline = 0.001;
XOutLess = 1;
%--------------------------------------------------------------------------
[m, n] = size(InImage);
% Making a vector out of the matrix (otherwise historam of each column separately)
Pixels = reshape(InImage, 1, m * n);     
%% Creating a histogram of values of intensity of all pixels in an image
% NbBins = 3000;
MaxIntens = max(max(InImage));
[Nb,XOut] = hist(Pixels(find(Pixels ~= 0)), 500); % because croping produced 0 pixels
% XOut = 0:1:MaxIntens / XOutLess;
% [Nb,XOut] = hist(Pixels(find(Pixels ~= 0)), XOut); % because croping produced 0 pixels

% figure, bar(XOut, Nb); 
%% Smoothing spline applied to the histogram
% Creating an array with x values for smoothing spline dots positionning:
% dots are 10 times more frequent than the dots in the histogram analysed
x_Spl = XOut(1):((XOut(2) - XOut(1))):XOut(length(XOut));    

FitOptions = fitoptions('Method', 'SmoothingSpline', 'SmoothingParam', p_SmSpline);
FitType = fittype('smoothingspline');
cfun = fit(XOut', Nb', FitType, FitOptions);

% hold on;
% plot(x_Spl, cfun(x_Spl), '-r');
% hold off;

a = cfun(x_Spl);
[a, BkGd_index] = max(a');      % a is column, x_Spl is line
BkGd = x_Spl(BkGd_index);
     