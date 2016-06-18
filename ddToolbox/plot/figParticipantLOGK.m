function figParticipantLOGK(pSamples, pointEstimateType, varargin)

p = inputParser;
p.FunctionName = mfilename;
p.addRequired('pSamples',@isstruct);
p.addRequired('pointEstimateType', @(x) any(strcmp(x,{'mean','median','mode'})));
p.addParameter('pData',[], @isstruct);
p.addParameter('opts',[], @isstruct);
p.parse(pSamples, pointEstimateType, varargin{:});

rows=1; cols=4;

subplot(rows, cols, 1)
epsilon_alpha = mcmc.BivariateDistribution(pSamples.epsilon, pSamples.alpha,...
	'xLabel','error rate, $\epsilon$',...
	'ylabel','comparison accuity, $\alpha$',...
	'pointEstimateType',p.Results.pointEstimateType);

subplot(rows, cols, 2)
plotPsychometricFunc(pSamples, p.Results.pointEstimateType);

subplot(rows, cols, 3)
logk = mcmc.UnivariateDistribution(pSamples.logk(:),...
 'killYAxis', true,...
 'xLabel', '$\log(k)$',...
 'pointEstimateType',p.Results.pointEstimateType);

% Plot in 2D data space
subplot(rows, cols, 4)
if ~isempty(p.Results.pData)
	% participant level, we have data
	plotDiscountFunction(pSamples.logk(:),...
		'data',p.Results.pData,...
		'pointEstimateType',p.Results.pointEstimateType);
else
	% for group level where there is no data
	plotDiscountFunction(pSamples.logk(:),...
		'pointEstimateType',p.Results.pointEstimateType);
end

end
