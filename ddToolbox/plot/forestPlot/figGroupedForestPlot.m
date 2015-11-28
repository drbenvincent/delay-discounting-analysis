function figGroupedForestPlot(uni)
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
for g=1:GROUPS
	modeVals(:,g) = [uni(g).glM.mode  uni(g).m.mode];
	CI95(:,:,g) = [uni(g).glM.CI95 uni(g).m.CI95];
end

[N, nGroups] = size(modeVals);

% create labels ---
xlabels=cell(N+1,1);
xlabels{1} = 'G^m';
for n=1:N, xlabels{n+1} = n; end
% -------

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
	modeVals(:,g) = [uni(g).glC.mode  uni(g).c.mode];
	CI95(:,:,g) = [uni(g).glC.CI95 uni(g).c.CI95];
end
xlabels{1} = 'G^c';
plotGroupedForestPlot(xlabels, modeVals, CI95, '$c$')
xlim([0.5 N+0.5])

clear CI95 modeValsCI95

% -----------------------------------------------------------
subplot(4,1,3) % LAPSE RATE
for g=1:GROUPS
	modeVals(:,g) = [uni(g).glEpsilon.mode uni(g).epsilon.mode];
	CI95(:,:,g) = [uni(g).glEpsilon.CI95 uni(g).epsilon.CI95];
end
xlabels{1} = 'G^\epsilon';
%plotGroupedForestPlot(xlabels, modeVals, CI95, '$\epsilon$') % plot as rate
plotGroupedForestPlot(xlabels, modeVals*100, CI95*100, '$\epsilon (\%)$') % plot as %
xlim([0.5 N+0.5])
a=axis; ylim([0 a(4)])
clear CI95 modeVals CI95

% -----------------------------------------------------------
subplot(4,1,4) % COMPARISON ACUITY
for g=1:GROUPS
	modeVals(:,g) = [uni(g).glALPHA.mode uni(g).alpha.mode];
	CI95(:,:,g) = [uni(g).glALPHA.CI95 uni(g).alpha.CI95];
end
% modeVals = [uniH.sigma.mode ; uniS.sigma.mode];
% CI95(:,:,1) = uniH.sigma.CI95;
% CI95(:,:,2) = uniS.sigma.CI95;
xlabels{1} = 'G^\alpha';
plotGroupedForestPlot(xlabels, modeVals, CI95, '$\alpha$')
xlim([0.5 N+0.5])
a=axis; ylim([0 a(4)])

return