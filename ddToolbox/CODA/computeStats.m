function stats = computeStats(all_samples)
% For each variable (field in the all_samples structure), compute a series
% of statistics (which will be fields of stats). The only complexity is
% that we have to be sensitive to whether each variable is a scalar,
% vector, or 2D matrix. Higher-dimensional variables are not currently
% supported.
disp('CODA: Calculating statistics')
assert(isstruct(all_samples))

variable_list = asRowVector(fieldnames(all_samples));

stats = struct('Rhat',[], 'mean', [], 'median', [], 'std', [],...
	'ci_low' , [] , 'ci_high' , [],...
	'hdi_low', [] , 'hdi_high' , []);

for variable_name = variable_list
    
	variable_samples = all_samples.(variable_name{:});
	
	switch ndims(variable_samples)
		case{2}
			stats = calcStatsScalar(stats, variable_samples, variable_name{:});
		case{3}
			stats = calcStatsVector(stats, variable_samples, variable_name{:});
		case{4}
			stats = calcStatsMatrix(stats, variable_samples, variable_name{:});
		otherwise
			stats = calcStatsTensor3(stats, variable_samples, variable_name{:});
	end
	
	Rhat = calcRhat(variable_samples);
	if ~isnan(Rhat)
		stats.Rhat.(variable_name{:}) = squeeze(Rhat);
	end
	
end

end


function stats = calcStatsScalar(stats, var_samples, var_name)
stats.mode.(var_name)	= calcMode( var_samples(:) );
stats.median.(var_name) = median( var_samples(:) );
stats.mean.(var_name)	= mean( var_samples(:) );
stats.std.(var_name)	= std( var_samples(:) );
[stats.ci_low.(var_name), stats.ci_high.(var_name)] = calcCI(var_samples(:));
[stats.hdi_low.(var_name), stats.hdi_high.(var_name)] = calcHDI(var_samples(:));
end

function stats = calcStatsVector(stats, var_samples, var_name)
sz = size(var_samples);
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
end

function stats = calcStatsMatrix(stats, var_samples, var_name)
sz = size(var_samples);
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
end

function stats = calcStatsTensor3(stats, var_samples, var_name)
warning('calculation of stats not supported for >2D matricies. You could implement it and send a pull request.')
stats.mode.(var_name) = [];
stats.median.(var_name) = [];
stats.mean.(var_name) = [];
stats.std.(var_name) = [];
stats.ci_low.(var_name) = [];
stats.ci_high.(var_name) = [];
stats.hdi_low.(var_name) = [];
stats.hdi_high.(var_name) = [];
end

function Rhat = calcRhat(var_samples)
% "estimated potential scale reduction" statistics due to Gelman and Rubin
sz = size(var_samples);
Nchains = sz(1);
Nsamples = sz(2);

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

function [low, high] = calcHDI(reshaped_samples)
% get the 95% highest density intervals of the posterior
[hdi] = HDIofSamples(reshaped_samples, 0.95);
low = squeeze(hdi(1));
high = squeeze(hdi(2));
end
