clear
close all

load('DividingCells.mat');
load('TimesStartGrowth_LongMovies.mat');

Monop = [];
MonopNb = [];
Bipol = [];
BipolNb = [];
SlowGrower = [];
TotalNbOfCells = length(find(DividingCells));
for i_cell = 1:length(DividingCells)
    if DividingCells(i_cell) == 0  % The cell is not followed till division
        continue
    end    
    
    if isempty(TimeStartGrowth{i_cell}) % If the growth of the cell was not detected
        continue
    end
    % Quick growth times for both cell ends 
    GrTimes = [TimeStartGrowth{i_cell}{1}(3); TimeStartGrowth{i_cell}{2}(3)];
    Nb = length(find(GrTimes)); % Number of cell ends initiating quick growth
    if Nb == 0
        SlowGrower = [SlowGrower; max(GrTimes)];
    end
    if Nb == 1
        Monop = [Monop; max(GrTimes)];  % 'max'- to avoid the zero value
        MonopNb(i_cell,1) = 1;
    end
    if Nb == 2
        Bipol = [Bipol; min(GrTimes)];  % the first of the two growth initiation times is taken
        BipolNb(i_cell,1) = 1;
    end        
end