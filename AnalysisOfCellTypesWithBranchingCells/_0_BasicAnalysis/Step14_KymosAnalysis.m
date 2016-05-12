%% The task of the program is to plot TipsGrowth and find 
%% rates of growth and the moment when the growth starts. 
%% And also to find the half-widths of intensity peaks.
%% This program should receive the time point from which the movie was
%% started.
close all;
clear;
%--------------------------------------------------------------------------
TipsLenFile = '_Output/AllTipsLengths.mat'; 
KymosFile = '_Output/AllKymographsCorr.mat'; 
OutFile = '_Output/AllPeaksTip1.mat'; 
%--------------------------------------------------------------------------
load(TipsLenFile);
load(KymosFile);
AllPeaks = cell(length(TipsLen), 1);
for i_cell = 1:length(TipsLen)       % Loop on cells
    i_cell
    close all;
    Kymo = AllKymos{i_cell};
    if isempty(Kymo)        % If the kymograph for this cell is anyway considered bad
        AllPeaks{i_cell} = [];
        continue
    end
    % Where there is no non-zero line in kymo, not consider length there 
    % (because cell outline is not detected right at that time point)
    Peaks = zeros(size(Kymo,1), 2);
    for i_t = 1:size(Kymo,1)
        i_t
        Kymo_t = Kymo(i_t, :);
        % Where there is no non-zero line in kymo, not consider length there 
        % (because cell outline is not detected right at that time point)
        if isempty(find(Kymo_t))
            AllPeaks{i_cell}(i_t,:) = [0,0];
            continue;
        end
        AllPeaks{i_cell}(i_t,:) = f_Peaks(Kymo_t); % First col- peak width, second- peak position        
    end    
    plot(AllPeaks{i_cell,1}(:,1), '-*'), grid on;
end
%% Output the result        
save(OutFile, 'AllPeaks');








