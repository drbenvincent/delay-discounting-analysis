function figGroupLevelWrapperLOGK(pSamples, pointEstimate, saveFolder, modelType)

  figure(99), clf
  set(gcf,'Name','GROUP LEVEL')

  figParticipantLOGK(pSamples, pointEstimate);

  % EXPORTING ---------------------
  latex_fig(16, 18, 4)
	myExport('GROUP',...
		'saveFolder', saveFolder,...
		'prefix', modelType)
  % -------------------------------
end
