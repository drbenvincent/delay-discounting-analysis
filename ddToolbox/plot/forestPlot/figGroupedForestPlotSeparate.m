function figGroupedForestPlotSeparate(uni, participantIDlist)
% stackedplotGroupedForestPlot
% is basically a wrapper to plot multiple subplots of
% plotGroupedForestPlot
%
% takes in a structure called uni
% uni holds stats for multiple model fits



figure

GROUPS = numel(uni);

clear CI95

% -----------------------------------------------------------
subplot(4,1,1)
CI95 = uni.m.CI95;
for g=1:GROUPS
	modeVals(:,g) = [uni(g).m.mode];
	CI95(:,:,g) = [uni(g).m.CI95];
end
[N, nGroups] = size(modeVals);
xlabels = participantIDlist;
plotGroupedForestPlot(xlabels, modeVals, CI95, '$m$')
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
xlim([0.5 N+0.5])
hline(0,...
	'Color','k',...
	'LineStyle','--')

clear CI95 modeValsCI95

% -----------------------------------------------------------
subplot(4,1,2)
for g=1:GROUPS
	modeVals(:,g) = [uni(g).c.mode];
	CI95(:,:,g) = [uni(g).c.CI95];
end
plotGroupedForestPlot(xlabels, modeVals, CI95, '$c$')
xlim([0.5 N+0.5])

clear CI95 modeValsCI95

% -----------------------------------------------------------
subplot(4,1,3) % LAPSE RATE
for g=1:GROUPS
	modeVals(:,g) = [uni(g).epsilon.mode];
	CI95(:,:,g) = [uni(g).epsilon.CI95];
end
%plotGroupedForestPlot(xlabels, modeVals, CI95, '$\epsilon$') % plot as rate
plotGroupedForestPlot(xlabels, modeVals*100, CI95*100, '$\epsilon (\%)$') % plot as %
xlim([0.5 N+0.5])
a=axis; ylim([0 a(4)])
clear CI95 modeVals CI95

% -----------------------------------------------------------
subplot(4,1,4) % COMPARISON ACUITY
for g=1:GROUPS
	modeVals(:,g) = [uni(g).alpha.mode];
	CI95(:,:,g) = [uni(g).alpha.CI95];
end
% modeVals = [uniH.sigma.mode ; uniS.sigma.mode];
% CI95(:,:,1) = uniH.sigma.CI95;
% CI95(:,:,2) = uniS.sigma.CI95;
plotGroupedForestPlot(xlabels, modeVals, CI95, '$\alpha$')
xlim([0.5 N+0.5])
a=axis; ylim([0 a(4)])

return