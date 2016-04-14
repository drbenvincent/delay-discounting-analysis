function figGroupLevelWrapperLOGK(mcmc, data, variables, saveFolder, modelType)

  % Get group-level data
  [pSamples] = mcmc.getSamples(variables);

  figure(99), clf
  set(gcf,'Name','GROUP LEVEL')

  pointEstimate.logk = mcmc.getStats('mean', 'logk_group');
  pointEstimate.epsilon = mcmc.getStats('mean', 'epsilon_group');
  pointEstimate.alpha = mcmc.getStats('mean', 'alpha_group');

  figParticipantLOGK(...
		vec(pSamples.('logk_group')),...
		vec(pSamples.('epsilon_group')),...
		vec(pSamples.('alpha_group')),...
    pointEstimate);

  % EXPORTING ---------------------
  latex_fig(16, 18, 4)
	myExport('GROUP',...
		'saveFolder', saveFolder,...
		'prefix', modelType)
  % -------------------------------
end
