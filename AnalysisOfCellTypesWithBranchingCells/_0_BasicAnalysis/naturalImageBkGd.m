function [BkGd] = naturalImageBkGd(InImage) 
%--------------------------------------------------------------------------
p_SmSpline = 0.99;
XOutLess = 1;
%--------------------------------------------------------------------------
[m, n] = size(InImage);
Pixels = reshape(InImage, 1, m * n);     % Making a vector out of the matrix
%% Creating a histogram of values of intensity of all pixels in an image
% NbBins = 3000;
MaxIntens = max(max(InImage));
% XOut = 0:0.07:MaxIntens / XOutLess;
XOut = 0:MaxIntens / XOutLess;
[Nb,XOut] = hist(Pixels, double(XOut));

% figure, bar(XOut, Nb); hold on;

%% Smoothing spline applied to the histogram
% Creating an array with x values for smoothing spline dots positionning:
% dots are 10 times more frequent than the dots in the histogram analysed
x_Spl = XOut(1):((XOut(2) - XOut(1)) / 10):XOut(length(XOut));    

FitOptions = fitoptions('Method', 'SmoothingSpline', 'SmoothingParam', p_SmSpline);
FitType = fittype('smoothingspline');
cfun = fit(XOut', Nb', FitType, FitOptions);

A = cfun(XOut);

% plot(x_Spl, cfun(x_Spl), '-r');
% plot(XOut, cfun(XOut), '-r');
% hold off;
% 
% pause(.1);

% [a, b, BkGd_index] = simple_max2D(cfun(x_Spl));
[a, BkGd_index] = max(Nb);
% BkGd = x_Spl(BkGd_index);
BkGd = XOut(BkGd_index);
     