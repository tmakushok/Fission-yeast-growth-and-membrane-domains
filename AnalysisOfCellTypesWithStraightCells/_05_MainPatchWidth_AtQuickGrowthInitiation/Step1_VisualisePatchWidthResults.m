%% The task of the program is to plot the results of the previous step.
%% The output of the previous step is the width of the cell end patch 
%% at three cell growth moments
% close all;
% clear;

load('PeaksWidth_AtGrowthTimes.mat');
load('TimesStartGrowth.mat');

%% Data for cell ends switching to fast growth at the beginning of P3
Width_Plat = [];
PosPatch_Plat = [];
DistFromCEnd_Plat = [];
PatchMaxInt_Plat = [];

Width_Slow = [];
PosPatch_Slow = [];
DistFromCEnd_Slow = [];
PatchMaxInt_Slow = [];

Width_Quick = [];
PosPatch_Quick = [];
DistFromCEnd_Quick = [];
PatchMaxInt_Quick = [];

for i_cell = 1:length(AllPeaks)     % Loop on the cells
    % If there is no info for this cell
    if isempty(AllPeaks{i_cell})
            continue
    end
    %% Finding the cell end that corresponds to the cell end switching to fast
    %% growth at the beginning of P3
    Times = [TimeStartGrowth{i_cell}{1}(3), TimeStartGrowth{i_cell}{2}(3)];  % Times of quick growth initiation for the two cell ends
    if max(Times) == 0  % If no quick growth was detected for any of the cell ends
       continue 
    end
    [Val, End] = min(Times);  % Choosing the end that starts to grow earlier
    if Val == 0  % If one of the cell ends did not grow quickly
        [Val, End] = max(Times);
    end
    
    if isempty(AllPeaks{i_cell}{End}) % If there is no info for this cell end
        continue
    end
    P = AllPeaks{i_cell}{End};
    % Data for growing to 1 pixel time moment
    Width_Plat = [Width_Plat; P(1).Width];
    PosPatch_Plat = [PosPatch_Plat; P(1).PositionOfPeakCenter];
    DistFromCEnd_Plat = [DistFromCEnd_Plat; P(1).DistFromCEnd];
    PatchMaxInt_Plat = [PatchMaxInt_Plat; P(1).MaxIntens];
    % Data for start of slow growth time moment
    Width_Slow = [Width_Slow; P(2).Width];
    PosPatch_Slow = [PosPatch_Slow; P(2).PositionOfPeakCenter];
    DistFromCEnd_Slow = [DistFromCEnd_Slow; P(2).DistFromCEnd];
    PatchMaxInt_Slow = [PatchMaxInt_Slow; P(2).MaxIntens];
    % Data for start of quick growth time moment
    Width_Quick = [Width_Quick; P(3).Width];
    PosPatch_Quick = [PosPatch_Quick; P(3).PositionOfPeakCenter];
    DistFromCEnd_Quick = [DistFromCEnd_Quick; P(3).DistFromCEnd];
    PatchMaxInt_Quick = [PatchMaxInt_Quick; P(3).MaxIntens];
end
%% Erasing values corresponding to patches not found
% Data for growing to 1 pixel time moment
Width_Plat(Width_Plat < 1) = [];
PosPatch_Plat(PosPatch_Plat < 1) = [];
DistFromCEnd_Plat(DistFromCEnd_Plat < 0) = [];
PatchMaxInt_Plat(PatchMaxInt_Plat < 1) = [];
% Data for start of slow growth time moment
Width_Slow(Width_Slow < 1) = [];
PosPatch_Slow(PosPatch_Slow < 1) = [];
DistFromCEnd_Slow(DistFromCEnd_Slow < 0) = [];
PatchMaxInt_Slow(PatchMaxInt_Slow < 1) = [];
% Data for quick growth
Width_Quick(Width_Quick < 1) = [];
PosPatch_Quick(PosPatch_Quick < 1) = [];
DistFromCEnd_Quick(DistFromCEnd_Quick < 0) = [];
PatchMaxInt_Quick(PatchMaxInt_Quick < 1) = [];
%% Conversion from pixels into microns
Width_Plat = Width_Plat * 0.0707;
Width_Slow = Width_Slow * 0.0707;
Width_Quick = Width_Quick * 0.0707;

