function figParticipantLOGK(pSamples, pointEstimate, varargin)

p = inputParser;
p.FunctionName = mfilename;
p.addRequired('pSamples',@isstruct);
p.addRequired('pointEstimate',@isstruct);
p.addParameter('pData',[], @isstruct);
p.addParameter('opts',[], @isstruct);
p.parse(pSamples, pointEstimate, varargin{:});

rows=1; cols=4;

subplot(rows, cols, 1)
mcmc.BivariateDistribution(pSamples.epsilon, pSamples.alpha,...
	'xLabel','error rate, $\epsilon$',...
	'ylabel','comparison accuity, $\alpha$',...
	'pointEstimateType','mode');

subplot(rows, cols, 2)
plotPsychometricFunc(pSamples,...
	[pointEstimate.epsilon, pointEstimate.alpha]);

subplot(rows, cols, 3)
mcmc.UnivariateDistribution(pSamples.logk(:),...
 'killYAxis', true,...
 'xLabel', '$\log(k)$');

% Plot in 2D data space
subplot(rows, cols, 4)
if ~isempty(p.Results.pData)
	% participant level, we have data
	plotDiscountFunction(pointEstimate.logk, pSamples.logk(:), 'data',p.Results.pData);
else
	% for group level where there is no data
	plotDiscountFunction(pointEstimate.logk, pSamples.logk(:));
end

end
