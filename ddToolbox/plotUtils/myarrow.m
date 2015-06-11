function myarrow(xo,yo)

% Matlab is rather stupid. You can't plot arrows in data space, only in
% normalised figure space. So you have to convert data space to figure
% space. I used a solution offered here:
% http://stackoverflow.com/questions/11499370/how-to-plot-arrow-onto-a-figure-in-matlab

set(gcf,'Units','normalized')
set(gca,'Units','normalized')
ax = axis;
ap = get(gca,'Position');
%% annotation 
% xo = [opts.bayesFactorXvalue opts.bayesFactorXvalue];
% yo = [BFpriorDensity BFpostDensity];
xp = (xo-ax(1))/(ax(2)-ax(1))*ap(3)+ap(1);
yp = (yo-ax(3))/(ax(4)-ax(3))*ap(4)+ap(2);
ah=annotation('arrow',xp,yp,...
	'HeadStyle','deltoid');

return