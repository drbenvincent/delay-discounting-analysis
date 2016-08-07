function plotMCclusters(mcmcContainer, data, col, pointEstimateType, savePath, modelType, shouldExportPlots)

% TODO:
% remove input:
% - mcmcContainer, just pass in the data
% - data, just pass in 
% rename to plotBivariateDistributions


% plot posteriors over (m,c) for all participants, as contour plots

probMass = 0.5;

figure(12), clf

% build samples
for p = 1:data.nExperimentFiles
	m(:,p) = mcmcContainer.getSamplesFromParticipantAsMatrix(p, {'m'});
	c(:,p) = mcmcContainer.getSamplesFromParticipantAsMatrix(p, {'c'});
end

%% plot all actual participants
mcBivariateParticipants = mcmc.BivariateDistribution(...
	m(:,[1:data.nRealParticipants]),...
	c(:,[1:data.nRealParticipants]),...
	'xLabel','m',...
	'yLabel','c',...
	'plotStyle','contour',...
	'probMass',probMass,...
	'pointEstimateType','mode',...
	'patchProperties',definePlotOptions4Participant(col));

% TODO: enable this functionality in BivariateDistribution
% % plot numbers
% for p = 1:data.nExperimentFiles
% 	text(mcBivariate.mode(1),mcBivariate.mode(2),...
% 		sprintf('%d',p),...
% 		'HorizontalAlignment','center',...
% 		'VerticalAlignment','middle',...
% 		'FontSize',9,...
% 		'Color',col)
% end

% keep axes zoomed in on all participants
axis tight
participantAxisBounds = axis;

%% plot unobserved participant (ie group level) if they exist
m_group = m(:,data.nExperimentFiles);
c_group = c(:,data.nExperimentFiles);
if ~any(isnan(m(:,end))) && ~any(isnan(m_group)) && ~any(isnan(c_group))% do we have (m,c) samples for the group-level?
	%if size(m,2) == data.nExperimentFiles + 1
	if data.unobservedPartipantPresent
		mcBivariateGroup = mcmc.BivariateDistribution(...
			m_group,...
			c_group,... %xLabel',variableNames{1},'yLabel',variableNames{2},...
			'plotStyle','contour',...
			'probMass',probMass,...
			'pointEstimateType',pointEstimateType,...
			'patchProperties',definePlotOptions4Group(col));
	end
end

axis(participantAxisBounds)
set(gca,'XAxisLocation','origin',...
	'YAxisLocation','origin')
drawnow

if shouldExportPlots
	myExport(savePath, 'summary_plot',...
		'suffix', modelType)
end

	function plotOpts = definePlotOptions4Participant(col)
		plotOpts = {'FaceAlpha', 0.1,...
			'FaceColor', col,...
			'LineStyle', 'none'};
	end

	function plotOpts = definePlotOptions4Group(col)
		plotOpts = {'FaceColor', 'none',...
			'EdgeColor', col,...
			'LineWidth', 2};
	end
end