DistFromCEnd_Plat = DistFromCEnd_Plat * 0.0707;
DistFromCEnd_Slow = DistFromCEnd_Slow * 0.0707;
DistFromCEnd_Quick = DistFromCEnd_Quick * 0.0707;
%% Means
WidQuickP3Avg = mean(Width_Quick);
WidQuickP3Std = std(Width_Quick);
%% Histograms
X = 0:0.2:3.5;
[N, Xout] = hist(DistFromCEnd_Quick, X);
figure, bar(Xout, N, 'FaceColor', [0.3 0.3 0.3], 'EdgeColor', [0.3 0.3 0.3], 'LineWidth', 0.1);
% xlabel('Quick growth initiation moment at old end, in minutes from GS release');
% set(gca,'XTick',0:50:350)
xlabel('Patch position (µm)');
ylabel('N');
xlim([-0.13, 3]);
ylim([0 140]);

xHist = 0:0.5:11;
figure, 
[Nhist, Xhist] = hist(Width_Quick, xHist);
bar(Xhist, Nhist, 'k', 'LineWidth', 1);  %, 'FaceColor', 'k');
xlabel('Width of peak at initiation of quick growth, in microns');
ylabel('N');
xlim([-0.5, 10.5]);
ylim([0 90]);



%%
%% Data for cell ends switching to fast growth at the beginning of P4
Width_Plat = [];
PosPatch_Plat = [];
DistFromCEnd_Plat = [];
PatchMaxInt_Plat = [];

Width_Slow = [];
PosPatch_Slow = [];
DistFromCEnd_Slow = [];
PatchMaxInt_Slow = [];

Width_Quick = [];
PosPatch_Quick = [];
DistFromCEnd_Quick = [];
PatchMaxInt_Quick = [];

for i_cell = 1:length(AllPeaks)     % Loop on the cells
    % If there is no info for this cell
    if isempty(AllPeaks{i_cell})
            continue
    end
    %% Finding the cell end switching to fast growth at the beginning of P4
    Times = [TimeStartGrowth{i_cell}{1}(3), TimeStartGrowth{i_cell}{2}(3)];  % Times of quick growth initiation for the two cell ends
    if length(find(Times)) < 2  % If quick growth was not initiated at both ends
       continue 
    end
    [Val, End] = max(Times);  % Choosing the end that starts to grow later
   
    if isempty(AllPeaks{i_cell}{End}) % If there is no info for this cell end
        continue
    end
    P = AllPeaks{i_cell}{End};
    % Data for growing to 1 pixel time moment
    Width_Plat = [Width_Plat; P(1).Width];
    PosPatch_Plat = [PosPatch_Plat; P(1).PositionOfPeakCenter];
    DistFromCEnd_Plat = [DistFromCEnd_Plat; P(1).DistFromCEnd];
    PatchMaxInt_Plat = [PatchMaxInt_Plat; P(1).MaxIntens];
    % Data for start of slow growth time moment
    Width_Slow = [Width_Slow; P(2).Width];
    PosPatch_Slow = [PosPatch_Slow; P(2).PositionOfPeakCenter];
    DistFromCEnd_Slow = [DistFromCEnd_Slow; P(2).DistFromCEnd];
    PatchMaxInt_Slow = [PatchMaxInt_Slow; P(2).MaxIntens];
    % Data for growing to 1 pixel time moment
    Width_Quick = [Width_Quick; P(3).Width];
    PosPatch_Quick = [PosPatch_Quick; P(3).PositionOfPeakCenter];
    DistFromCEnd_Quick = [DistFromCEnd_Quick; P(3).DistFromCEnd];
    PatchMaxInt_Quick = [PatchMaxInt_Quick; P(3).MaxIntens];
