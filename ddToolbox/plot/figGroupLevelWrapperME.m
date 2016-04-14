function figGroupLevelWrapperME(pSamples, pointEstimate, saveFolder, modelType)

figure(99), clf
set(gcf,'Name','GROUP LEVEL')

% TODO: Fix
%   opts.maxlogB	= max(abs(data.observedData.B(:)));
%   opts.maxD		= max(data.observedData.DB(:));
opts.maxlogB	= 1000;
opts.maxD		= 365*5;

figParticipantME(pSamples, pointEstimate,...
	'opts', opts);

% EXPORTING ---------------------
latex_fig(16, 18, 4)
myExport('GROUP',...
	'saveFolder', saveFolder,...
	'prefix', modelType)

% -------------------------------
end
