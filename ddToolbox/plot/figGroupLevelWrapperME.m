function figGroupLevelWrapperME(mcmc, data, variables, saveFolder, modelType)
  % get group level parameters in a form ready to pass off to
  % figParticipant()

  % Get group-level data
  [pSamples] = mcmc.getSamples(variables);
  % rename fields
  [pSamples.('m')] = pSamples.('m_group'); pSamples = rmfield(pSamples,'m_group');
  [pSamples.('c')] = pSamples.('c_group'); pSamples = rmfield(pSamples,'c_group');
  [pSamples.('epsilon')] = pSamples.('epsilon_group'); pSamples = rmfield(pSamples,'epsilon_group');
  [pSamples.('alpha')] = pSamples.('alpha_group'); pSamples = rmfield(pSamples,'alpha_group');

  pData = []; % no data for group level

  figure(99), clf
  set(gcf,'Name','GROUP LEVEL')

  mMEAN = mcmc.getStats('mean', 'm_group');
  cMEAN = mcmc.getStats('mean', 'c_group');
  epsilonMEAN = mcmc.getStats('mean', 'epsilon_group');
  alphaMEAN = mcmc.getStats('mean', 'alpha_group');

  opts.maxlogB	= max(abs(data.observedData.B(:)));
  opts.maxD		= max(data.observedData.DB(:));

  figParticipantME(pSamples, pData, mMEAN, cMEAN, epsilonMEAN, alphaMEAN, opts)

  % EXPORTING ---------------------
%   latex_fig(16, 18, 4)
%   myExport('GROUP',...
% 					'saveFolder', obj.saveFolder,...
% 					'prefix', obj.modelType)
	
  % -------------------------------
end
