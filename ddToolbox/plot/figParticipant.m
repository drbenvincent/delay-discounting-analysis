function figParticipant(plotFuncs, plotdata)

fh = figure('Name', ['participant: ' plotdata.IDname]);

subplot_handles = create_subplots(numel(plotFuncs), 'row');

arrayfun(...
	@(n) apply_plot_function_to_subplot_handle(plotFuncs{n}, subplot_handles(n), plotdata),...
	[1:numel(plotFuncs)])

%% EXPORT
latex_fig(16, 18, 4)
myExport('fig',...
	'saveFolder', plotdata.saveFolder,...
	'prefix', plotdata.IDname,...
	'suffix', plotdata.modelType);

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