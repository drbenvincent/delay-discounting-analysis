function figPsychometricParamsHierarchical(mcmc, data)
  % Plot priors/posteriors for parameters related to the psychometric
  % function, ie how response 'errors' are characterised
  %
  % figPsychometricParams(hModel.mcmc.samples)

  figure(7), clf
  P=data.nParticipants;
  %====================================
  subplot(3,2,1)
  plotPriorPostHist(...
    mcmc.getSamplesAsMatrix({'alpha_group_prior'}),...
    mcmc.getSamplesAsMatrix({'alpha_group'}));
  title('Group \alpha')

  subplot(3,4,5)
  plotPriorPostHist(...
    mcmc.getSamplesAsMatrix({'groupALPHAmu_prior'}),...
    mcmc.getSamplesAsMatrix({'groupALPHAmu'}));
  xlabel('\mu_\alpha')

  subplot(3,4,6)
  plotPriorPostHist(...
    mcmc.getSamplesAsMatrix({'groupALPHAsigma_prior'}),...
    mcmc.getSamplesAsMatrix({'groupALPHAsigma'}));
  xlabel('\sigma_\alpha')

  subplot(3,2,5),
  for p=1:P-1 % plot participant level alpha (alpha(:,:,p))
    %histogram(vec(samples.alpha(:,:,p)));
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
  plotPriorPostHist(...
    mcmc.getSamplesAsMatrix({'epsilon_group_prior'}),...
    mcmc.getSamplesAsMatrix({'epsilon_group'}));
  title('Group \epsilon')

  subplot(3,4,7),
  plotPriorPostHist(...
    mcmc.getSamplesAsMatrix({'groupW_prior'}),...
    mcmc.getSamplesAsMatrix({'groupW'}));
  xlabel('\omega (mode)')

  subplot(3,4,8),
  plotPriorPostHist(...
    mcmc.getSamplesAsMatrix({'groupK_prior'}),...
    mcmc.getSamplesAsMatrix({'groupK'}));
  xlabel('\kappa (concentration)')

  subplot(3,2,6),
  for p=1:P-1 % plot participant level alpha (alpha(:,:,p))
    %histogram(vec(samples.epsilon(:,:,p)));
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
