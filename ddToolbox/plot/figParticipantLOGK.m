function figParticipantLOGK(logkSamples, epsilonSamples, alphaSamples, pointEstimate, varargin)

p = inputParser;
p.FunctionName = mfilename;
p.addRequired('epsilonSamples',@isvector);
p.addRequired('alphaSamples',@isvector);
p.addRequired('logkSamples',@isvector);
p.addRequired('pointEstimate',@isstruct);
p.addParameter('pData',[], @isstruct);
p.parse(epsilonSamples, alphaSamples, logkSamples, pointEstimate, varargin{:});

rows=1; cols=4;

subplot(rows, cols, 1)
BivariateDistribution(epsilonSamples(:), alphaSamples(:),...
	'xLabel','error rate, $\epsilon$',...
	'ylabel','comparison accuity, $\alpha$');

subplot(rows, cols, 2)
plotPsychometricFunc(epsilonSamples, alphaSamples,...
	[pointEstimate.epsilon, pointEstimate.alpha]);

subplot(rows, cols, 3)
UnivariateDistribution(logkSamples(:),...
 'killYAxis', true,...
 'xLabel', '$\log(k)$');

% Plot in 2D data space
subplot(rows, cols, 4)
if ~isempty(p.Results.pData)
	% participant level, we have data
	plotDiscountFunction(pointEstimate.logk, logkSamples(:), 'data',p.Results.pData);
else
	% for group level where there is no data
	plotDiscountFunction(pointEstimate.logk, logkSamples(:));
end

end
