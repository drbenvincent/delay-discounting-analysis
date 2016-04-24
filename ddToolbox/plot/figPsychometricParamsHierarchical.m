function figPsychometricParamsHierarchical(mcmcContainer, data)
  % Plot priors/posteriors for parameters related to the psychometric
  % function, ie how response 'errors' are characterised
  %
  % figPsychometricParams(hModel.mcmc.samples)
  
  figure(7), clf
  P=data.nParticipants;
  %====================================
  subplot(3,2,1)
  mcmc.UnivariateDistribution(mcmcContainer.getSamplesAsMatrix({'alpha_group'}),...
    'priorSamples', mcmcContainer.getSamplesAsMatrix({'alpha_group_prior'}));
  title('Group \alpha')

  subplot(3,4,5)
  mcmc.UnivariateDistribution(mcmcContainer.getSamplesAsMatrix({'groupALPHAmu'}),...
    'priorSamples', mcmcContainer.getSamplesAsMatrix({'groupALPHAmu_prior'}),...
    'xLabel','\mu_\alpha');

  subplot(3,4,6)
  mcmc.UnivariateDistribution(mcmcContainer.getSamplesAsMatrix({'groupALPHAsigma'}),...
    'priorSamples', mcmcContainer.getSamplesAsMatrix({'groupALPHAsigma_prior'}),...
    'xLabel','\sigma_\alpha');

  subplot(3,2,5),
  for p=1:P-1 % plot participant level alpha (alpha(:,:,p))
    [F,XI]=ksdensity(...
      mcmcContainer.getSamplesFromParticipantAsMatrix(p,{'alpha'}),... %vec(samples.alpha(:,:,p)),...
      'support','positive',...
      'function','pdf');
    plot(XI, F)
    hold on
  end
  xlabel('\alpha_p')
  box off

  %====================================
  subplot(3,2,2)
  mcmc.UnivariateDistribution(mcmcContainer.getSamplesAsMatrix({'epsilon_group'}),...
    'priorSamples', mcmcContainer.getSamplesAsMatrix({'epsilon_group_prior'}));
  title('Group \epsilon')

  subplot(3,4,7),
  mcmc.UnivariateDistribution(mcmcContainer.getSamplesAsMatrix({'groupW'}),...
    'priorSamples', mcmcContainer.getSamplesAsMatrix({'groupW_prior'}),...
    'xLabel','\omega (mode)');

  subplot(3,4,8)
  mcmc.UnivariateDistribution(mcmcContainer.getSamplesAsMatrix({'groupK'}),...
    'priorSamples', mcmcContainer.getSamplesAsMatrix({'groupK_prior'}),...
    'xLabel','\kappa (concentration)');

  subplot(3,2,6),
  for p=1:P-1 % plot participant level alpha (alpha(:,:,p))
    [F,XI]=ksdensity(...
      mcmcContainer.getSamplesFromParticipantAsMatrix(p,{'epsilon'}),... % vec(samples.epsilon(:,:,p)),...
      'support','positive',...
      'function','pdf');
    plot(XI, F)
    hold on
  end
  xlabel('\epsilon_p')
  box off
end