end
%% Erasing values corresponding to patches not found
% Data for growing to 1 pixel time moment
Width_Plat(Width_Plat < 1) = [];
PosPatch_Plat(PosPatch_Plat < 1) = [];
DistFromCEnd_Plat(DistFromCEnd_Plat < 0) = [];
PatchMaxInt_Plat(PatchMaxInt_Plat < 1) = [];
% Data for start of slow growth time moment
Width_Slow(Width_Slow < 1) = [];
PosPatch_Slow(PosPatch_Slow < 1) = [];
DistFromCEnd_Slow(DistFromCEnd_Slow < 0) = [];
PatchMaxInt_Slow(PatchMaxInt_Slow < 1) = [];
% Data for quick growth
Width_Quick(Width_Quick < 1) = [];
PosPatch_Quick(PosPatch_Quick < 1) = [];
DistFromCEnd_Quick(DistFromCEnd_Quick < 0) = [];
PatchMaxInt_Quick(PatchMaxInt_Quick < 1) = [];
%% Conversion from pixels into microns
Width_Plat = Width_Plat * 0.0707;
Width_Slow = Width_Slow * 0.0707;
Width_Quick = Width_Quick * 0.0707;

DistFromCEnd_Plat = DistFromCEnd_Plat * 0.0707;
DistFromCEnd_Slow = DistFromCEnd_Slow * 0.0707;
DistFromCEnd_Quick = DistFromCEnd_Quick * 0.0707;
%% Means
WidQuickP4Avg = mean(Width_Quick);
WidQuickP4Std = std(Width_Quick);
%% Histograms
X = 0:0.2:3.5;
[N, Xout] = hist(DistFromCEnd_Quick, X);
figure, bar(Xout, N, 'FaceColor', [0.3 0.3 0.3], 'EdgeColor', [0.3 0.3 0.3], 'LineWidth', 0.1);
% xlabel('Quick growth initiation moment at old end, in minutes from GS release');
% set(gca,'XTick',0:50:350)
xlabel('Patch position (µm)');
ylabel('N');
xlim([-0.13, 3]);
ylim([0 35]);




% xHist = 0:0.5:11;
% figure, hist(Width_Plat, xHist);
% title('Width of the peak at 1 pixel growth moment, in microns');
% 
% figure, hist(Width_Slow, xHist);
% title('Width of the peak at beginning of slow growth, in microns');
% 
% figure, 
% [Nhist, Xhist] = hist(Width_Quick, xHist);
% bar(Xhist, Nhist, 'k', 'LineWidth', 1);  %, 'FaceColor', 'k');
% xlabel('Width of peak at second cell end growth initiation, in microns');
% ylabel('N');
% xlim([-0.5, 10.5]);
% ylim([0 19]);
% 
% %% Distance between patch center and cell end and fit of the data for quick growth
% figure, hist(DistFromCEnd_Quick, xHist);
% title('Distance from center of patch to cell end (for quick growth), in microns');
% [n,xout] = hist(DistFromCEnd_Quick, xHist);
% n = n';
% xout = xout';
% hold on;
% % Fit the data for distance between patch center and cell end
% s = fitoptions('Method','NonlinearLeastSquares',...
%                'Lower',[0,0,0],...
%                'Upper',[Inf,max(xout), max(xout)],...
%                'Startpoint',[1 1 1]);
% f = fittype('a*exp((-x+b)/c)', 'options', s);
% [c2,gof2] = fit(xout, n, f);
% plot(c2,'r');








