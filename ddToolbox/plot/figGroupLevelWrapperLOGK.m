function figGroupLevelWrapperLOGK(mcmc, data, variables, saveFolder, modelType)
  % get group level parameters in a form ready to pass off to
  % figParticipant()

  % Get group-level data
  [pSamples] = mcmc.getSamples(variables);
  % rename fields
  [pSamples.('logk')] = pSamples.('logk_group'); pSamples = rmfield(pSamples,'logk_group');
  [pSamples.('epsilon')] = pSamples.('epsilon_group'); pSamples = rmfield(pSamples,'epsilon_group');
  [pSamples.('alpha')] = pSamples.('alpha_group'); pSamples = rmfield(pSamples,'alpha_group');

  pData = []; % no data for group level

  figure(99), clf
  set(gcf,'Name','GROUP LEVEL')

  logkMEAN = mcmc.getStats('mean', 'logk_group');
  epsilonMEAN = mcmc.getStats('mean', 'epsilon_group');
  alphaMEAN = mcmc.getStats('mean', 'alpha_group');

  figParticipantLOGK(pSamples, pData, logkMEAN, epsilonMEAN, alphaMEAN)

  % EXPORTING ---------------------
  latex_fig(16, 18, 4)
  myExport(saveFolder, modelType, '-GROUP')
  % -------------------------------
end
