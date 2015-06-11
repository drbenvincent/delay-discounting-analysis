function plotGroupedForestPlot(xLabels, modeVal, ci, ylabelText)
% plots a single forest plot

N = numel(xLabels);

[N, nGroups] = size(modeVal);

% attempt to use default spacing
defaultSpacing = 0.1;
groupXoffset = linspace(-defaultSpacing*(nGroups-1), defaultSpacing*(nGroups-1), nGroups);
% If there are too many groups then this spacing would lead to overlapping
% groups, in which case, define new spacings
if groupXoffset(end)-groupXoffset(1) > 0.9
	groupWidth = 0.8;
	groupXoffset=linspace(-groupWidth/2, groupWidth/2, nGroups);
end

hold on

for g = 1:nGroups
	
	%groupColour = [1 1 1].* (1- ((g-1)/(N-1)));
	groupColour = [1 1 1];
	
	% plot credibility intervals
	for n=1:N
		plot([n n]+groupXoffset(g), ci(:,n,g) , 'k-')
	end
	
	% plot points
	h=plot([1:N]+groupXoffset(g),modeVal(:,g), 'ko');
	h.MarkerFaceColor = groupColour;
	h.MarkerSize = 5;
end



set(gca,'xTick',[1:N],...
	'xTickLabel',xLabels)

axis tight
set(gca,'XLim',[0 N+1])

ylabel(ylabelText,'Interpreter','Latex')

return
