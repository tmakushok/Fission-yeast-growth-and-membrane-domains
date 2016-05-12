%% Saving a plot into a tiff file
width = 8;        % Width of the figure
height = 6;         % Height of the figure

set(gcf, 'PaperUnits', 'centimeters');
papersize = get(gcf, 'PaperSize');

left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;

FigureSize = [left, bottom, width, height];
set(gcf, 'PaperPosition', FigureSize);

print('-dtiff', '-r500', '_Output/Plot');

% print('-dtiff', '-r500', '-loose', '_Output/TestTiff_Uncropped');

% print('-dtiff', '-r300', '-zbuffer', '_Output/TestTiff_zbuffer');
% 
% print('-dtiff', '-r300', '-painters', '_Output/TestTiff_painters');
% 
% print('-dtiff', '-r300', '-opengl', '_Output/TestTiff_OpenGL');

% print('-depsc', '-r300', '-f1','_Output/TestEPS');