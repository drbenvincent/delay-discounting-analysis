classdef CODA
	%CODA Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		samples
		stats
	end
	
	methods
		
		function obj = CODA(samples, stats) % constructor
			% This is the main constructor function.
			
			% Validate samples
			assert(isstruct(samples))
			
			obj.samples = samples;
			obj.stats = stats;
		end
		
		
		
		% -----------------------------------------------------------------
		% GET METHODS
		% -----------------------------------------------------------------
		
		function data = grabParamEstimates(obj, varNames, getCI, pointEstimateType)
			assert(islogical(getCI))
			data=[];
			for n=1:numel(varNames)
				data = [data obj.getStats(pointEstimateType,varNames{n})];
				if getCI
					data = [data obj.getStats('hdi_low',varNames{n})];
					data = [data obj.getStats('hdi_high',varNames{n})];
				end
			end
		end
		
		
		function [samples] = getSamplesAtIndex(obj, index, fieldsToGet)
			assert(iscell(fieldsToGet),'fieldsToGet must be a cell array')
			% get all the samples for a given value of the 3rd dimension of
			% samples. Dimensions are:
			% 1. mcmc chain number
			% 2. mcmc sample number
			% 3. index of variable, meaning depends upon context of the
			% model
			
			[flatSamples] = obj.flattenChains(obj.samples, fieldsToGet);
			for field = each(fieldsToGet)
				samples.(field) = flatSamples.(field)(:,index,:);
			end
		end
		
		function [samplesMatrix] = getSamplesFromParticipantAsMatrix(obj, participant, fieldsToGet)
			assert(iscell(fieldsToGet),'fieldsToGet must be a cell array')
			% TODO: This function is doing the same thing as getSamplesAtIndex() ???
			for field = each(fieldsToGet)
				samples.(field) = vec(obj.samples.(field)(:,:,participant));
			end
			[samplesMatrix] = struct2Matrix(samples);
		end
		
		function [samples] = getSamples(obj, fieldsToGet)
			% This will not flatten across chains
			%			assert(iscell(fieldsToGet),'fieldsToGet must be a cell array')
			for field = each(fieldsToGet)
				if isfield(obj.samples,field)
					samples.(field) = obj.samples.(field);
				end
			end
		end
		
		function [samplesMatrix] = getSamplesAsMatrix(obj, fieldsToGet)
			[samples] = obj.getSamples(fieldsToGet);
			% flatten across chains
			for field = each(fieldsToGet)
				samples.(field) = vec(samples.(field));
			end
			[samplesMatrix] = struct2Matrix(samples);
		end
		
		function [columnVector] = getStats(obj, field, variable)
			try
				columnVector = obj.stats.(field).(variable)';
			catch
				columnVector =[];
			end
		end
		
		function pointEstimates = getParticipantPointEstimates(obj, n, variableNames)
			assert(iscellstr(variableNames))
			for var = each(variableNames)
				temp = obj.getStats('mean', var);
				pointEstimates.(var) = temp(n);
			end
		end
		
		
		function [predicted] = getParticipantPredictedResponses(obj, ind)
			% ind is a binary valued vector indicating the trials
			% corresponding to a particular participant
			assert(isvector(ind))
			RpostPred = obj.samples.Rpostpred(:,:,ind);
			% collapse over chains
			s = size(RpostPred);
			%if ndims(RpostPred) == 2
			%	participantRpostpredSamples = RpostPred(:);
			%else
			%	warning('IS THIS LINE EVER REACHED?')
			participantRpostpredSamples = reshape(RpostPred, s(1)*s(2), s(3));
			%end
			% Calculate predicted response probability
			predicted = sum(participantRpostpredSamples,1) ./ size(participantRpostpredSamples,1);
		end
		
		function [P] = getPChooseDelayed(obj, pInd)
			% get samples for participant
			P = obj.samples.P(:,:,pInd);
			% flatten over chains
			s = size(P);
			P = reshape(P, s(1)*s(2), s(3));
			P=P';
		end
		
	end
	
	
	
	
	methods(Static)
		
		
		
