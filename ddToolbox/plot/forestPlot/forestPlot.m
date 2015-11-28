function forestPlot(xLabels, modeVal, ci, ylabelText)
% plots a single forest plot

N = numel(modeVal);

hold on
% plot credibility intervals
for n=1:N
	plot([n n], ci(:,n) , 'k-')
end
% plot points
plot([1:N],modeVal,'ko')


set(gca,'xTick',[1:N],...
	'xTickLabel',xLabels)

set(gca,'XLim',[0 N+1])

ylabel(ylabelText)

return
