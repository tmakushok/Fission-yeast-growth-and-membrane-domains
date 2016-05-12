close all;
%% Check the 'X'!!!
X = -3:0.15:5;
[N, X] = hist(Speeds, X);
h = figure, 

bar(X, N, 'w', 'LineWidth', 0.5)%, grid on;
% xlabel('Max speed of cell end growth, in microns per hour');
% ylabel('N');
% title('Wild type');

%% Fitting of the curve with a sum of two gaussians
% xHist = 0:0.2:2.5;
% figure, hist(DistFromCEnd_Plat, xHist);
% [n,xout] = hist(DistFromCEnd_Plat, xHist);
N = N';
X = X';
% Fit the data for distance between patch center and cell end
s = fitoptions('Method','NonlinearLeastSquares',...
               'Lower',[30, 1.8, 0.8, 0, 0, 0],...
               'Upper',[250, 5, 1, 900, 2.5, max(X)],...
               'Startpoint',[0,0,0,0,0,0]);
f = fittype('a*exp(-(x-b)^2/(2*c^2)) + d*exp(-(x-e)^2/(2*f^2))', 'options', s);
[c2,gof2] = fit(X, N, f);
Xmore = min(X):0.01:max(X);
Y = feval(c2,Xmore);
% Visualise

hold on, plot(Xmore, Y, 'r', 'LineWidth', 1);
%'LineWidth', 1);
% xlabel('Max speed of cell end growth, in microns per hour');
xlabel('Growth speed (µm/hour)');
ylabel('N');
% title('Wild type');
xlim([-1 4]); 
% ylim([0 450]); 

%% Fitting of the distribution containing only speeds from the growth
%% phases longer than the threshold
X = -3:0.15:4;
[N, X] = hist(Speeds_LongPhases, X);
h = figure, 
bar(X, N, 'w', 'LineWidth', 0.5)%, grid on;
%% Fitting of the curve with a sum of two gaussians
% xHist = 0:0.2:2.5;
% figure, hist(DistFromCEnd_Plat, xHist);
% [n,xout] = hist(DistFromCEnd_Plat, xHist);
N = N';
X = X';
% Fit the data for distance between patch center and cell end
s = fitoptions('Method','NonlinearLeastSquares',...
               'Lower',[100,0,3, 0,1,0],...
               'Upper',[640, 1, 4.5, 170, 2.5, max(X)],...
               'Startpoint',[1 1 1 1 1 1]);
f = fittype('a*exp(-(x-b)^2/2*c^2) + d*exp(-(x-e)^2/2*f^2)', 'options', s);
[c2,gof2] = fit(X, N, f);
Xmore = min(X):0.01:max(X);
Y = feval(c2,Xmore);
% Visualise
% hold on, plot(Xmore, Y, 'r', 'LineWidth', 1);
%'LineWidth', 1);
% xlabel('Max speed of cell end growth, in microns per hour');
xlabel('Growth speed (µm/hour)');
ylabel('N');
% title('Wild type');
xlim([-1 4]); 

%% Fitting of the distribution containing only max speed per cell end
X = -3:0.15:4;
[N, X] = hist(MaxSpeeds, X);
h = figure, 
bar(X, N, 'w', 'LineWidth', 0.5)%, grid on;
%% Fitting of the curve with a sum of two gaussians
% xHist = 0:0.2:2.5;
% figure, hist(DistFromCEnd_Plat, xHist);
% [n,xout] = hist(DistFromCEnd_Plat, xHist);
N = N';
X = X';
% Fit the data for distance between patch center and cell end
s = fitoptions('Method','NonlinearLeastSquares',...
               'Lower',[0,0,3, 0,1,0],...
               'Upper',[200, 1, 4.5, 170, 2.5, max(X)],...
               'Startpoint',[1 1 1 1 1 1]);
