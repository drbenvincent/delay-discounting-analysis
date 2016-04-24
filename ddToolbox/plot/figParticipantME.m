function figParticipantME(pSamples, pointEstimate, varargin)

p = inputParser;
p.FunctionName = mfilename;
p.addRequired('pSamples',@isstruct);
p.addRequired('pointEstimate',@isstruct);
p.addParameter('pData',[], @isstruct);
p.addParameter('opts',[], @isstruct);
p.parse(pSamples, pointEstimate, varargin{:});

rows=1; cols=5;

subplot(rows, cols, 1)
mcmc.BivariateDistribution(pSamples.epsilon(:), pSamples.alpha(:),...
	'xLabel','error rate, $\epsilon$',...
	'ylabel','comparison accuity, $\alpha$',...
	'pointEstimateType','mode');

subplot(rows, cols, 2)
plotPsychometricFunc(pSamples, [pointEstimate.epsilon, pointEstimate.alpha]);

subplot(rows, cols, 3)
mcmc.BivariateDistribution(pSamples.m(:), pSamples.c(:),...
	'xLabel','slope, $m$',...
	'ylabel','intercept, $c$',...
	'pointEstimateType','mode');

subplot(rows, cols, 4)
plotMagnitudeEffect(pSamples, [pointEstimate.m, pointEstimate.c]);

% Plot in 3D data space
subplot(rows, cols, 5)
if ~isempty(p.Results.pData)
	% participant, we have data
	plotDiscountSurface([pointEstimate.m, pointEstimate.c], p.Results.opts,...
		'data', p.Results.pData);
else
	% no data for group level
	plotDiscountSurface([pointEstimate.m, pointEstimate.c], p.Results.opts);
end
% 			set(gca,'XTick',[10 100])
% 			set(gca,'XTickLabel',[10 100])
% 			set(gca,'XLim',[10 100])
end
