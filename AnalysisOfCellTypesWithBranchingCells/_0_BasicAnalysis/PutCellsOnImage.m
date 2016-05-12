%% The task of the program is to write the numbers of cell on the
%% bright-field image
% clear;
% close all;
% -----------------------------
% The name of bright-field image file
File = 'REG_BF_AVG_Series006_tea1deltagfptna1_t060.mat';
% -----------------------------
load('_Output/output_CellsPixels.mat');
%% Show the bright-field image
BrFieldIm = load(['_InputImages/' File]);    
BrFieldIm = BrFieldIm.RegIm;
figure, imshow(BrFieldIm, []);

%% Write cell numbers on the cells
Pxs = AllCellsPixels{1,1};
for i_cell = 1:length(Pxs)
    x = Pxs{i_cell,1}(1,1);
    y = Pxs{i_cell,1}(1,2);    
    text(x, y, num2str(i_cell), 'FontWeight', 'bold', 'FontSize', 11);
end