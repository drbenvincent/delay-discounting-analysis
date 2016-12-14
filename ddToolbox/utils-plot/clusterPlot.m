function clusterPlot(mcmcContainer, data, col, modelType, plotOptions, vars)

% deal with cluster plotting of either univariate or bivariate
% distributions

varNames = {vars.name};

if numel(varNames)==1
    plot1Dclusters(mcmcContainer, data, col, modelType, plotOptions, vars);
elseif numel(varNames)==2
    plot2Dclusters(mcmcContainer, data, col, modelType, plotOptions, vars);
else
    error('can only deal with plotting univariate or bivariate distributions')
end

end


function plot1Dclusters(mcmcContainer, data, col, modelType, plotOptions, varInfo)

% TODO: plotExpclusters.m and plotLOGKclusters are pretty much identical

% TODO: plotExpclusters.m and plotLOGKclusters also do the same thing
% (conceptually) as plotMCclusters.m

% TODO:
% remove input:
% - mcmcContainer, just pass in the data
% - data, just pass in 
% rename to plotUnivariateDistributions

% plot posteriors over log(k) for all participants


figure(12), clf

%% REAL EXPERIMENT DATA
% build samples
for p = 1:data.getNExperimentFiles()
	samples(:,p) = mcmcContainer.getSamplesFromExperimentAsMatrix(p, {varInfo.name});
end

uniG1 = mcmc.UnivariateDistribution(samples(:,[1:data.getNRealExperimentFiles()]),...
    'xLabel', varInfo.label,...
    'plotHDI', false,...
	'pointEstimateType', plotOptions.pointEstimateType,...
	'patchProperties',definePlotOptions4Participant(col));

% keep axes zoomed in on all participants
axis tight
participantAxisBounds = axis;

%% GROUP LEVEL (UNOBSERVED PARTICIPANT)
groupSamples = samples(:,data.getNExperimentFiles());

if data.isUnobservedPartipantPresent() && ~any(isnan(groupSamples))
	mcmc.UnivariateDistribution(groupSamples,...
		'xLabel', varInfo.label,...
		'plotHDI', false,...
		'pointEstimateType', plotOptions.pointEstimateType,...
		'patchProperties', definePlotOptions4Group(col));
end

%% Formatting
set(gca,'PlotBoxAspectRatio',[3,1,1])
axis(participantAxisBounds)
% set(gca,'XAxisLocation','origin',...
% 	'YAxisLocation','origin')
drawnow

if plotOptions.shouldExportPlots
	myExport(plotOptions.savePath, 'summary_plot',...
		'suffix', modelType,...
        'formats', {'png'})
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



function plot2Dclusters(mcmcContainer, data, col, modelType, plotOptions, varInfo)

% TODO:
% remove input:
% - mcmcContainer, just pass in the data
% - data, just pass in 
% rename to plotBivariateDistributions


% plot posteriors over (m,c) for all participants, as contour plots

probMass = 0.5;

figure(12), clf

% build samples
for p = 1:data.getNExperimentFiles()
	x(:,p) = mcmcContainer.getSamplesFromExperimentAsMatrix(p, {varInfo(1).name});
	y(:,p) = mcmcContainer.getSamplesFromExperimentAsMatrix(p, {varInfo(2).name});
end

%% plot all actual participants
mcBivariateParticipants = mcmc.BivariateDistribution(...
	x(:,[1:data.getNRealExperimentFiles()]),...
	y(:,[1:data.getNRealExperimentFiles()]),...
	'xLabel', varInfo(1).label,...
	'yLabel', varInfo(2).label,...
	'plotStyle','contour',...
	'probMass',probMass,...
	'pointEstimateType','mode',...
	'patchProperties',definePlotOptions4Participant(col));

% TODO: enable this functionality in BivariateDistribution
% % plot numbers
% for p = 1:data.getNExperimentFiles()
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
x_group = x(:,data.getNExperimentFiles());
y_group = y(:,data.getNExperimentFiles());
if ~any(isnan(x(:,end))) && ~any(isnan(x_group)) && ~any(isnan(y_group))% do we have (m,c) samples for the group-level?
	if data.isUnobservedPartipantPresent()
		mcBivariateGroup = mcmc.BivariateDistribution(...
			x_group,...
			y_group,... %xLabel',variableNames{1},'yLabel',variableNames{2},...
			'plotStyle','contour',...
			'probMass',probMass,...
			'pointEstimateType', plotOptions.pointEstimateType,...
			'patchProperties', definePlotOptions4Group(col));
	end
end

axis(participantAxisBounds)
set(gca,'XAxisLocation','origin',...
	'YAxisLocation','origin')
drawnow

if plotOptions.shouldExportPlots
	myExport(plotOptions.savePath, 'summary_plot',...
		'suffix', modelType,...
        'formats', {'png'})
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
