%% The task of the program is to extract average patch width for each of
%% the phases of cell growth to see if there is a correlation between speed
%% of cell end growth and the width of the corresponding patch

%% ??????? Width of the patch is followed from one time point before 
%% ??????? the growth initiation ???????
clear;
close all;

load('PatchWidths_OldEnd_FromQuickGrInit.mat'); 
load('CellGrowthDynamics.mat');

WidGr = [];
for i_cell = 1:length(DynamicsAll)
    if isempty(PeaksWidthsAll{i_cell})  % isempty(DynamicsAll{i_cell}) ||
       continue 
    end  
    % Finding which end is the quickly growing one
    End = QuickEnds(i_cell);
    Dyn_OneEnd = DynamicsAll{i_cell}{End};
    Wid_OneEnd = PeaksWidthsAll{i_cell};
    % From what time patch width is tracked (when is the growth initiation moment)
    for TimeInit = 1:length(Wid_OneEnd)
        if ~isempty(Wid_OneEnd(TimeInit).Width)
           break 
        end
    end
    for i_ph = 1:size(Dyn_OneEnd,1)       % Loop on phases of growth for the current cell        
        Width = [];
        t1 = Dyn_OneEnd(i_ph, 1); % Beginning of the phase of growth
        t2 = Dyn_OneEnd(i_ph, 2); % End of the phase of growth
        % Check if this phase of growth is after the cell growth initiation
        if t1 < TimeInit    % If beginning of the phase is before cell started growing 
            continue
        end
        for i = 1:t2-t1+1
            if isempty(Wid_OneEnd(t1 + i - 1).Width)
               continue 
            end
            Width(i,1) = Wid_OneEnd(t1 + i - 1).Width;        
        end
        p = polyfit((t1:t2)', Width, 1); % To get the slope of patch width changing
        % Visualise
        plot(t1:t2, Width, 'ro');
        hold on, plot(t1:t2, polyval(p, t1:t2)), hold off;
        WidGr = [WidGr; mean(Width), Dyn_OneEnd(i_ph, 3), p(1), length(find(Width))];      % In the final matrix first column is the average patch width during the current phase of growth and the second column is the speed of the cell end growth during this phase and the third is the slope of patch width variation
    end   
end

%% Transform to microns
Widths = WidGr(:,1) * 0.0707; 
Speeds = WidGr(:,2) * 0.0707; 
Slopes = WidGr(:,3) * 0.0707; 
% Conversion from speed per 3 minutes into speed per hour
Speeds = Speeds * 20; 
Slopes = Slopes * 20;
%% Take off NaN values of speed
for i = length(Speeds):-1:1
   if isnan(Speeds(i)) 
       Speeds(i) = [];
       Widths(i) = [];
       Slopes(i) = [];
   end
end
%% Take off negative values of average patch width
Speeds(Widths < 0) = [];
Slopes(Widths < 0) = [];
Widths(Widths < 0) = [];
%% Visualise
figure, plot(Widths, Speeds, 'ro', 'MarkerSize', 3);
xlabel('Average patch width over the phase of growth, in microns');
ylabel('Speed of the phase of growth, in microns per hour');
title('Wild type');

%% Correlation between patch width and speed of growth
[R, P] = corrcoef(Widths, Speeds);
p = polyfit(Widths, Speeds, 1);
Fit = polyval(p, Widths); 
hold on, plot(Widths, Fit)

figure, plot(Speeds, Slopes, 'ro', 'MarkerSize', 3);
ylabel('Speed of patch width changing during phase of growth, in microns per hour');
xlabel('Speed of phase of cell end growth, in microns per hour');
title('Wild type');

%% Correlation between patch width change speed and speed of growth
[R, P] = corrcoef(Speeds, Slopes);
p = polyfit(Speeds, Slopes, 1);
Fit = polyval(p, Speeds); 
hold on, plot(Speeds, Fit)

%% ----------------------------------------------
%% Keep only phases of growth that are long enough
TimeThres = 6; % In fact, this is a threshold on number of points of patch width during the phase
for i = size(WidGr, 1):-1:1
    if WidGr(i, 4) < TimeThres
        WidGr(i, :) = [];
    end
end

%% Transform to microns
Widths = WidGr(:,1) * 0.0707; 
Speeds = WidGr(:,2) * 0.0707; 
Slopes = WidGr(:,3) * 0.0707; 
% Conversion from speed per 3 minutes into speed per hour
Speeds = Speeds * 20; 
Slopes = Slopes * 20;
%% Take off NaN values of speed
for i = length(Speeds):-1:1
   if isnan(Speeds(i)) 
       Speeds(i) = [];
       Widths(i) = [];
       Slopes(i) = [];
   end
end
%% Take off negative values of average patch width
Speeds(Widths < 0) = [];
Slopes(Widths < 0) = [];
Widths(Widths < 0) = [];
%% Visualise
figure, plot(Widths, Speeds, 'ro', 'MarkerSize', 3);
xlabel('Average patch width over phase of growth, in microns');
ylabel('Speed of phase of growth, in microns per hour');
title('Wild type');

%% Correlation between patch width and speed of growth
[R, P] = corrcoef(Widths, Speeds);
p = polyfit(Widths, Speeds, 1);
Fit = polyval(p, Widths); 
hold on, plot(Widths, Fit)

figure, plot(Speeds, Slopes, 'ro', 'MarkerSize', 3);
ylabel('Speed of patch width changing during phase of growth, in microns per hour');
xlabel('Speed of phase of cell end growth, in microns per hour');
title('Wild type');

%% Correlation between patch width change speed and speed of growth
[R, P] = corrcoef(Speeds, Slopes);
p = polyfit(Speeds, Slopes, 1);
Fit = polyval(p, Speeds); 
hold on, plot(Speeds, Fit)