% %% Distance between patch center and cell end and fit of the data for 1
% %% pixel growth
% xHist = 0:0.2:2.5;
% figure, hist(DistFromCEnd_Plat, xHist);
% [n,xout] = hist(DistFromCEnd_Plat, xHist);
% n = n';
% xout = xout';
% title('Distance from center of patch to cell end (for 1 pixel growth), in microns');
% hold on;
% % Fit the data for distance between patch center and cell end
% s = fitoptions('Method','NonlinearLeastSquares',...
%                'Lower',[0,0,0],...
%                'Upper',[Inf,max(xout), max(xout)],...
%                'Startpoint',[1 1 1]);
% f = fittype('a*exp((-x+b)/c)', 'options', s);
% [c2,gof2] = fit(xout, n, f);
% plot(c2,'r');
% %% Distance between patch center and cell end and fit of the data for slow growth
% figure, hist(DistFromCEnd_Slow, xHist);
% title('Distance from center of patch to cell end (for slow growth), in microns');
% [n,xout] = hist(DistFromCEnd_Slow, xHist);
% n = n';
% xout = xout';
% hold on;
% % Fit the data for distance between patch center and cell end
% s = fitoptions('Method','NonlinearLeastSquares',...
%                'Lower',[0,0,0],...
%                'Upper',[Inf,max(xout), max(xout)],...
%                'Startpoint',[1 1 1]);
% f = fittype('a*exp((-x+b)/c)', 'options', s);
% [c2,gof2] = fit(xout, n, f);
% plot(c2,'r');







%% BackUp

