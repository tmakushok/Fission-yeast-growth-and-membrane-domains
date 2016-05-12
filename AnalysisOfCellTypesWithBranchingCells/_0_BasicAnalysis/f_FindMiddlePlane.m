function [ThePlane] = f_FindMiddlePlane(X, Y)
%-----------------
p_Spline = 0.05;
%!!!--!!! Number of points taken for linear fit of intensity profiles
%-- to get the slopes
PtsLinFit = 7;
%!!!--!!! Coefficient of linear aproximation of a region of the curve
SlopeThres = 6000;
%!!!--!!! Min histogram value for finding the lowest curve 
HistThresCompare = 100;         % (for 2048*2048 image)
%-----------------
Yinput = Y;         % Y is going to be changed next (central peaks are going to be cut off)
for i_pl = 1:length(X(:,1))     % Loop on all z-planes' histograms
%% Find the central peak        
    FitOptions = fitoptions('Method', 'SmoothingSpline', 'SmoothingParam', p_Spline);
    FitType = fittype('smoothingspline');
    cfun = fit(X(i_pl, :)', Y(i_pl, :)', FitType, FitOptions);

    Fit = cfun(X(i_pl, :)');
    
%     figure, bar(X(i_pl, :), Y(i_pl, :)); hold on;
%     plot(X(i_pl, :), Fit, '-r');

    PeakBegin = 0;
    PeakEnd = 0;
    %-- Beginning of the big peak
    for i_Slope = 1:length(Fit) - PtsLinFit
        x = (i_Slope:i_Slope + PtsLinFit - 1)';
        y = Fit(x);                   
        p = polyfit(x, y, 1);  

%         hold on
%         plot(x, p(1) * x + p(2), '-rs', 'MarkerSize', 5);   

        if p(1) > SlopeThres
            PeakBegin = i_Slope + floor(PtsLinFit / 2) + 1;
%             plot(PeakBegin, Fit(PeakBegin), '-go', 'MarkerSize', 9); 
            break
        end
    end
    %-- End of the slope of the big peak            
    for i_Slope = length(Fit):-1:PtsLinFit
        x = (i_Slope:-1:i_Slope - PtsLinFit + 1)';
        y = Fit(x);                   
        p = polyfit(x, y, 1);  

%         hold on
%         plot(x, p(1) * x + p(2), '-rs', 'MarkerSize', 5);   

        if p(1) < -SlopeThres
            PeakEnd = i_Slope - floor(PtsLinFit / 2) - 1;
%             plot(PeakEnd, Fit(PeakEnd), '-go', 'MarkerSize', 9); 
            break
        end
    end 
%% Cut off the central peak
    Y(i_pl, PeakBegin:PeakEnd) = 0;
%     figure, plot(X(i_pl,:), Y(i_pl,:), '-r');
%% Cut off histogram values that are too small for finding the lowest curve (error-prone)    
    Y(i_pl, find(Y(i_pl,:) < HistThresCompare)) = 0;
end
%% Analyse histograms with cut-off parts
% Compare sum signal in the parts left after cut-off for each Z-slice
Sums = sum(Y')';
[a, ThePlane] = min(Sums);





