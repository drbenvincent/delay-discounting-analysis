function [models] = demo_compare_samplers(modelType)
% [models] = demo_compare_samplers('ModelHierarchicalLogK')

%% Setup
samplers = {'jags', 'stan'};
modelFunction = str2func(modelType);

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
path_of_this_mfile = strrep(which(mfilename),[mfilename '.m'],'');
toolbox_path = fullfile(path_of_this_mfile,'..','ddToolbox');
datapath = fullfile(path_of_this_mfile,'datasets','kirby');
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Run setup routine
addpath(toolbox_path)
ddAnalysisSetUp();

%% Do parameter estimation for each of the sampler types
for sampler = samplers
	models.(sampler{:}) = modelFunction(...
		Data(datapath, 'files', allFilesInFolder(datapath, 'txt')),...
		'savePath', fullfile(pwd,'output','my_analysis'),...
		'pointEstimateType', 'median',...
		'sampler', sampler{:},...
		'shouldPlot', 'no',...
		'shouldExportPlots', false,...
		'exportFormats', {'png'},...
		'mcmcParams', struct('nsamples', 200,...
		'nchains', 4,...
		'nburnin', 100));
end



%% Compare group level parameter estimates (repeated-measures)
assert(numel(samplers)==2,'this is only implemented for comparing TWO samplers against each other')

% get posteriors
varName = 'logk';	% TODO: Automatically do this for all variables
p=1;				% TODO: Automatically do it for all data files
for sampler = samplers
	posterior.(sampler{:}) = models.(sampler{:}).coda.getSamplesAtIndex(p, {varName});
end

% calculate differences
varNames = fieldnames(posterior.(sampler{1}));
for varName = varNames
	posteriorDifference.(varName{:}) = minus(...
		posterior.(samplers{1}).(varName{:}),...
		posterior.(samplers{2}).(varName{:}) );
end

% plot distribution of differences
figure
for varName = varNames
	mcmc.UnivariateDistribution(posteriorDifference.(varName{:}),...
		'XLabel', [samplers{1} ' - ' samplers{2}],...
		'plotHDI', true)
end