f = fittype('a*exp(-(x-b)^2/(2*c^2)) + d*exp(-(x-e)^2/(2*f^2))', 'options', s);
[c2,gof2] = fit(X, N, f);
Xmore = min(X):0.01:max(X);
Y = feval(c2,Xmore);
% Visualise
hold on, plot(Xmore, Y, 'r', 'LineWidth', 1);
%'LineWidth', 1);
% xlabel('Max speed of cell end growth, in microns per hour');
xlabel('Max growth speed (µm/hour)');
ylabel('N');
% title('Wild type');
xlim([0 4]); 
%% Fitting of the distribution containing only max speed per cell end
X = -3:0.15:4;
[N, X] = hist(MaxSpeeds, X);
h = figure, 
bar(X, N, 'w', 'LineWidth', 0.5)%, grid on;
%% Fitting of the curve with a sum of two gaussians
% xHist = 0:0.2:2.5;
% figure, hist(DistFromCEnd_Plat, xHist);
% [n,xout] = hist(DistFromCEnd_Plat, xHist);
N = N';
X = X';
% Fit the data for distance between patch center and cell end
s = fitoptions('Method','NonlinearLeastSquares',...
               'Lower',[0,0,3, 0,1,0],...
               'Upper',[200, 1, 4.5, 170, 2.5, max(X)],...
               'Startpoint',[1 1 1 1 1 1]);
f = fittype('a*exp(-(x-b)^2/2*c^2) + d*exp(-(x-e)^2/2*f^2)', 'options', s);
[c2,gof2] = fit(X, N, f);
Xmore = min(X):0.01:max(X);
Y = feval(c2,Xmore);
% Visualise
hold on, plot(Xmore, Y, 'r', 'LineWidth', 1);
%'LineWidth', 1);
% xlabel('Max speed of cell end growth, in microns per hour');
xlabel('Max growth speed (µm/hour)');
ylabel('N');
% title('Wild type');
xlim([0 4]); 
%% Fitting of the distribution containing only max speed per cell end
X = -3:0.15:4;
[N, X] = hist(MaxSpeeds, X);
h = figure, 
bar(X, N, 'w', 'LineWidth', 0.5)%, grid on;
% Fitting of the curve with a sum of two gaussians
N = N';
X = X';
% Fit the data for distance between patch center and cell end
s = fitoptions('Method','NonlinearLeastSquares',...
               'Lower',[0,0,3, 0,1,0],...
               'Upper',[200, 1, 4.5, 170, 2.5, max(X)],...
               'Startpoint',[1 1 1 1 1 1]);
f = fittype('a*exp(-(x-b)^2/2*c^2) + d*exp(-(x-e)^2/2*f^2)', 'options', s);
[c2,gof2] = fit(X, N, f);
Xmore = min(X):0.01:max(X);
Y = feval(c2,Xmore);
% Visualise
hold on, plot(Xmore, Y, 'r', 'LineWidth', 1);
%'LineWidth', 1);
% xlabel('Max speed of cell end growth, in microns per hour');
xlabel('Max growth speed (µm/hour)');
ylabel('N');
% title('Wild type');
xlim([0 4]); 
%% Fitting of the distribution containing only max speed per cell
X = -3:0.20:6;
% Choosing only the fastest phases that are long enough
LengthThres = 1;
Pos = find(CellMaxSpeed(:,2) > LengthThres);
CellMaxSpeed_Subset = CellMaxSpeed(Pos,1);

[N, X] = hist(CellMaxSpeed_Subset, X);
h = figure, 
bar(X, N, 'w', 'LineWidth', 0.5)%, grid on;
% Fitting of the curve with a sum of two gaussians
N = N';
X = X';
% Fit the data for distance between patch center and cell end
s = fitoptions('Method','NonlinearLeastSquares',...
               'Lower',[0,0,3, 0,1,0],...
               'Upper',[200, 1, 4.5, 170, 2.5, max(X)],...
               'Startpoint',[1 1 1 1 1 1]);
f = fittype('a*exp(-(x-b)^2/2*c^2) + d*exp(-(x-e)^2/2*f^2)', 'options', s);
[c2,gof2] = fit(X, N, f);
Xmore = min(X):0.01:max(X);
Y = feval(c2,Xmore);
% Visualise
hold on, plot(Xmore, Y, 'r', 'LineWidth', 1);
%'LineWidth', 1);
% xlabel('Max speed of cell end growth, in microns per hour');
xlabel('Max growth speed (µm/hour)');
ylabel('N');
% title('Wild type');
xlim([0 4.1]); 
ylim([0 17]); 