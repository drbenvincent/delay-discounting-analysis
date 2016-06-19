function addGoodnessOfFitScoreToPlot(goodnessOfFit)

if isempty(goodnessOfFit), return, end

% add goodness of fit
fit_score = sprintf('fit score: %.1f',goodnessOfFit);
%addTextToFigure('BR',fit_score, 15, 'latex')
title(fit_score)

return