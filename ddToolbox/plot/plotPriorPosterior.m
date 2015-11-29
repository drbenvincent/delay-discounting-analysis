function plotPriorPosterior(priorSamples, posteriorSamples, titleStr)

% prior
hPrior = histogram(priorSamples(:),...
	'DisplayStyle','bar',...
	'Normalization', 'pdf',...
	'FaceColor',[0.8 0.8 0.8]);
hPrior.EdgeColor='none';
hold on

% posterior
hPosterior = histogram(posteriorSamples(:),...
	'DisplayStyle','bar',...
	'Normalization', 'pdf',...
	'FaceColor',[0.2 0.2 0.2]);
hPosterior.EdgeColor='none';

% formatting
xlim(hPrior.BinLimits)
title(titleStr)
box off
end