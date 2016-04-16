function figParticipantLevelWrapper(mcmc, data, variables, participant_prior_variables, saveFolder, modelType, opts, participantFigPlotFunc)
  % For each participant, call some plotting functions on the variables provided.

  for n = 1:data.nParticipants
    doParticipantPlot()
    doTriPlot()
  end


  function doParticipantPlot()
    fh = figure;
    fh.Name=['participant: ' data.IDname{n}];

    % ==========================================================
    participantFigPlotFunc(mcmc.getSamplesAtIndex(n, variables),...
      mcmc.getParticipantPointEstimates(n, variables),...
      'pData', data.getParticipantData(n),...
			'opts',opts);
    % ==========================================================

    latex_fig(16, 18, 4)
    myExport(data.IDname{n},...
      'saveFolder', saveFolder,...
      'prefix', modelType);
    close(fh)
  end

  function doTriPlot()
    figure(87)
    TriPlotSamples(mcmc.getSamplesFromParticipantAsMatrix(n, variables),...
      variables,...
      'PRIOR',mcmc.getSamplesAsMatrix(participant_prior_variables));

    myExport([data.IDname{n} '-triplot'],...
      'saveFolder', saveFolder,...
      'prefix', modelType);
  end

end
