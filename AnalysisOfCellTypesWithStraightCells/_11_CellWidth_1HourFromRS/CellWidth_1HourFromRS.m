%% Combine the info about all cells available, at the time point 18 = 61
%% min from release from starvation
close all
AllCells_Info = [AllGoodCells1{18,1}; AllGoodCells2{18,1}; AllGoodCells3{18,1};...
    AllGoodCells4{18,1}; AllGoodCells5{18,1}; AllGoodCells6{18,1}];
% Extracting the widths of all cells, in pixels
AllCells_Width = AllCells_Info(:,3);
hist(AllCells_Width, 20)
% Tranforming the widths into microns
AllCells_WidthInMicrons = AllCells_Width * 0.0707;
figure, hist(AllCells_WidthInMicrons, 20)
% Numbers
mean(AllCells_WidthInMicrons)
std(AllCells_WidthInMicrons)