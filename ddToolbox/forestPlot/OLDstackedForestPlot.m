function stackedForestPlot(uni)


% how many participants do we have
N = numel(uni.lr.mode);

% create x labels
xlabels=cell(N+1,1);
xlabels{1} = 'group';
for n=1:N
xlabels{n+1} = n;
end


subplot(4,1,1)
forestPlot(xlabels, [uni.groupMmu.mode uni.m.mode],...
	[uni.groupMmu.CI95 uni.m.CI95],...
	'm')

subplot(4,1,2)
forestPlot(xlabels, [uni.groupCmu.mode uni.c.mode],...
	[uni.groupCmu.CI95 uni.c.CI95],...
	'c')

subplot(4,1,3)
forestPlot(xlabels, [uni.groupW.mode uni.lr.mode],...
	[uni.groupW.CI95 uni.lr.CI95], '\lambda')
%xlim([-1 N+1])

subplot(4,1,4)
forestPlot(1:N, uni.sigma.mode, uni.sigma.CI95, '\sigma')
xlim([-1 N+1])

return