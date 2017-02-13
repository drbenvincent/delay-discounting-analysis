function clusterPlot(mcmcContainer, data, col, plotOptions, vars)

% deal with cluster plotting of either univariate or bivariate
% distributions

varNames = {vars.name};

if numel(varNames) == 1
	plot1Dclusters(mcmcContainer, data, col, plotOptions, vars);
elseif numel(varNames) == 2
	plot2Dclusters(mcmcContainer, data, col, plotOptions, vars);
else
	error('can only deal with plotting univariate or bivariate distributions')
end

end
