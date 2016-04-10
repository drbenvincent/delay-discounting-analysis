function figParticipantLevelWrapperME(mcmc, data, variables,...
	participant_prior_variables, saveFolder, modelType)
  % For each participant, call some plotting functions on the variables provided.

  mMEAN = mcmc.getStats('mean', 'm');
  cMEAN = mcmc.getStats('mean', 'c');
  epsilonMEAN = mcmc.getStats('mean', 'epsilon');
  alphaMEAN = mcmc.getStats('mean', 'alpha');

  for n = 1:data.nParticipants
    fh = figure;
    fh.Name=['participant: ' data.IDname{n}];

    % 1) figParticipant plot
    [pSamples] = mcmc.getSamplesAtIndex(n, variables);
    [pData] = data.getParticipantData(n);

    figParticipantME(...
      mcmc.getSamplesAtIndex(n, variables),...
      data.getParticipantData(n),...
      mMEAN(n), cMEAN(n), epsilonMEAN(n), alphaMEAN(n))

    latex_fig(16, 18, 4)
    myExport(saveFolder, modelType, ['-' data.IDname{n}])
    close(fh)

    % 2) Triplot
    posteriorSamples = mcmc.getSamplesFromParticipantAsMatrix(n, variables);
    priorSamples = mcmc.getSamplesAsMatrix(participant_prior_variables);

		figure(87)
		triPlotSamples(priorSamples, posteriorSamples, variables, [])

    myExport(saveFolder, modelType, ['-' data.IDname{n} '-triplot'])
  end
end
