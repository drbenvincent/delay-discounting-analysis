function HTgroupSlopeLessThanZero(modelObject)
  % Test the hypothesis that the group level slope (G^m) is less
  % than one

figure


priorSamples = modelObject.mcmc.getSamplesAsMatrix({'m_group_prior'});
posteriorSamples = modelObject.mcmc.getSamplesAsMatrix({'m_group'});

%% METHOD 1
subplot(1,2,1)
HT_BayesFactor(priorSamples, posteriorSamples)
		
%% METHOD 2
subplot(1,2,2)
plotPosteriorHDI(priorSamples, posteriorSamples)

%% 
myExport(modelObject.saveFolder, [], '-BayesFactorMLT1')
end
