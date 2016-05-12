close all

figure 
bar(Results, 0.3, 'stack');
colormap([1 0.2 0;...
          0 0 0.4]);

xlim([0.5 2.5]);
ylim([0 120]);
set(gca,'XTick',[]);

% Saving the plot into a tiff file
width = 8;        % Width of the figure
height = 6;         % Height of the figure

set(gcf, 'PaperUnits', 'centimeters');
papersize = get(gcf, 'PaperSize');

left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;

FigureSize = [left, bottom, width, height];
set(gcf, 'PaperPosition', FigureSize);

print('-dtiff', '-r500', 'Plot');