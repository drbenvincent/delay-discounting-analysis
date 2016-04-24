function plotMCclusters(mcmcContainer, data, col, probMass)
% TODO: TURN THIS INTO A "GROUPBivariateDistribution" PLOT CLASS

% plot posteriors over (m,c) for all participants, as contour plots

figure(12)
% participants
for p = 1:data.nParticipants

	[samples] = mcmcContainer.getSamplesAtIndex(p, {'m','c'});

	mcBivariate = mcmc.BivariateDistribution(...
		samples.m,...
		samples.c,... %xLabel',variableNames{1},'yLabel',variableNames{2},...
		'plotStyle','contour',...
		'probMass',probMass,...
		'pointEstimateType','mode');
	% TODO: set the patch fill options to... definePlotOptions4Participant(col)
	%mcBivariate.plotContour(probMass, definePlotOptions4Participant(col))

	% plot numbers
	text(mcBivariate.mode(1),mcBivariate.mode(2),...
		sprintf('%d',p),...
		'HorizontalAlignment','center',...
		'VerticalAlignment','middle',...
		'FontSize',9,...
		'Color',col)
	drawnow
end
% keep axes zoomed in on all participants
axis tight
participantAxisBounds = axis;
% group
% mcBivariate = BivariateDistribution(...
% 	mcmcContainer.getSamplesAsMatrix({'m_group'}),...
% 	mcmcContainer.getSamplesAsMatrix({'c_group'}),...
% 	'shouldPlot',false);
% mcBivariate.plotContour(probMass, definePlotOptions4Group(col))

mcBivariate = mcmc.BivariateDistribution(...
		mcmcContainer.getSamplesAsMatrix({'m_group'}),...
		mcmcContainer.getSamplesAsMatrix({'c_group'}),... %xLabel',variableNames{1},'yLabel',variableNames{2},...
		'plotStyle','contour',...
		'probMass',probMass,...
		'pointEstimateType','mode');

axis(participantAxisBounds)
set(gca,'XAxisLocation','origin')
set(gca,'YAxisLocation','origin')
drawnow

	function plotOpts = definePlotOptions4Participant(col)
		plotOpts.FaceAlpha = '0.1';
		plotOpts.FaceColor = col;
		plotOpts.LineStyle = 'none';
	end

	function plotOpts = definePlotOptions4Group(col)
		plotOpts.FaceColor = 'none';
		plotOpts.EdgeColor = col;
		plotOpts.LineWidth = 2;
	end
end
