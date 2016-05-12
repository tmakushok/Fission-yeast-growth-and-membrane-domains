close all;
clear;

load('_Input/PeaksPos_Normalized_AllMoviesCombined.mat');     

PosAllCells = [];
CellNb = 0;
for i_cell = 1:length(PeaksPos)       % Loop on cells
    Pos1Cell = PeaksPos{i_cell};
    if isempty(PeaksPos{i_cell})
        continue
    end
    PosAllCells = [PosAllCells; Pos1Cell];
    CellNb = CellNb + 1;
end
%% Statistics
PosMean = mean(PosAllCells)
PosMedian = median(PosAllCells)
% Skewness??? But not unimodal distr...






%% Scatter plot of all data points
figure, plot(PosAllCells, 'k.', 'MarkerSize', 3);
xlim([0, 1340]);

width = 4;        % Width of the figure
height = 6;         % Height of the figure
set(gcf, 'PaperUnits', 'centimeters');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
FigureSize = [left, bottom, width, height];
set(gcf, 'PaperPosition', FigureSize);
print('-dtiff', '-r800', '_Output/ScatterPlot_WithoutLabels_Narrow.tiff'); 


xlabel('Domain number');
ylabel('Norm. distance');
                      
width = 8;        % Width of the figure
height = 6;         % Height of the figure
set(gcf, 'PaperUnits', 'centimeters');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
FigureSize = [left, bottom, width, height];
set(gcf, 'PaperPosition', FigureSize);
% print('-dtiff', '-r800', '_Output/ScatterPlot.tiff');  
%% Histogram
[N, X] = hist(PosAllCells, 15);
h = figure, bar(X, N, 'w', 'LineWidth', 1);

width = 8;        % Width of the figure
height = 6;         % Height of the figure
set(gcf, 'PaperUnits', 'centimeters');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
FigureSize = [left, bottom, width, height];
set(gcf, 'PaperPosition', FigureSize);
% print('-dtiff', '-r800', '_Output/Hist_WithoutLabels.tiff'); 


xlabel('Norm. distance');
ylabel('Nb of domains');
                      
width = 8;        % Width of the figure
height = 6;         % Height of the figure
set(gcf, 'PaperUnits', 'centimeters');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
FigureSize = [left, bottom, width, height];
set(gcf, 'PaperPosition', FigureSize);
% print('-dtiff', '-r800', '_Output/Hist.tiff');
%% Box plot (to assess skewness, sort of)
figure;
boxplot(PosAllCells, ones(length(PosAllCells),1), 'notch','on', 'colors', 'k', 'labelorientation', 'inline', ...
    'widths', 0.3, 'outliersize', 4, 'symbol', '+', ...
    'labels',{''});
set(gca,'XTick',[]);
grid on

width = 4;        % Width of the figure
height = 6;         % Height of the figure
set(gcf, 'PaperUnits', 'centimeters');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
FigureSize = [left, bottom, width, height];
set(gcf, 'PaperPosition', FigureSize);
print('-dtiff', '-r800', '_Output/BoxPlot_ShiftTowards1.tiff');

