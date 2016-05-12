% close all;
clear;

load('_Input/AllPeaks_AllMoviesCombined.mat');
% load('_Input/TimesStartGrowth_ManuallyCorrected.mat');

% Width_Plat = [];
% PosPatch_Plat = [];
% DistFromCEnd_Plat = [];
% PatchMaxInt_Plat = [];
% 
% Width_Slow = [];
% PosPatch_Slow = [];
% DistFromCEnd_Slow = [];
% PatchMaxInt_Slow = [];

Width_Quick = [];
PosPatch_Quick = [];
DistFromCEnd_Quick = [];
PatchMaxInt_Quick = [];
NormPos = [];

N1 = 0;
N2 = 0;
for i_cell = 1:length(AllPeaks)     % Loop on the cells
    % If there is no info for this cell
    if isempty(AllPeaks{i_cell})
            continue
    end
    N1 = N1 + 1;
    
    
    
    
    
%     %% Finding the cell end that corresponds to the cell end switching to fast
%     %% growth at the beginning of P3
%     Times = [TimeStartGrowth{i_cell}{1}(3), TimeStartGrowth{i_cell}{2}(3)];  % Times of quick growth initiation for the two cell ends
%     if max(Times) == 0  % If no quick growth was detected for any of the cell ends
%        continue 
%     end
%     N2 = N2 + 1;
%     [Val, End] = min(Times);  % Choosing the end that starts to grow earlier
%     if Val == 0  % If one of the cell ends did not grow quickly
%         [Val, End] = max(Times);
%     end
%     if isempty(AllPeaks{i_cell}{End}) % If there is no info for this cell end
%         continue
%     end
    for i_end = 1:length(AllPeaks{i_cell})
        P = AllPeaks{i_cell}{i_end}(3);    
%         P 
        if P.Width == -2
            continue
        end
        % Data for start of quick growth time moment
        NormPos = [NormPos; P.NormPos];
        Width_Quick = [Width_Quick; P.Width];
        PosPatch_Quick = [PosPatch_Quick; P.PositionOfPeakCenter];
        DistFromCEnd_Quick = [DistFromCEnd_Quick; P.DistFromCEnd];
        PatchMaxInt_Quick = [PatchMaxInt_Quick; P.MaxIntens];
    end
end
%% Histogram of normalized distances between the domain center and one of the initial cell ends
[N, X] = hist(NormPos, 15);
h = figure, bar(X, N, 'w', 'LineWidth', 1);

width = 8;        % Width of the figure
height = 6;         % Height of the figure
set(gcf, 'PaperUnits', 'centimeters');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
FigureSize = [left, bottom, width, height];
set(gcf, 'PaperPosition', FigureSize);
% print('-dtiff', '-r800', '_Output/NormDistToInitCellEnd_Tea1.tiff'); 

%% Erasing values corresponding to patches not found
% Data for quick growth
Width_Quick(Width_Quick < 1) = [];
PosPatch_Quick(PosPatch_Quick < 1) = [];
DistFromCEnd_Quick(DistFromCEnd_Quick < 0) = [];
PatchMaxInt_Quick(PatchMaxInt_Quick < 1) = [];
% % Data for growing to 1 pixel time moment
% Width_Plat(Width_Plat < 1) = [];
% PosPatch_Plat(PosPatch_Plat < 1) = [];
% DistFromCEnd_Plat(DistFromCEnd_Plat < 0) = [];
% PatchMaxInt_Plat(PatchMaxInt_Plat < 1) = [];
% % Data for start of slow growth time moment
% Width_Slow(Width_Slow < 1) = [];
% PosPatch_Slow(PosPatch_Slow < 1) = [];
% DistFromCEnd_Slow(DistFromCEnd_Slow < 0) = [];
% PatchMaxInt_Slow(PatchMaxInt_Slow < 1) = [];
%% Conversion from pixels into microns
% Width_Plat = Width_Plat * 0.0707;
% Width_Slow = Width_Slow * 0.0707;
Width_Quick = Width_Quick * 0.0707;

% DistFromCEnd_Plat = DistFromCEnd_Plat * 0.0707;
% DistFromCEnd_Slow = DistFromCEnd_Slow * 0.0707;
DistFromCEnd_Quick = DistFromCEnd_Quick * 0.0707;
%% Means
WidQuickP3Avg = mean(Width_Quick);
WidQuickP3Std = std(Width_Quick);
%% Histograms
X = 0:0.5:7.5;
[N, Xout] = hist(DistFromCEnd_Quick, X);
figure, bar(Xout, N, 'FaceColor', [0.3 0.3 0.3], 'EdgeColor', [0.3 0.3 0.3], 'LineWidth', 0.1);
% xlabel('Quick growth initiation moment at old end, in minutes from GS release');
% set(gca,'XTick',0:50:350)
xlabel('Patch position (µm)');
ylabel('N');
% xlim([-0.13, 3]);
% ylim([0 140]);

xHist = 0:0.5:11;
figure, 
[Nhist, Xhist] = hist(Width_Quick, xHist);
bar(Xhist, Nhist, 'k', 'LineWidth', 1);  %, 'FaceColor', 'k');
xlabel('Width of peak at initiation of quick growth, in microns');
ylabel('N');
xlim([-0.5, 10.5]);
% ylim([0 90]);

[N, X] = hist(Width_Quick, 25);
h = figure, bar(X, N, 'w', 'LineWidth', 1);

width = 8;        % Width of the figure
height = 6;         % Height of the figure
set(gcf, 'PaperUnits', 'centimeters');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
FigureSize = [left, bottom, width, height];
set(gcf, 'PaperPosition', FigureSize);
print('-dtiff', '-r800', '_Output/DomWidthAtP3Init_Tea1.tiff'); 



