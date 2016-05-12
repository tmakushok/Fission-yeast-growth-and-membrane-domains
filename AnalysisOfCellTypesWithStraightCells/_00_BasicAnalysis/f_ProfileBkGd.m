function [BkGd] = f_ProfileBkGd(Y) 
%--------------------------------------------------------------------------
p_SmSpline = 0.1;
%--------------------------------------------------------------------------    
%% Creating a histogram of values
[Nb,XOut] = hist(Y, 40); 

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
     