function stackedplotGroupedForestPlot2NOMAG(uni)
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
subplot(3,1,1)
for g=1:GROUPS
	modeVals(:,g) = [uni(g).groupLogKmu.mode  uni(g).participantLogK.mode];
	CI95(:,:,g) = [uni(g).groupLogKmu.CI95 uni(g).participantLogK.CI95];
end

[N, nGroups] = size(modeVals);

% create labels ---
xlabels=cell(N+1,1);
xlabels{1} = 'group';
for n=1:N, xlabels{n+1} = n; end
% -------

plotGroupedForestPlot(xlabels, modeVals, CI95, '$log(k)$')
xlim([0.5 N+0.5])
% hline(0,...
% 	'Color','k',...
% 	'LineStyle','--')

clear CI95 modeValsCI95

% -----------------------------------------------------------
% subplot(4,1,2)
% for g=1:GROUPS
% 	modeVals(:,g) = [uni(g).groupCmu.mode  uni(g).c.mode];
% 	CI95(:,:,g) = [uni(g).groupCmu.CI95 uni(g).c.CI95];
% end
% plotGroupedForestPlot(xlabels, modeVals, CI95, '$c$')
% xlim([0.5 N+0.5])
% 
% clear CI95 modeValsCI95

% -----------------------------------------------------------
subplot(3,1,2)
for g=1:GROUPS
	modeVals(:,g) = [uni(g).groupW.mode uni(g).lr.mode];
	CI95(:,:,g) = [uni(g).groupW.CI95 uni(g).lr.CI95];
end
% modeVals = [uniH.lr.mode ; uniS.lr.mode];
% CI95(:,:,1) = uniH.lr.CI95;
% CI95(:,:,2) = uniS.lr.CI95;
plotGroupedForestPlot(xlabels, modeVals, CI95, '$\lambda$')
xlim([0.5 N+0.5])
a=axis; ylim([0 a(4)])
clear CI95 modeVals CI95

% -----------------------------------------------------------
subplot(3,1,3)
for g=1:GROUPS
	modeVals(:,g) = uni(g).sigma.mode;
	CI95(:,:,g) = uni(g).sigma.CI95;
end
% modeVals = [uniH.sigma.mode ; uniS.sigma.mode];
% CI95(:,:,1) = uniH.sigma.CI95;
% CI95(:,:,2) = uniS.sigma.CI95;
plotGroupedForestPlot([1:N], modeVals, CI95, '$\sigma$')
xlim([0.5-1 N-1+0.5])
a=axis; ylim([0 a(4)])

return