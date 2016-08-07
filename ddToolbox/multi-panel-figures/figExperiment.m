function figExperiment(plotFuncs, plotdata)

assert(isstruct(plotdata))
assert(iscell(plotFuncs))
isa(plotFuncs{1},'function_handle')

fh = figure('Name', ['participant: ' plotdata.IDname{:}]);
latex_fig(16, 12, 5)

subplot_handles = create_subplots(numel(plotFuncs), 'row');

arrayfun(@(n) apply_plot_function_to_subplot_handle(plotFuncs{n}, subplot_handles(n), plotdata),...
	[1:numel(plotFuncs)])

drawnow

if plotdata.shouldExportPlots
	myExport(plotdata.savePath, 'expt',...
		'prefix', plotdata.IDname{:},...
		'suffix', plotdata.modelType);
end

close(fh)

% 	function goodnessStr = makeGoodnessStr()
% 		percentPredicted = plotdata.postPred.percentPredictedDistribution(:);
% 		pp = mcmc.UnivariateDistribution(percentPredicted, 'shouldPlot', false);
% 		goodnessStr = sprintf('%% predicted: %3.1f (%3.1f - %3.1f)',...
% 			pp.(plotdata.pointEstimateType)*100,...
% 			pp.HDI(1)*100,...
% 			pp.HDI(2)*100);
% 	end

end
