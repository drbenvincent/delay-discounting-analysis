function plotErrorBars(xLabels, modeVal, ci, ylabelText)
% plots a single forest plot
N = numel(xLabels);
hold on
% plot credibility intervals
for n=1:N
	plot([n n], ci(:,n) , 'k-')
end
% plot points
h=plot([1:N],modeVal(:), 'ko');
h.MarkerFaceColor = [1 1 1];
h.MarkerSize = 5;
set(gca,'xTick',[1:N],...
	'xTickLabel',xLabels,...
	'FontSize',8,...
	'TickDir','out',...
	'XLim',[0.5 N+0.5])
axis tight
ylabel(ylabelText,'Interpreter','Latex')
return