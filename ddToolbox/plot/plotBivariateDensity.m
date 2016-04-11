function [structName] = plotBivariateDensity(xSamples, ySamples, varargin)

p = inputParser;
p.FunctionName = mfilename;
p.addRequired('xSamples',@isvector);
p.addRequired('ySamples',@isvector);
p.addParameter('xLabel','x label here',@isstr);
p.addParameter('yLabel','y label here',@isstr);
p.parse(xSamples, ySamples, varargin{:});


[structName] = calcBivariateSummaryStats(xSamples,ySamples, 500, 500, 'kde2d');

% plot
imagesc(structName.xi, structName.yi, structName.density);
axis xy
colormap(gca, flipud(gray));
xlabel(p.Results.xLabel,'Interpreter','latex')
ylabel(p.Results.yLabel,'Interpreter','latex')
axis square
hold on
box off

% indicate posterior mean
plot(mean(xSamples), mean(ySamples), 'ro')



% TODO: fix this commented code *******************************************
% % plot MODE and 95% CI text
% % TODO: grab this from analysis already done, no need to recompute
% [estimated_mode, ~, ~, ci95] = calcUnivariateSummaryStats(xSamples*100, 'positive');
% lr_text = sprintf('$$ \\xSamples = %2.2f (%2.2f, %2.2f) $$',estimated_mode, ci95(1), ci95(2));
%
% [estimated_mode, ~, ~, ci95] = calcUnivariateSummaryStats(ySamples, 'positive');
% ySamples_text = sprintf('$$ \\ySamples = %2.2f (%2.2f, %2.2f) $$',estimated_mode, ci95(1), ci95(2));
%
% str(1)={lr_text};
% str(2)={ySamples_text};
% addTextToFigure('TR',str, 12, 'latex');
return