% 		function stats = calcStatsFromSamples(samples)
% 			warning('CHECK THIS WORKS OK FOR SCALARS / VECTORS / ARRAYS')
% 			f = fieldnames(samples);
% 			for n=1:numel(f)
% 				stats.mean.(f{n}) = mean(samples.(f{n}));
% 				stats.median.(f{n}) = median(samples.(f{n}));
% 				stats.mode.(f{n}) = mode(samples.(f{n})); % TODO: do this by kernel density estimation
% 				stats.std.(f{n}) = std(samples.(f{n}));
% 				% get HDI
% 				tempSamples = samples.(f{n});
% 				for i=1:size(tempSamples,2)
% 					[HDI] = HDIofSamples(tempSamples(:,i), 0.95);
% 					stats.hdi_low.(f{n})(:,i) = HDI(1);
% 					stats.hdi_high.(f{n})(:,i) = HDI(2);
% 				end
% 				% get 95% CI
% 				tempSamples = samples.(f{n});
% 				for i=1:size(tempSamples,2)
% 					[CI] = prctile(tempSamples(:,i), [2.5 97.5]);
% 					stats.ci_low.(f{n})(:,i) = CI(1);
% 					stats.ci_high.(f{n})(:,i) = CI(2);
% 				end
% 			end
% 		end
		
		
		function [new_samples] = flattenChains(samples, fieldsToGet)
			% collapse the first 2 dimensions of samples (number of MCMC
			% chains, number of MCMC samples)
			for field = each(fieldsToGet)
				temp = samples.(field);
				oldDims = size(temp);
				switch numel(oldDims)
					case{2}
						% only dealing with one participant
						new_samples.(field) = vec(temp);
					case{3}
						% dealing with multiple participants
						newDims = [oldDims(1)*oldDims(2) oldDims(3)];
						new_samples.(field) = reshape(temp, newDims);
					case{4}
						newDims = [oldDims(1)*oldDims(2) oldDims(3) oldDims(4)];
						new_samples.(field) = reshape(temp, newDims);
				end
			end
		end
		
		% -----------------------------------------------------------------
		% ALTERNATE CONSTRUCTORS
		% -----------------------------------------------------------------
		
		function obj = buildFromStanFit(stanFitObject)
			% Call this function as a constructor when you have a StanFit
			% object, produced by MatlabStan.
			
			% convert StanFit object into samples structure
			samples = stanFitObject.extract('collapseChains', false,...
				'permuted', false);
			
			% TODO: calculate stats here
			stats = computeStats(samples);
			
			% call the constructor
			
			obj = CODA(samples, stats);
		end
		
		
	end
	
end








% -----------------------------------------------------------------
% LOCAL FUNCTIONS
% -----------------------------------------------------------------



function stats = computeStats(all_samples)
% For each variable (field in the all_samples structure), compute a series
% of statistics (which will be fields of stats). The only complexity is
% that we have to be sensitive to whether each variable is a scalar,
% vector, or 2D matrix. Higher-dimensional variables are not currently
% supported.
disp('CODA: Calculating statistics')
assert(isstruct(all_samples))

variable_names = fieldnames(all_samples);

stats = struct('Rhat',[], 'mean', [], 'median', [], 'std', [],...
	'ci_low' , [] , 'ci_high' , [],...
	'hdi_low', [] , 'hdi_high' , []);

