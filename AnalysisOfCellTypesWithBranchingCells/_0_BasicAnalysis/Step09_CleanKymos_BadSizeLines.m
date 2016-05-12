%% The task of the program is to take off from created kymographs 
%% the lines that are longer or shorter than their neighbours
%--------------------------------------------------------------------------
AllKymosFile = '_Output\AllKymographs.mat'; 
AllKymosCorrFile = '_Output\AllKymographsCorr.mat';
ThresLen = 12;  %Threshold on difference in length of cell outline
%--------------------------------------------------------------------------
close all;
load(AllKymosFile);
for i_K = 1:size(AllKymos, 1)
    close all;
    Kymo = AllKymos{i_K, 1};
    Len = zeros(size(Kymo, 1), 1);
    for i_Line = 1:size(Kymo, 1)
        Len(i_Line) = length(find(Kymo(i_Line, :)));
    end
    [LenRow, a, LenVal] = find(Len);
    figure, plot(LenRow, LenVal, 'ro-'); grid on
%% ??? Smooth it first???    
%% Differences matrix, then- matrix of slopes between points
    DiffVal = LenVal(2:length(LenVal)) - LenVal(1:length(LenVal) - 1);
    DiffRow = LenRow(2:length(LenRow)) - LenRow(1:length(LenRow) - 1);
    Slopes = DiffVal ./ DiffRow;
%% ??????? Take off negative values of slopes ???    
    Sl = median(Slopes);
%% Find corresponding second parameter of the correction line 
    SecPar = median(LenVal - Sl * LenRow);          % That means:  b = y - ax;
%% Baseline correction of length matrix   
    BL = Sl * LenRow + SecPar;
    NewLenVal = LenVal - BL;
%     figure, plot(LenRow, NewLenVal, 'ro-'), grid on;
%% Finding which lines have length (corrected) very different from other lines
    M = median(NewLenVal);
    indTakeOff = find((NewLenVal > M + ThresLen) | (NewLenVal < M - ThresLen));
    RealLinNbs = LenRow(indTakeOff);
%% Deleting the lines from the kymograph
    Kymo(RealLinNbs, :) = zeros(length(RealLinNbs), size(Kymo,2));
    AllKymos{i_K, 1} = Kymo;     
end
save(AllKymosCorrFile, 'AllKymos');









%% BackUp

% %% Smoothing spline of the points corresponding to lines lengths    
% %     x = 1:size(Kymo, 1);
%     p_SmSpline = 0.09;
%     FitOptions = fitoptions('Method', 'SmoothingSpline', 'SmoothingParam', p_SmSpline);
%     FitType = fittype('smoothingspline');  
%     cfun = fit(LenRow, LenVal, FitType, FitOptions);
%     hold on, plot(LenRow, cfun(LenRow), '-r');  
%     c = improfile(I,xi,yi,n);
%     [cx,cy,c] = improfile(...);    
%% Do linear fit of the bits of the lengths matrix
%     P = [];
%     L = length(LenRow);
%     % The whole length matrix length :-)
%     P(1,1:2) = polyfit([LenRow(1), LenRow(L)], [LenVal(1), LenVal(L)], 1);
%     % 2/3s from both sides, with one pixel displacement from both sides
%     P(2,1:2) = polyfit([LenRow(2), LenRow(ceil(2*L/3))], [LenVal(2), LenVal(ceil(2*L/3))], 1);
%     P(3,1:2) = polyfit([LenRow(floor(L/3)), LenRow(L-1)], [LenVal(floor(L/3)), LenVal(L-1)], 1);
%     % Halfs of length matrix, with two pixels displacement from both sides
%     P(4,1:2) = polyfit([LenRow(3), LenRow(ceil(L/2) + 1)], [LenVal(3), LenVal(ceil(L/2) + 1)], 1);
%     P(5,1:2) = polyfit([LenRow(floor(L/2) - 1), LenRow(L-2)], [LenVal(floor(L/2) - 1), LenVal(L-2)], 1);
%     figure, plot(1:5, P(:,1), '*-'), grid on;
% %% Negative slopes are impossible (cells don't shrink), take median of the positive slopes    
%     P(find(P(:,1) < 0), :) = [];
    
    
%     hold on, plot([1 10], [p(1) + p(2), 10*p(1) + p(2)]);