function figGroupLevelWrapper(pSamples, pointEstimate, saveFolder, modelType, participantPlotFunc, opts)

error('Am I even calling this?')
% participantPlotFunc = {'figParticipantLOGK' or 'figParticipantME'}

  figure(99), clf
  set(gcf,'Name','GROUP LEVEL')

  participantPlotFunc(pSamples, pointEstimate,...
  	'opts', opts);

  % EXPORTING ---------------------
  latex_fig(16, 18, 4)
	myExport('GROUP',...
		'saveFolder', saveFolder,...
		'prefix', modelType)
  % -------------------------------
end
