close all;
clear;
%% -----------
PhLenThresMax = 4;  % Minimal duration of phase for cell max growth speed, in time points
%% -----------
load('Dynamics.mat');
load('TimesStartGrowth_ManuallyCorrected.mat');
%% Choosing the cells that were followed at least until P3 initiation
CellNbs = [];
for i = 1:length(TimeStartGrowth)
    Times = [];
    for i_end = 1:length(TimeStartGrowth{i})
        Times = [Times; TimeStartGrowth{i}{i_end}(3)];
    end        
    if max(Times) > 0
        CellNbs = [CellNbs; i];  % The list of good cell numbers
    end
end
%% Accumulating speeds for the distribution for max speeds of individual cells 
MaxSpeeds_LongPhases = [];
for i_cell = 1:length(CellNbs)     % Loop on the cells followed at least until P3 initiation
    CellNb = CellNbs(i_cell);
    MaxLong = zeros(1, length(Dynamics{CellNb}));
    for i_end = 1:length(Dynamics{CellNb})        
%         if isempty(Dynamics{CellNb}{i_end}) % If there is no info for this cell end
%             continue
%         end
        D = Dynamics{CellNb}{i_end};                 
        for i_ph = 1:size(D,1)
            if D(i_ph, 2) - D(i_ph, 1) >= PhLenThresMax       % Max growth speeds for phases longer than threshold  
            	MaxLong(i_end) = max(MaxLong(i_end), D(i_ph,3));     % Accumulation of the max speed values for all cell ends 
            end
        end               
    end   
    MaxSpeeds_LongPhases = [MaxSpeeds_LongPhases; max(MaxLong)];    % The maximal out of the max speeds of individual cell ends is kept as cell's global max growth speed
end
%% Conversion from pixels into microns
MaxSpeeds_LongPhases = MaxSpeeds_LongPhases * 0.0707;
%% Conversion from speed per 3 minutes into speed per hour
MaxSpeeds_LongPhases = MaxSpeeds_LongPhases * 20;
%% Single Gaussian fit of the distribution containing max speed per cell chosen
%% initially from the long enough phases (MaxSpeeds_LongPhases)
X = -3:0.35:4.5;
[N, X] = hist(MaxSpeeds_LongPhases, X);
h = figure, 
bar(X, N, 'w', 'LineWidth', 0.5)%, grid on;
% Fitting of the curve with a sum of two gaussians
N = N';
X = X';
% Fit the data for distance between patch center and cell end
s = fitoptions('Method','NonlinearLeastSquares',...
               'Lower',[0,1,0],...
               'Upper',[170, 2.5, max(X)],...
               'Startpoint',[1 1 1]);
f = fittype('a*exp(-(x-b)^2/2*c^2)', 'options', s);
[c2,gof2] = fit(X, N, f);
Xmore = min(X):0.01:max(X);
Y = feval(c2,Xmore);
% Visualise
hold on, plot(Xmore, Y, 'r', 'LineWidth', 1);
xlim([0 4.2]);