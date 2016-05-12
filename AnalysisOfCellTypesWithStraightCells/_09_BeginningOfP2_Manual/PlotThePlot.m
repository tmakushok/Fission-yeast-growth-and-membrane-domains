[N, Xout] = hist(Length, 12);
% bar(Xout, N, [0.5 0.5 0.5], 'LineWidth', 0.1);
bar(Xout, N, 'FaceColor', [0.3 0.3 0.3], 'EdgeColor', [0.3 0.3 0.3], 'LineWidth', 0.1);
% xlabel('Quick growth initiation moment at old end, in minutes from GS release');
set(gca,'XTick',0:50:350)
xlabel('Length of P2 (min)');
ylabel('N');
xlim([0 120]);