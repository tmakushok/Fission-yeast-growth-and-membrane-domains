function f_removeFigEdges

hAxes = gca;
set(hAxes, 'Units', 'Pixels');
s = get(hAxes, 'Position');
set(gcf, 'Units', 'Pixels', 'Position', s + [200 200 0 0]);
set(hAxes, 'Position', [1 1 s(3) s(4)]);

end