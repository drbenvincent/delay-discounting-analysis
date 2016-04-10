function figPsychometricParamsSeparate(mcmc, data)
  % Plot priors/posteriors for parameters related to the psychometric
  % function, ie how response 'errors' are characterised
  %
  % plotPsychometricParams(hModel.sampler.samples)

  figure(7), clf
  P=obj.data.nParticipants;
% 			%====================================
% 			subplot(3,2,1)
% 			plotPriorPostHist(...
% 				obj.sampler.getSamplesAsMatrix({'alpha_group_prior'}),...
% 				obj.sampler.getSamplesAsMatrix({'alpha_group'}));
% 			title('Group \alpha')
%
% 			subplot(3,4,5)
% 			plotPriorPostHist(...
% 				obj.sampler.getSamplesAsMatrix({'groupALPHAmu_prior'}),...
% 				obj.sampler.getSamplesAsMatrix({'groupALPHAmu'}));
% 			xlabel('\mu_\alpha')
%
% 			subplot(3,4,6)
% 			plotPriorPostHist(...
% 				obj.sampler.getSamplesAsMatrix({'groupALPHAsigma_prior'}),...
% 				obj.sampler.getSamplesAsMatrix({'groupALPHAsigma'}));
% 			xlabel('\sigma_\alpha')

  subplot(3,2,5),
        for p=1:P-1 % plot participant level alpha (alpha(:,:,p))
          %histogram(vec(samples.alpha(:,:,p)));
          [F,XI]=ksdensity(vec(obj.sampler.samples.alpha(:,:,p)),...
            'support','positive',...
            'function','pdf');
          plot(XI, F)
          hold on
        end
  xlabel('\alpha_p')
  box off

% 			%====================================
% 			subplot(3,2,2)
% 			plotPriorPostHist(...
% 				obj.sampler.getSamplesAsMatrix({'epsilon_group_prior'}),...
% 				obj.sampler.getSamplesAsMatrix({'epsilon_group'}));
% 			title('Group \epsilon')
%
% 			subplot(3,4,7),
% 			plotPriorPostHist(...
% 				obj.sampler.getSamplesAsMatrix({'groupW_prior'}),...
% 				obj.sampler.getSamplesAsMatrix({'groupW'}));
% 			xlabel('\omega (mode)')
%
% 			subplot(3,4,8),
% 			plotPriorPostHist(...
% 				obj.sampler.getSamplesAsMatrix({'groupK_prior'}),...
% 				obj.sampler.getSamplesAsMatrix({'groupK'}));
% 			xlabel('\kappa (concentration)')

  subplot(3,2,6),
        for p=1:P-1 % plot participant level alpha (alpha(:,:,p))
          %histogram(vec(samples.epsilon(:,:,p)));
            [F,XI]=ksdensity(vec(samples.epsilon(:,:,p)),...
            'support','positive',...
            'function','pdf');
          plot(XI, F)
          hold on
        end
  xlabel('\epsilon_p')
  box off
end
