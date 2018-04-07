function allParametricModels = getAllParametricModelNames()
allParametricModels = {'ModelHierarchicalME_MVNORM',...
	'ModelHierarchicalMEUpdated',...
	'ModelHierarchicalME', 'ModelMixedME', 'ModelSeparateME',...
	'ModelHierarchicalLogK', 'ModelMixedLogK', 'ModelSeparateLogK',...
	'ModelHierarchicalHyperboloid', 'ModelMixedHyperboloid', 'ModelSeparateHyperboloid',...
    'ModelHierarchicalHyperboloidB', 'ModelMixedHyperboloidB', 'ModelSeparateHyperboloidB',...
	'ModelHierarchicalBetaDelta', 'ModelMixedBetaDelta', 'ModelSeparateBetaDelta',...
	'ModelHierarchicalExp1', 'ModelMixedExp1', 'ModelSeparateExp1',...
	'ModelSeparateExpPower', 'ModelMixedExpPower',... % no hierarchical model
	'ModelSeparateExpLog', 'ModelMixedExpLog',... % no hierarchical model
	'ModelSeparateEbertPrelec', 'ModelMixedEbertPrelec',... % no hierarchical model
    'ModelHierarchicalHyperbolicUtility'}; % non-linear utility model
end
