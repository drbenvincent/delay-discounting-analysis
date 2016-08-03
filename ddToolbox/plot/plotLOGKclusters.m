function plotLOGKclusters(mcmcContainer, data, col, pointEstimateType, saveFolder, modelType, shouldExportPlots)

% plot posteriors over log(k) for all participants

figure(12), clf

% build samples
for p = 1:numel(data.IDname)
	logkSamples(:,p) = mcmcContainer.getSamplesFromParticipantAsMatrix(p, {'logk'});
end

uniG1 = mcmc.UnivariateDistribution(logkSamples(:,[1:data.nParticipants]),...
    'xLabel', '$\log(k)$',...
    'plotHDI', false,...
	'pointEstimateType', pointEstimateType,...
	'patchProperties',definePlotOptions4Participant(col));

% keep axes zoomed in on all participants
axis tight
participantAxisBounds = axis;

if size(logkSamples,2) == data.nParticipants+1
	mcmc.UnivariateDistribution(logkSamples(:,data.nParticipants+1),...
		'xLabel', '$\log(k)$',...
		'plotHDI', false,...
		'pointEstimateType', pointEstimateType,...
		'patchProperties',definePlotOptions4Group(col));
end
set(gca,'PlotBoxAspectRatio',[3,1,1])
axis(participantAxisBounds)
% set(gca,'XAxisLocation','origin',...
% 	'YAxisLocation','origin')
drawnow

if shouldExportPlots
	myExport('summary_plot',...
		'saveFolder', saveFolder,...
		'suffix', modelType)
end


	function plotOpts = definePlotOptions4Participant(col)
		plotOpts = {'FaceAlpha', 0.2,...
			'FaceColor', col,...
			'LineStyle', 'none'};
	end

	function plotOpts = definePlotOptions4Group(col)
		plotOpts = {'FaceColor', 'none',...
			'EdgeColor', col/2,...
			'LineWidth', 3};
	end
end