%% !!! The results of the two cell ends are put together, as if the two cell
%% !!! ends were independent
% Width_Plat = [];
% PosPatch_Plat = [];
% DistFromCEnd_Plat = [];
% PatchMaxInt_Plat = [];
% 
% Width_Slow = [];
% PosPatch_Slow = [];
% DistFromCEnd_Slow = [];
% PatchMaxInt_Slow = [];
% 
% Width_Quick = [];
% PosPatch_Quick = [];
% DistFromCEnd_Quick = [];
% PatchMaxInt_Quick = [];
% 
% for i_cell = 1:length(AllPeaks)     % Loop on the cells
%     % If there is no info for this cell
%     if isempty(AllPeaks{i_cell})
%             continue
%     end
%     for i_end = 1:length(AllPeaks{i_cell})        
%         if isempty(AllPeaks{i_cell}{i_end}) % If there is no info for this cell end
%             continue
%         end
%         P = AllPeaks{i_cell}{i_end};
%         % Data for growing to 1 pixel time moment
%         Width_Plat = [Width_Plat; P(1).Width];
%         PosPatch_Plat = [PosPatch_Plat; P(1).PositionOfPeakCenter];
%         DistFromCEnd_Plat = [DistFromCEnd_Plat; P(1).DistFromCEnd];
%         PatchMaxInt_Plat = [PatchMaxInt_Plat; P(1).MaxIntens];
%         % Data for start of slow growth time moment
%         Width_Slow = [Width_Slow; P(2).Width];
%         PosPatch_Slow = [PosPatch_Slow; P(2).PositionOfPeakCenter];
%         DistFromCEnd_Slow = [DistFromCEnd_Slow; P(2).DistFromCEnd];
%         PatchMaxInt_Slow = [PatchMaxInt_Slow; P(2).MaxIntens];
%         % Data for growing to 1 pixel time moment
%         Width_Quick = [Width_Quick; P(3).Width];
%         PosPatch_Quick = [PosPatch_Quick; P(3).PositionOfPeakCenter];
%         DistFromCEnd_Quick = [DistFromCEnd_Quick; P(3).DistFromCEnd];
%         PatchMaxInt_Quick = [PatchMaxInt_Quick; P(3).MaxIntens];
%     end
% end
% %% Erasing values corresponding to patches not found
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
% % Data for quick growth
% Width_Quick(Width_Quick < 1) = [];
% PosPatch_Quick(PosPatch_Quick < 1) = [];
% DistFromCEnd_Quick(DistFromCEnd_Quick < 0) = [];
% PatchMaxInt_Quick(PatchMaxInt_Quick < 1) = [];
% %% Conversion from pixels into microns
% Width_Plat = Width_Plat * 0.0707;
% Width_Slow = Width_Slow * 0.0707;
% Width_Quick = Width_Quick * 0.0707;
% 
% DistFromCEnd_Plat = DistFromCEnd_Plat * 0.0707;
% DistFromCEnd_Slow = DistFromCEnd_Slow * 0.0707;
% DistFromCEnd_Quick = DistFromCEnd_Quick * 0.0707;
% %% Means
% % mean(Width_Plat), mean(Width_Slow), mean(Width_Quick),
% % median(Width_Plat), median(Width_Slow), median(Width_Quick),
% % mean(PatchMaxInt_Plat), mean(PatchMaxInt_Slow), mean(PatchMaxInt_Quick),
% 
% xHist = 0:0.5:11;
% % figure, plot(Width_Plat, 'o', 'MarkerSize', 3);
% % title('Width of the peak at 1 pixel growth moment, in microns');
% figure, hist(Width_Plat, xHist);
% title('Width of the peak at 1 pixel growth moment, in microns');
% 
% % figure, plot(PosPatch_Plat, 'o', 'MarkerSize', 3);
% % title('Position of the peak at 1 pixel growth moment, in px');
% % figure, plot(DistFromCEnd_Plat, 'o', 'MarkerSize', 3);
% % title('Distance from cell end to the peak at 1 pixel growth moment, in microns');
% % figure, plot(PatchMaxInt_Plat, 'o', 'MarkerSize', 3);
% % title('Max intensity of the peak at 1 pixel growth moment, in microns');
% 
% % figure, plot(Width_Slow, 'o', 'MarkerSize', 3);
% % title('Width of the peak at beginning of slow growth, in microns');
% figure, hist(Width_Slow, xHist);
% title('Width of the peak at beginning of slow growth, in microns');
% 
% % figure, plot(PosPatch_Slow, 'o', 'MarkerSize', 3);
% % title('Position of the peak at beginning of slow growth, in px');
% % figure, plot(DistFromCEnd_Slow, 'o', 'MarkerSize', 3);
% % title('Distance from cell end to the peak at beginning of slow growth, in microns');
% % figure, plot(PatchMaxInt_Slow, 'o', 'MarkerSize', 3);
% % title('Max intensity of the peak at beginning of slow growth, in microns');
% 
% % figure, plot(Width_Quick, 'o', 'MarkerSize', 3);
% % title('Width of the peak at beginning of quick growth, in microns');
% figure, 
% [Nhist, Xhist] = hist(Width_Quick, xHist);
% bar(Xhist, Nhist, 'k', 'LineWidth', 1);  %, 'FaceColor', 'k');
% xlabel('Width of peak at initiation of quick growth, in microns');
% ylabel('N');
% xlim([-0.5, 10.5]);
% ylim([0 105]);
% % title('Width of the peak at beginning of quick growth, in microns');
% 
% % figure, plot(PosPatch_Quick, 'o', 'MarkerSize', 3);
% % title('Position of the peak at beginning of quick growth, in px');
% % figure, plot(DistFromCEnd_Quick, 'o', 'MarkerSize', 3);
% % title('Distance from cell end to the peak at beginning of quick growth, in microns');
% % figure, plot(PatchMaxInt_Quick, 'o', 'MarkerSize', 3);
% % title('Max intensity of the peak at beginning of quick growth, in
% % microns');


% %% Max patch intensity vs patch width
% figure, plot(Width_Slow, PatchMaxInt_Slow, 'ro', 'MarkerSize', 3);
% title('Max patch intensity vs patch width (for slow growth)');
% xlabel('Patch width, in microns');
% ylabel('Max patch intensity');
% 
% figure, plot(Width_Plat, PatchMaxInt_Plat, 'ro', 'MarkerSize', 3);
% title('Max patch intensity vs patch width (for 1 pixel growth)');
% xlabel('Patch width, in microns');
% ylabel('Max patch intensity');
% 
% figure, plot(Width_Quick, PatchMaxInt_Quick, 'ro', 'MarkerSize', 3);
% title('Max patch intensity vs patch width (for quick growth)');
% xlabel('Patch width, in microns');
% ylabel('Max patch intensity');