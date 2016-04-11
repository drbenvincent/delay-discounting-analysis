function figPsychometricParamsHierarchical(mcmc, data)
  % Plot priors/posteriors for parameters related to the psychometric
  % function, ie how response 'errors' are characterised
  %
  % figPsychometricParams(hModel.mcmc.samples)

  figure(7), clf
  P=data.nParticipants;
  %====================================
  subplot(3,2,1)
  UnivariateDistribution(mcmc.getSamplesAsMatrix({'alpha_group'}),...
    'priorSamples', mcmc.getSamplesAsMatrix({'alpha_group_prior'}))
  title('Group \alpha')

  subplot(3,4,5)
  UnivariateDistribution(mcmc.getSamplesAsMatrix({'groupALPHAmu'}),...
    'priorSamples', mcmc.getSamplesAsMatrix({'groupALPHAmu_prior'}),...
    'xLabel','\mu_\alpha')

  subplot(3,4,6)
  UnivariateDistribution(mcmc.getSamplesAsMatrix({'groupALPHAsigma'}),...
    'priorSamples', mcmc.getSamplesAsMatrix({'groupALPHAsigma_prior'}),...
    'xLabel','\sigma_\alpha')

  subplot(3,2,5),
  for p=1:P-1 % plot participant level alpha (alpha(:,:,p))
    [F,XI]=ksdensity(...
      mcmc.getSamplesFromParticipantAsMatrix(p,{'alpha'}),... %vec(samples.alpha(:,:,p)),...
      'support','positive',...
      'function','pdf');
    plot(XI, F)
    hold on
  end
  xlabel('\alpha_p')
  box off

  %====================================
  subplot(3,2,2)
  UnivariateDistribution(mcmc.getSamplesAsMatrix({'epsilon_group'}),...
    'priorSamples', mcmc.getSamplesAsMatrix({'epsilon_group_prior'}))
  title('Group \epsilon')

  subplot(3,4,7),
  UnivariateDistribution(mcmc.getSamplesAsMatrix({'groupW'}),...
    'priorSamples', mcmc.getSamplesAsMatrix({'groupW_prior'}),...
    'xLabel','\omega (mode)')

  subplot(3,4,8)
  UnivariateDistribution(mcmc.getSamplesAsMatrix({'groupK'}),...
    'priorSamples', mcmc.getSamplesAsMatrix({'groupK_prior'}),...
    'xLabel','\kappa (concentration)')

  subplot(3,2,6),
  for p=1:P-1 % plot participant level alpha (alpha(:,:,p))
    [F,XI]=ksdensity(...
      mcmc.getSamplesFromParticipantAsMatrix(p,{'epsilon'}),... % vec(samples.epsilon(:,:,p)),...
      'support','positive',...
      'function','pdf');
    plot(XI, F)
    hold on
  end
  xlabel('\epsilon_p')
  box off
end
