%% The task of the function is to find outliers in a set of data and take
%% them off.

function [X, Y] = f_TakeOffOutliers(X, Y, OutlierThres)
PtToAnalyze = 2;
while 1
    FlagOut = 0;
    for i_out = PtToAnalyze:length(Y)
        Yadd1 = Y(i_out - 1);
        Yadd2 = Y(i_out);
        % If the value to the left of the data point was 0,
        % extrapolate values from the three previous left neighbours
        dX = X(i_out) - X(i_out - 1);
        if dX > 1
            % Do linear regression through the five previous left
            % neighbours
            Xfit = X(max(i_out - 5, 1) : i_out - 1);
            Yfit = Y(max(i_out - 5, 1) : i_out - 1);
            p = polyfit(Xfit, Yfit, 1);
            Yadd1 = polyval(p, X(i_out) - 1);  
%             hold on, plot(X(i_out) - 1, Yadd1, 'g*');
        end                
        % Checking for big gap with the left neighbour
        Diff = abs(Yadd2 - Yadd1);
        if Diff > OutlierThres
            X(i_out) = [];
            Y(i_out) = [];
            PtToAnalyze = i_out;     % Next point to be analyzed is the one that replaces the one taken away
            break
        end  
        if i_out == length(Y)
            FlagOut = 1;
        end
    end  
    if (FlagOut == 1) || (PtToAnalyze > length(Y))
        break   % If all the points are analysed, get out of the loop
    end
end