for v=1:length(variable_names)
	var_name = variable_names{v};
	var_samples = all_samples.(var_name);
	
	sz = size(var_samples);
	Nchains = sz(1);
	Nsamples = sz(2);
	dims = ndims(var_samples);
	
	% Calculate stats
	switch dims
		case{2} % scalar
			stats.mode.(var_name)	= calcMode( var_samples(:) );
			stats.median.(var_name) = median( var_samples(:) );
			stats.mean.(var_name)	= mean( var_samples(:) );
			stats.std.(var_name)	= std( var_samples(:) );
			[stats.ci_low.(var_name), stats.ci_high.(var_name)] = calcCI(var_samples(:));
			[stats.hdi_low.(var_name), stats.hdi_high.(var_name)] = calcHDI(var_samples(:));
			
		case{3} % vector
			for n=1:sz(3)
				stats.mode.(var_name)(n)	= calcMode( vec(var_samples(:,:,n)) );
				stats.median.(var_name)(n)	= median( vec(var_samples(:,:,n)) );
				stats.mean.(var_name)(n)	= mean( vec(var_samples(:,:,n)) );
				stats.std.(var_name)(n)		= std( vec(var_samples(:,:,n)) );
				[stats.ci_low.(var_name)(n),...
					stats.ci_high.(var_name)(n)] = calcCI( vec(var_samples(:,:,n)) );
				[stats.hdi_low.(var_name)(n),...
					stats.hdi_high.(var_name)(n)] = calcHDI( vec(var_samples(:,:,n)) );
			end
		case{4} % 2D matrix
			for a=1:sz(3)
				for b=1:sz(4)
					stats.mode.(var_name)(a,b)		= calcMode( vec(var_samples(:,:,a,b)) );
					stats.median.(var_name)(a,b)	= median( vec(var_samples(:,:,a,b)) );
					stats.mean.(var_name)(a,b)		= mean( vec(var_samples(:,:,a,b)) );
					stats.std.(var_name)(a,b)		= std( vec(var_samples(:,:,a,b)) );
					[stats.ci_low.(var_name)(a,b),...
						stats.ci_high.(var_name)(a,b)] = calcCI( vec(var_samples(:,:,a,b)) );
					[stats.hdi_low.(var_name)(a,b),...
						stats.hdi_high.(var_name(a,b))] = calcHDI( vec(var_samples(:,:,a,b)) );
				end
			end
		otherwise
			warning('calculation of stats not supported for >2D variables. You could implement it and send a pull request.')
			stats.mode.(var_name) = [];
			stats.median.(var_name) = [];
			stats.mean.(var_name) = [];
			stats.std.(var_name) = [];
			stats.ci_low.(var_name) = [];
			stats.ci_high.(var_name) = [];
			stats.hdi_low.(var_name) = [];
			stats.hdi_high.(var_name) = [];
	end
	
	%% "estimated potential scale reduction" statistics due to Gelman and Rubin.
	Rhat = calcRhat();
	if ~isnan(Rhat)
		stats.Rhat.(var_name) = squeeze(Rhat);
	end
	
end


	function Rhat = calcRhat()
		st_mean_per_chain = mean(var_samples, 2);
		st_mean_overall   = mean(st_mean_per_chain, 1);
		
		if Nchains > 1
			B = (Nsamples/Nchains-1) * ...
				sum((st_mean_per_chain - repmat(st_mean_overall, [Nchains,1])).^2);
			varPerChain = var(var_samples, 0, 2);
			W = (1/Nchains) * sum(varPerChain);
			vhat = ((Nsamples-1)/Nsamples) * W + (1/Nsamples) * B;
			Rhat = sqrt(vhat./(W+eps));
		else
			Rhat = nan;
		end
	end

	function [low, high] = calcCI(reshaped_samples)
		% get the 95% interval of the posterior
		ci_samples_overall = prctile( reshaped_samples , [ 2.5 97.5 ] , 1 );
		ci_samples_overall_low = ci_samples_overall( 1,: );
		ci_samples_overall_high = ci_samples_overall( 2,: );
		low = squeeze(ci_samples_overall_low);
		high = squeeze(ci_samples_overall_high);
	end

	function [low, high] = 	calcHDI(reshaped_samples)
		% get the 95% highest density intervals of the posterior
		[hdi_samples_overall_low, hdi_samples_overall_high] = HDIofSamples(reshaped_samples);
		low = squeeze(hdi_samples_overall_low);
		high = squeeze(hdi_samples_overall_high);
	end
end

function [HDI_lower, HDI_upper] = HDIofSamples(samples)
% Calculate the 95% Highest Density Intervals. This has advantages over the
% regular 95% credible interval for some 'shapes' of distribution.
%
% Translated by Benjamin T. Vincent (www.inferenceLab.com) from code in:
% Kruschke, J. K. (2015). Doing Bayesian Data Analysis: A Tutorial with R,
% JAGS, and Stan. Academic Press.

credibilityMass = 0.95;

[nSamples, N] = size(samples);
for i=1:N
	selectedSortedSamples = sort(samples(:,i));
	ciIdxInc = floor( credibilityMass * numel( selectedSortedSamples ) );
	nCIs = numel( selectedSortedSamples ) - ciIdxInc;
	
	ciWidth=zeros(nCIs,1);
	for n =1:nCIs
		ciWidth(n) = selectedSortedSamples( n + ciIdxInc ) - selectedSortedSamples(n);
	end
	
	[~, minInd] = min(ciWidth);
	HDI_lower(i)	= selectedSortedSamples( minInd );
	HDI_upper(i)	= selectedSortedSamples( minInd + ciIdxInc);
end
end

function mode = calcMode(x)
[F, XI] = ksdensity( x );
[~, ind] = max(F);
mode = XI(ind);
end
