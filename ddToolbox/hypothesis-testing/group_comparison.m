function group1_minus_group2 = group_comparison(group1, group2, vars, group_level_participant_index, pointEstimateType)
% group1_minus_group2 = group_comparison(group1, group2, {'logk'}, 11)

% input validation
assert(any(strcmp(superclasses(group1),'Model')), 'group1 must be some subclass of Model')
assert(any(strcmp(superclasses(group2),'Model')), 'group2 must be some subclass of Model')
assert(iscellstr(vars))
assert(any(strcmp(pointEstimateType,{'mean','median','mode'})))

% grab estimates for all requested variables, into a structure
group1_estimates = group1.coda.getSamplesAtIndex(group_level_participant_index, vars);
group2_estimates = group2.coda.getSamplesAtIndex(group_level_participant_index, vars);

% compute the difference
for var = vars
	group1_minus_group2.(var{:}) = group1_estimates.(var{:}) - group2_estimates.(var{:});
end


%% Parameter Estimation approach
% Now you can make decisions about whether there are group level
% differences based upon whether the 95% credible region overlaps with zero
% (ie no group difference) or not.

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



%% Hypothesis testing approach
% TODO: BAYESIAN HYPOTHESIS TESTING


end