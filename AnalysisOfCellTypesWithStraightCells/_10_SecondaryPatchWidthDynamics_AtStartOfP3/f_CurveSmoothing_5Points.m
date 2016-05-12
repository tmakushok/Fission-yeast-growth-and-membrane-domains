function [X, Y] = f_CurveSmoothing(X,Y)
YnonSm = Y;
for i_sm = 3:length(YnonSm)-2
    Yadd0 = YnonSm(i_sm - 2);
    Yadd1 = YnonSm(i_sm - 1);
    Yadd2 = YnonSm(i_sm);
    Yadd3 = YnonSm(i_sm + 1);
    Yadd4 = YnonSm(i_sm + 2);
    % If the value to the left of the data point was 0,
    % then linear approximation is done between the two points on
    % the two sides of the zeros region and the value on the
    % current position is taken as the smoothed value
    dX = X(i_sm) - X(i_sm - 1);
    if dX > 1
        Yadd1 = Yadd1 + ((Yadd2 - Yadd1) / dX) * (dX - 1);                
    end
    % For the one further left neigbour
    dX = X(i_sm - 1) - X(i_sm - 2);
    if dX > 1
        Yadd0 = Yadd0 + ((Yadd1 - Yadd0) / dX) * (dX - 1);                
    end
    % If the value to the right of the data point was 0,
    % do the same thing as above
    dX = X(i_sm + 1) - X(i_sm);
    if dX > 1
        Yadd3 = Yadd2 + ((Yadd3 - Yadd2) / dX);                
    end          
    % For the one further right neigbour
    dX = X(i_sm + 2) - X(i_sm + 1);
    if dX > 1
        Yadd4 = Yadd3 + ((Yadd4 - Yadd3) / dX);                
    end  
    % Calculating the current point after smoothing    
    Y(i_sm) = (Yadd0 + Yadd1 + Yadd2 + Yadd3 + Yadd4) / 5;
end   



