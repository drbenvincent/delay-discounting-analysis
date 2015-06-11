function plotDiscountRateDistribution(logKSamples)


samplesK = exp(logKSamples(:));

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% % log spaced bin edges
% edges = linspace( min(logKSamples), max(logKSamples), 50);
% edges = exp(edges);
% 
% h = histogram(samplesK, edges, ...
% 	'Normalization','probability',...
% 	'DisplayStyle','stairs');
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
edges = logspace(-4,0, 50);
h = histogram(samplesK, edges, ...
	'Normalization','probability',...
	'DisplayStyle','stairs');
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% h = histogram(samplesK, 20, ...
% 	'Normalization','probability',...
% 	'DisplayStyle','stairs');
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

set(gca,'XScale','log')
%forceNonExponentialTick
xlabel('discount rate $k$','Interpreter','latex')
axis square

set(gca,'XTick',[logspace(-4,0, 5)])

return,