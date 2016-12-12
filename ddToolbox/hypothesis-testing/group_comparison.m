function group1_minus_group2 = group_comparison(group1, group2, vars, pointEstimateType, method)
% group1_minus_group2 = group_comparison(group1, group2, {'logk'}, 11)

% input validation
assert(any(strcmp(superclasses(group1),'Model')), 'group1 must be some subclass of Model')
assert(any(strcmp(superclasses(group2),'Model')), 'group2 must be some subclass of Model')
assert(iscellstr(vars))
assert(any(strcmp(pointEstimateType,{'mean','median','mode'})))

% grab estimates for all requested variables, into a structure
group1_estimates = group1.getGroupLevelSamples(vars);
group2_estimates = group2.getGroupLevelSamples(vars);

% compute the difference
for var = vars
	% TODO: make this a stochastic object
	group1_minus_group2.(var{:}) = group1_estimates.(var{:}) - group2_estimates.(var{:});
end

switch method
	case{'parameter estimation'}
		%% METHOD 1: Parameter Estimation approach
		
		% You could now plot this distribution of differences very simply as:
		% >>  hist(group_logk_difference, 31)
		%
		% but we can use my mcmc-utils-matlab repository code...
		
		for var = vars
			figure
			mcmc.UnivariateDistribution(group1_minus_group2.(var{:}),...
				'XLabel','group 1 - group 2',...
				'pointEstimateType', pointEstimateType,...
				'shouldPlotPointEstimate', true)
			title(['Differences in group level ' var{:}], 'Interpreter','latex')
		end
		
	case{'bayesian hypothesis test'}
		%% METHOD 2: Hypothesis testing approach
		warning('Not yet implemented')
		
	case{'point estimates'}
		%% MERTHOD 3: Estimation with point estimates
		warning('Not yet implemented')
		
		% 1. Extract point estimates.
		% 2. Run frequentist comparison in Matlab
		% 3. Export a .csv file of point estimate for analysis in JAGS
		
end

end