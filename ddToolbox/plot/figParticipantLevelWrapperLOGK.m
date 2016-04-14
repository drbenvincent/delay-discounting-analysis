function figParticipantLevelWrapperLOGK(mcmc, data, variables, participant_prior_variables, saveFolder, modelType, opts)
  % For each participant, call some plotting functions on the variables provided.

  logkPointEstimates = mcmc.getStats('mean', 'logk');
  epsilonPointEstimates = mcmc.getStats('mean', 'epsilon');
  alphaPointEstimates = mcmc.getStats('mean', 'alpha');

  for n = 1:data.nParticipants
    fh = figure;
    fh.Name=['participant: ' data.IDname{n}];

    % 1) figParticipant plot
    [pSamples] = mcmc.getSamplesAtIndex(n, variables);
		[pData] = data.getParticipantData(n);

    % TODO: make into a get method of mcmc?
		pointEstimate.logk = logkPointEstimates(n);
		pointEstimate.epsilon = epsilonPointEstimates(n);
		pointEstimate.alpha = alphaPointEstimates(n);

		figParticipantLOGK(pSamples, pointEstimate, 'pData', pData);

    latex_fig(16, 18, 4)
		myExport(data.IDname{n},...
			'saveFolder', saveFolder,...
			'prefix', modelType);
    close(fh)

    % 2) Triplot
    posteriorSamples = mcmc.getSamplesFromParticipantAsMatrix(n, variables);
    priorSamples = mcmc.getSamplesAsMatrix(participant_prior_variables);

		figure(87)
		TriPlotSamples(posteriorSamples, variables, 'PRIOR', priorSamples);

		myExport([data.IDname{n} '-triplot'],...
			'saveFolder', saveFolder,...
			'prefix', modelType);
  end
end
